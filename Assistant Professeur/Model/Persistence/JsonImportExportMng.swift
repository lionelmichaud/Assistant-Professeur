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

                /// Rechercher le fichier contenant la branche des Programmes du Modèle
                guard let programJsonFile = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == programsFileName
                }) else {
                    alertTitle = "Échec"
                    alertMessage = "Le fichier **\(programsFileName)** n'a pas été trouvé"
                    alertIsPresented = true
                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                /// Rechercher le fichier contenant la branche des Schools du Modèle
                guard let schoolJsonFile = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == schoolsFileName
                }) else {
                    alertTitle = "Échec"
                    alertMessage = "Le fichier **\(schoolsFileName)** n'a pas été trouvé"
                    alertIsPresented = true
                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }

                // Importer les données des Programs et de leurs descendants
                guard programJsonFile.startAccessingSecurityScopedResource() else {
                    alertTitle = "Échec"
                    alertMessage = "L'importation du fichier **\(programsFileName)** a échouée!"
                    alertIsPresented = true

                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                importProgramsFromJson(fileUrl: programJsonFile)
                programJsonFile.stopAccessingSecurityScopedResource()

                // Importer les données des Schools et de leurs descendants
                guard schoolJsonFile.startAccessingSecurityScopedResource() else {
                    alertTitle = "Échec"
                    alertMessage = "L'importation du fichier **\(schoolsFileName)** a échouée!"
                    alertIsPresented = true

                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                importSchoolsFromJson(fileUrl: schoolJsonFile)
                schoolJsonFile.stopAccessingSecurityScopedResource()

                // Importer les fichiers annexes (PDF, JPEG, PNG...)
                (
                    alertTitle,
                    alertMessage,
                    alertIsPresented
                ) = importAnnexeFiles(filesUrl: filesUrl)

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

    private static func importAnnexeFiles(filesUrl: [URL])
        -> (
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false

        // Importer les annexes PDF des Documnts associés aux Schools
        let docFilesUrl = filesUrl.compactMap { fileUrl in
            if fileUrl.lastPathComponent.hasPrefix("doc_") {
                return fileUrl
            } else {
                return nil
            }
        }
        (
            alertTitle,
            alertMessage,
            alertIsPresented
        ) = importDocFiles(filesUrl: docFilesUrl)

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer les annexes PDF des Documnts associés aux Schools
    private static func importDocFiles(filesUrl: [URL])
        -> (
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false

        DocumentEntity
            .all()
            .forEach { doc in
                guard let uuidString = doc.id?.uuidString else {
                    return
                }
                let fileName = "doc_" + uuidString + ".pdf"
                if let fileUrlFound = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == fileName
                }) {
                    do {
                        let data = try Data(contentsOf: fileUrlFound)
                        doc.setPdfData(to: data)
                    } catch {
                        customLog.log(
                            level: .error,
                            "Error creating PDF data from file: \(error.localizedDescription)"
                        )
                        alertTitle = "Échec"
                        alertMessage = "L'importation du fichier \(error.localizedDescription) a échouée"
                        alertIsPresented = true
                    }
                }
            }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }
}
