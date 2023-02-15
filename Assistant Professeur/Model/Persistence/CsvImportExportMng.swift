//
//  CsvImportExportMng.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/02/2023.
//

import Foundation
import os
import TabularData

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "CsvImportExportMng"
)
/// Export/Import vers/depuis des fichiers CSV
enum CsvImporterError: Error {
    case incompatibleColumnNames
}

enum CsvImportExportMng {
    // MARK: - Export

    static let csvEleveListFileName = "élèves.csv"
    static let csvProgramListFileName = "programmes.csv"

    static func csvFileName(classe: ClasseEntity) -> String {
        (classe.school?.displayString ?? "") + classe.displayString + "_groupes.csv"
    }

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportEleves() {
        var total = DataFrame()
        SchoolEntity.all()
            .forEach { school in
                school.allClasses
                    .forEach { classe in
                        let dataFrame = classeGroupsDataFrame(de: classe)
                        print(dataFrame)
                        if total.isEmpty {
                            total = dataFrame
                        } else {
                            total.append(rowsOf: dataFrame)
                        }
                    }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvEleveListFileName)

        let options = CSVWritingOptions(
            includesHeader: true,
            nilEncoding: "",
            trueEncoding: "true",
            falseEncoding: "false",
            delimiter: ";"
        )
        try?
        total.writeCSV(
            to: fileUrl,
            options: options
        )
    }

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportGroups(de classe: ClasseEntity) {
        let groupsDataFrame = classeGroupsDataFrame(de: classe)

        let fileName = csvFileName(classe: classe)
        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: fileName)

        let options = CSVWritingOptions(
            includesHeader: true,
            nilEncoding: "",
            trueEncoding: "true",
            falseEncoding: "false",
            delimiter: ";"
        )
        try?
            groupsDataFrame.writeCSV(
                to: fileUrl,
                options: options
            )
    }

    /// Construit la table des élèves des groupes d'une classe
    static func classeGroupsDataFrame(de classe: ClasseEntity) -> DataFrame {
        // TODO: - Exporter les groupes au format CSV
        var dataFrame = DataFrame()

        let schoolColumnID = ColumnID("Établissement", String.self)
        let classeColumnID = ColumnID("Classe", String.self)
        let groupeColumnID = ColumnID("Groupe", String.self)
        let eleveColumnID = ColumnID("Élève", String.self)
//        let columnNames = [classeColumnID.name, groupeColumnID.name, eleveColumnID.name]

        var schoolColumn = Column(schoolColumnID, capacity: 1)
        var classeColumn = Column(classeColumnID, capacity: 15)
        var groupeColumn = Column(groupeColumnID, capacity: 15)
        var eleveColumn = Column(eleveColumnID, capacity: 15)

        let schoolName = classe.school?.displayString
        let classeName = classe.displayString

        classe.allGroups.forEach { group in
            group.allEleves.forEach { eleve in
                schoolColumn.append(schoolName)
                classeColumn.append(classeName)
                groupeColumn.append(group.displayString)
                eleveColumn.append(eleve.displayName)
            }
        }

        dataFrame.append(column: schoolColumn)
        dataFrame.append(column: classeColumn)
        dataFrame.append(column: groupeColumn)
        dataFrame.append(column: eleveColumn)

        return dataFrame
            .sorted(
                on: groupeColumnID,
                order: .ascending
            )
    }

    // MARK: - Import

    /// Importer de nouveaux élèves depuis le contenu de fichier au format CSV
    /// et les ajouter à la `classe`.
    /// - Parameters:
    ///   - interoperability: interoperabilité avec ProNote ou EcoleDirecte
    static func importElevesListe(
        for classe: ClasseEntity,
        interoperability: Interoperability,
        result: Result<[URL], Error>
    )
        -> (
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false

        switch result {
            case let .failure(error):
                customLog.log(
                    level: .fault,
                    "Error selecting file: \(error.localizedDescription)"
                )
                alertTitle = "Échec"
                alertMessage = "L'importation du fichier a échouée"
                alertIsPresented.toggle()

            case let .success(filesUrl):
                filesUrl.forEach { fileUrl in
                    guard fileUrl.startAccessingSecurityScopedResource() else {
                        return
                    }

                    if let data = try? Data(contentsOf: fileUrl) {
                        do {
                            switch interoperability {
                                case .ecoleDirecte:
                                    try importElevesFromEcoleDirecte(
                                        from: data,
                                        dans: classe
                                    )

                                case .proNote:
                                    try importElevesFromPRONOTE(
                                        from: data,
                                        dans: classe
                                    )
                            }
                        } catch {
                            customLog.log(
                                level: .fault,
                                "Error reading file: \(error.localizedDescription)"
                            )
                            alertTitle = "Échec"
                            alertMessage = "L'importation du fichier a échouée"
                            alertIsPresented.toggle()
                        }
                    }

                    fileUrl.stopAccessingSecurityScopedResource()
                }
        }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer de nouveaux élèves depuis le contenu de fichier `data`
    /// et les ajouter à la `classe`.
    ///
    /// Le format utilisé est proche de celui des exports depuis PRONOTE:
    ///   - Colonne nommée "Élève": nom et prénom séparés par un espace
    ///   - Colonne nommée "Sexe": 'G' pour garçon
    ///
    /// - Parameters:
    ///   - data: Contenu du fichier à importer
    ///   - classe: La classe à laquelle ajouter l'élève
    static func importElevesFromPRONOTE(
        from data: Data,
        dans classe: ClasseEntity
    ) throws {
        let nameColumn = ColumnID("Élève", String.self)
        let sexeColumn = ColumnID("Sexe", String.self)

        let columnNames = [nameColumn.name, sexeColumn.name]

        let options = CSVReadingOptions(
            hasHeaderRow: true,
            nilEncodings: ["", "nil"],
            ignoresEmptyLines: true,
            delimiter: ";"
        )

        var dataFrame = try DataFrame(
            csvData: data,
            columns: columnNames,
            types: [
                nameColumn.name: .string,
                sexeColumn.name: .string
            ],
            options: options
        )

        let resolvedColumnsNames = Set(dataFrame.columns.map(\.name))
        guard resolvedColumnsNames.intersection(columnNames) == resolvedColumnsNames else {
            throw CsvImporterError.incompatibleColumnNames
        }

        dataFrame.transformColumn("Sexe") { data in
            data == "G" ? "male" : "female"
        }

        return dataFrame
            .filter(on: "Élève", String.self) {
                if let name = $0 {
                    return !name.contains("Eleve")
                } else {
                    return false
                }
            }
            .rows
            .forEach { row in
                if let nom = row["Élève", String.self]?.split(separator: " ") {
                    EleveEntity.create(
                        familyName: String(nom[0]),
                        givenName: String(nom.last!),
                        sex: (row["Sexe", String.self] == "male") ? .male : .female,
                        dans: classe
                    )
                }
            }
    }

    /// Importer de nouveaux élèves depuis le contenu de fichier `data`
    /// et les ajouter à la `classe`.
    ///
    /// Le format utilisé est proche de celui des exports depuis Ecole Directe:
    ///   - Colonne nommée "Nom": nom et prénom séparés par un espace
    ///   - Colonne nommée "Sexe": 'G' pour garçon
    ///
    /// - Parameters:
    ///   - data: Contenu du fichier à importer
    ///   - classe: La classe à laquelle ajouter l'élève
    static func importElevesFromEcoleDirecte(
        from data: Data,
        dans classe: ClasseEntity
    ) throws {
        let nameColumn = ColumnID("Nom", String.self)
        let sexeColumn = ColumnID("Sexe", String.self)

        let columnNames = [nameColumn.name, sexeColumn.name]

        let options = CSVReadingOptions(
            hasHeaderRow: true,
            nilEncodings: ["", "nil"],
            ignoresEmptyLines: true,
            delimiter: ";"
        )

        var dataFrame = try DataFrame(
            csvData: data,
            columns: columnNames,
            types: [
                nameColumn.name: .string,
                sexeColumn.name: .string
            ],
            options: options
        )

        let resolvedColumnsNames = Set(dataFrame.columns.map(\.name))
        guard resolvedColumnsNames.intersection(columnNames) == resolvedColumnsNames else {
            throw CsvImporterError.incompatibleColumnNames
        }

        dataFrame.transformColumn("Sexe") { data in
            data == "G" ? "male" : "female"
        }

        return dataFrame
            .rows
            .forEach { row in
                if let nom = row["Nom", String.self]?.split(separator: " ") {
                    EleveEntity.create(
                        familyName: String(nom[0]),
                        givenName: String(nom.last!),
                        sex: (row["Sexe", String.self] == "male") ? .male : .female,
                        dans: classe
                    )
                }
            }
    }
}
