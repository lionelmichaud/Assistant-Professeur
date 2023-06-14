//
//  CsvImport.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/06/2023.
//

import Foundation
import os
import TabularData

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "CsvImportExportMng.Import"
)

/// IMPORT
extension CsvImportExportMng {
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

                            alertTitle = "Importation réussie"
                            alertMessage = "\(classe.nbOfEleves) élèves importés"
                            alertIsPresented = true

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
                        givenName: String(nom.last!).capitalized,
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
    ///   - Colonne nommée "Nom": nom (sans espace) et prénom séparés par un espace
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
            data == "M" ? "male" : "female"
        }

        return dataFrame
            .rows
            .forEach { row in
                if let nom = row["Nom", String.self]?.split(separator: " ") {
                    EleveEntity.create(
                        familyName: String(nom[0]),
                        givenName: String(nom.last!.capitalized),
                        sex: (row["Sexe", String.self] == "male") ? .male : .female,
                        dans: classe
                    )
                }
            }
    }
}
