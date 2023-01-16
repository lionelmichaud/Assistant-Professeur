//
//  importCSV.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 07/05/2022.
//

import Foundation
import TabularData

enum CsvImporterError: Error {
    case incompatibleColumnNames
}

struct CsvImporter {
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
    func importElevesFromPRONOTE(
        from data: Data,
        dans classe: ClasseEntity
    ) throws {
        let nameColumn = ColumnID("Élève", String.self)
        let sexeColumn = ColumnID("Sexe", String.self)

        let columnNames = [nameColumn.name, sexeColumn.name]

        let options = CSVReadingOptions(hasHeaderRow      : true,
                                        nilEncodings      : ["", "nil"],
                                        ignoresEmptyLines : true,
                                        delimiter         : ";")

        var dataFrame = try DataFrame(csvData : data,
                                      columns : columnNames,
                                      types   : [nameColumn.name : .string,
                                                 sexeColumn.name : .string],
                                      options : options)

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
                    EleveEntity.create(familyName: String(nom[0]),
                                       givenName: String(nom.last!),
                                       sex: (row["Sexe", String.self] == "male") ? .male : .female,
                                       dans: classe)
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
    func importElevesFromEcoleDirecte(
        from data: Data,
        dans classe: ClasseEntity
    ) throws {
        let nameColumn = ColumnID("Nom", String.self)
        let sexeColumn = ColumnID("Sexe", String.self)

        let columnNames = [nameColumn.name, sexeColumn.name]

        let options = CSVReadingOptions(hasHeaderRow      : true,
                                        nilEncodings      : ["", "nil"],
                                        ignoresEmptyLines : true,
                                        delimiter         : ";")

        var dataFrame = try DataFrame(csvData : data,
                                      columns : columnNames,
                                      types   : [nameColumn.name : .string,
                                                 sexeColumn.name : .string],
                                      options : options)

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
                    EleveEntity.create(familyName: String(nom[0]),
                                       givenName: String(nom.last!),
                                       sex: (row["Sexe", String.self] == "male") ? .male : .female,
                                       dans: classe)
                }
            }
    }
}
