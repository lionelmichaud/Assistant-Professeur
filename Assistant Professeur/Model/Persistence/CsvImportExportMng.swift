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

enum CsvImportExportMng { // swiftlint:disable:this type_body_length
    // MARK: - Export

    static let csvEleveListFileName = "élèves.csv"
    static let csvProgramListFileName = "programmes.csv"

    static func csvFileName(classe: ClasseEntity) -> String {
        (classe.school?.displayString ?? "") + classe.displayString + "_groupes.csv"
    }

    private static var csWritingOptions: CSVWritingOptions {
        CSVWritingOptions(
            includesHeader: true,
            nilEncoding: "",
            trueEncoding: "VRAI",
            falseEncoding: "FAUX",
            delimiter: ";"
        )
    }

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportPrograms() {
        var total = DataFrame()
        ProgramEntity.allSortedbyDisciplineLevelSegpa()
            .forEach { program in
                let dataFrame = programDataFrame(de: program)
                #if DEBUG
                    print(dataFrame)
                #endif
                if total.isEmpty {
                    total = dataFrame
                } else {
                    total.append(rowsOf: dataFrame)
                }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvProgramListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des séquences d'un programme
    static func programDataFrame(de program: ProgramEntity) -> DataFrame {
        // colonnes relatives au programme
        func appendProgramToProgramColumns(program: ProgramEntity) {
            disciplineColumn.append(program.disciplineString)
            levelColumn.append(program.viewLevelEnum.pickerString)
            segpaColumn.append(program.viewSegpa)
            durationColumn.append(program.durationWithoutMargin)
            durationWithMarginColumn.append(program.durationWithMargin)
        }

        // colonnes relatives à la séquence
        func appendSequenceToSequenceColumns(sequence: SequenceEntity?) {
            if let sequence {
                seqNumColumn.append(sequence.viewNumber)
                seqNameColumn.append(sequence.viewName)
                seqDurationColumn.append(sequence.durationWithoutMargin)
                seqDurationWithMarginColumn.append(sequence.durationWithMargin)
            } else {
                seqNumColumn.append(0)
                seqNameColumn.append("aucune")
                seqDurationColumn.append(0.0)
                seqDurationWithMarginColumn.append(0.0)
            }
        }

        // colonnes relatives à l'activité
        func appendActivityToActivityColumns(activity: ActivityEntity?) {
            if let activity {
                actNumColumn.append(activity.viewNumber)
                actNameColumn.append(activity.viewName)
                actDurationColumn.append(activity.duration)
                actIsEvalSommativeColumn.append(activity.viewIsEvalSommative)
                actIsEvalFormativeColumn.append(activity.viewIsEvalFormative)
                actIsTpColumn.append(activity.viewIsTP)
                actIsProjectColumn.append(activity.isProject)
            } else {
                actNumColumn.append(0)
                actNameColumn.append("aucune")
                actDurationColumn.append(0.0)
                actIsEvalSommativeColumn.append(false)
                actIsEvalFormativeColumn.append(false)
                actIsTpColumn.append(false)
                actIsProjectColumn.append(false)
            }
        }

        var dataFrame = DataFrame()

        // colonnes relatives au programme
        let disciplineColumnID = ColumnID("Discipline", String.self)
        let levelColumnID = ColumnID("Niveau", String.self)
        let segpaColumnID = ColumnID("SEGPA", Bool.self)
        let durationColumnID = ColumnID("Durée", Double.self)
        let durationWithMarginColumnID = ColumnID("Durée avec marge", Double.self)

        var disciplineColumn = Column(disciplineColumnID, capacity: 4)
        var levelColumn = Column(levelColumnID, capacity: 4)
        var segpaColumn = Column(segpaColumnID, capacity: 4)
        var durationColumn = Column(durationColumnID, capacity: 4)
        var durationWithMarginColumn = Column(durationWithMarginColumnID, capacity: 4)

        // colonnes relatives à la séquence
        let seqNumColumnID = ColumnID("Séquence numéro", Int.self)
        let seqNameColumnID = ColumnID("Séquence nom", String.self)
        let seqDurationColumnID = ColumnID("Séquence Durée", Double.self)
        let seqDurationWithMarginColumnID = ColumnID("Séquence Durée avec marge", Double.self)

        var seqNumColumn = Column(seqNumColumnID, capacity: 4)
        var seqNameColumn = Column(seqNameColumnID, capacity: 4)
        var seqDurationColumn = Column(seqDurationColumnID, capacity: 4)
        var seqDurationWithMarginColumn = Column(seqDurationWithMarginColumnID, capacity: 4)

        // colonnes relatives à l'activité
        let activityNumColumnID = ColumnID("Activité numéro", Int.self)
        let actNameColumnID = ColumnID("Activité nom", String.self)
        let actDurationColumnID = ColumnID("Activité Durée", Double.self)
        let actIsEvalSommativeColumnID = ColumnID("Activité Eval Sommative", Bool.self)
        let actIsEvalFormativeColumnID = ColumnID("Activité Eval Formative", Bool.self)
        let actIsTpColumnID = ColumnID("Activité TP", Bool.self)
        let actIsProjectColumnID = ColumnID("Activité Projet", Bool.self)

        var actNumColumn = Column(activityNumColumnID, capacity: 4)
        var actNameColumn = Column(actNameColumnID, capacity: 4)
        var actDurationColumn = Column(actDurationColumnID, capacity: 4)
        var actIsEvalSommativeColumn = Column(actIsEvalSommativeColumnID, capacity: 4)
        var actIsEvalFormativeColumn = Column(actIsEvalFormativeColumnID, capacity: 4)
        var actIsTpColumn = Column(actIsTpColumnID, capacity: 4)
        var actIsProjectColumn = Column(actIsProjectColumnID, capacity: 4)

        let sequences = program.sequencesSortedByNumber

        if sequences.isNotEmpty {
            sequences.forEach { sequence in
                let activities = sequence.activitiesSortedByNumber

                // colonnes relatives au programme
                if activities.isNotEmpty {
                    activities.forEach { activity in
                        // colonnes relatives au programme
                        appendProgramToProgramColumns(program: program)

                        // colonnes relatives à la séquence
                        appendSequenceToSequenceColumns(sequence: sequence)

                        // colonnes relatives à l'activité
                        appendActivityToActivityColumns(activity: activity)
                    }
                } else {
                    // colonnes relatives au programme
                    appendProgramToProgramColumns(program: program)

                    // colonnes relatives à la séquence
                    appendSequenceToSequenceColumns(sequence: sequence)

                    // colonnes VIDES relatives à l'activité
                    appendActivityToActivityColumns(activity: nil)
                }
            }
        } else {
            // colonnes relatives au programme
            appendProgramToProgramColumns(program: program)

            // colonnes VIDES relatives à la séquence
            appendSequenceToSequenceColumns(sequence: nil)

            // colonnes VIDES relatives à l'activité
            appendActivityToActivityColumns(activity: nil)
        }

        // colonnes relatives au programme
        dataFrame.append(column: disciplineColumn)
        dataFrame.append(column: levelColumn)
        dataFrame.append(column: segpaColumn)
        dataFrame.append(column: durationColumn)
        dataFrame.append(column: durationWithMarginColumn)

        // colonnes relatives à la séquence
        dataFrame.append(column: seqNumColumn)
        dataFrame.append(column: seqNameColumn)
        dataFrame.append(column: seqDurationColumn)
        dataFrame.append(column: seqDurationWithMarginColumn)

        // colonnes relatives à l'activité
        dataFrame.append(column: actNumColumn)
        dataFrame.append(column: actNameColumn)
        dataFrame.append(column: actDurationColumn)
        dataFrame.append(column: actIsEvalSommativeColumn)
        dataFrame.append(column: actIsEvalFormativeColumn)
        dataFrame.append(column: actIsTpColumn)
        dataFrame.append(column: actIsProjectColumn)

        return dataFrame
    }

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportEleves() {
        var total = DataFrame()
        SchoolEntity.allSortedByLevelName()
            .forEach { school in
                school.classesSortedByLevelNumber
                    .forEach { classe in
                        let dataFrame = classeGroupsDataFrame(de: classe)
                        #if DEBUG
                            print(dataFrame)
                        #endif
                        if total.isEmpty {
                            total = dataFrame
                        } else {
                            total.append(rowsOf: dataFrame)
                        }
                    }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvEleveListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportGroups(de classe: ClasseEntity) {
        let groupsDataFrame = classeGroupsDataFrame(de: classe)

        let fileName = csvFileName(classe: classe)
        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: fileName)

        try? groupsDataFrame.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des élèves des groupes d'une classe
    static func classeGroupsDataFrame(de classe: ClasseEntity) -> DataFrame {
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
