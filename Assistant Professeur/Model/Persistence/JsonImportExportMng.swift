//
//  JsonImportExportMng.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/02/2023.
//

import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "JsonImportExportMng"
)

/// Export/Import vers/depuis des fichiers JSON
enum JsonImportExportMng {
    static let schoolsFileName = String(describing: SchoolEntity.self) + ".json"
    static let programsFileName = String(describing: ProgramEntity.self) + ".json"

    // MARK: - Export

    /// Exporter les données vers des fichiers au format JSON
    static func exportToJsonFiles() {
        exportSchoolsToJson()
        exportProgramsToJson()
    }

    /// Exporter les School et leurs descendants vers un fichier au format JSON
    private static func exportSchoolsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            SchoolEntity.all(),
            to: schoolsFileName
        )
    }

    /// Exporter les Program et leurs descendants vers un fichier au format JSON
    private static func exportProgramsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            ProgramEntity.all(),
            to: programsFileName
        )
    }

    // MARK: - Import

    /// Peupler la base de donnée à patir des données importées des fichiers  JSON sélectionnés.
    /// - Parameter filesUrl: URLs des fichiers sélectionnés
    static func importJsonData(
        result: Result<[URL], Error>,
        resetNavigationData: () -> Void
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
                alertMessage = "L'importation des fichiers a échouée!"
                alertIsPresented = true

            case let .success(filesUrl):
                /// Vider la base de données
                var failed = false
                resetNavigationData()
                DataBaseManager.clear(failed: &failed)

                guard !failed else {
                    alertTitle = "Échec"
                    alertMessage = "L'effacement complet de la base de donnée a échoué"
                    alertIsPresented = true
                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }

                filesUrl.forEach { fileUrl in
                    guard fileUrl.startAccessingSecurityScopedResource() else {
                        return
                    }

                    let urlFileNameWithExtension = fileUrl.lastPathComponent

                    /// Les Programmes doivent être importés avant les Schools
                    if urlFileNameWithExtension.contains(String(describing: SchoolEntity.self)) {
                        // Importer les données des Schools et de leurs descendants
                        importSchoolsFromJson(fileUrl: fileUrl)

                    } else if urlFileNameWithExtension.contains(String(describing: ProgramEntity.self)) {
                        // Importer les données des Programs et de leurs descendants
                        importProgramsFromJson(fileUrl: fileUrl)
                    }

                    fileUrl.stopAccessingSecurityScopedResource()
                }

                try? SchoolEntity.saveIfContextHasChanged()
        }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer les Schools depuis des fichiers au format JSON
    private static func importSchoolsFromJson(fileUrl: URL) {
        let schools = fileUrl.decode(
            [SchoolEntity].self,
            from: ""
        )
        #if DEBUG
            print(String(describing: schools))
        #endif
    }

    /// Importer les Programs depuis des fichiers au format JSON
    private static func importProgramsFromJson(fileUrl: URL) {
        let programs = fileUrl.decode(
            [ProgramEntity].self,
            from: ""
        )
        #if DEBUG
            print(String(describing: programs))
        #endif
    }
}
