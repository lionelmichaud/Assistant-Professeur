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
enum JsonImportExportMng { // swiftlint:disable:this type_body_length
    static let schoolsFileName = String(describing: SchoolEntity.self) + ".json"
    static let programsFileName = String(describing: ProgramEntity.self) + ".json"

    // MARK: - Export

    /// Exporter les données du Model vers des fichiers au format JSON.
    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités.
    static func exportToJsonFiles() -> [String] {
        exportSchoolsToJson()
        exportProgramsToJson()

        // Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités
        return exportedAnnexeFiles()
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

    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités
    private static func exportedAnnexeFiles() -> [String] {
        var exportedFileNames = [String]()

        // Exporter les annexes PDF des Documents associés aux Schools
        exportedFileNames += exportedDocFiles()

        // Exporter les annexes PNG des plans de salle Rooms associés aux Schools
        exportedFileNames += exportedRoomFiles()

        // Exporter les annexes PNG des plans de salle Rooms associés aux Schools
        exportedFileNames += exportedTrombineFiles()

        return exportedFileNames
    }

    /// Exporter les annexes PDF des Documents associés aux Schools
    private static func exportedDocFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        DocumentEntity
            .all()
            .forEach { doc in
                guard let fileName = doc.uuidFileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try doc.pdfData?.write(to: fileUrl)
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

    /// Exporter les annexes PNG des plans de salle Rooms associés aux Schools
    private static func exportedRoomFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        RoomEntity
            .all()
            .forEach { room in
                guard let fileName = room.fileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try ImageImportExportMng
                        .writeNativeImage(
                            image: room.viewNativeImage,
                            to: fileUrl
                        )
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

    /// Exporter les  Photos des Elèves
    private static func exportedTrombineFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        EleveEntity
            .all()
            .forEach { eleve in
                guard let fileName = eleve.fileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try ImageImportExportMng
                        .writeNativeImage(
                            image: eleve.viewNativeImageTrombine,
                            to: fileUrl
                        )
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

    // MARK: - Import

    /// Peupler la base de donnée à patir des données importées des fichiers  JSON sélectionnés.
    /// - Parameter filesUrl: URLs des fichiers sélectionnés
    static func importJsonData(
        result: Result<[URL], Error>,
        resetNavigationData: () -> Void
    ) -> (
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

                // Importer les données des Schools et de leurs descendants
                // WARNING: Il faut que les Schools soient chargées AVANT
                // les Programmes pour que les entités des Programmes puissent
                // établir la connection avec les entités des Schools
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

    /// Importer les fichiers annexes (PDF, JPEG, PNG...) des autres entités
    private static func importAnnexeFiles(filesUrl: [URL])
        -> (
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false

        // Importer les annexes PDF des Documents associés aux Schools
        let docFilesUrl = filesUrl.compactMap { fileUrl in
            if fileUrl.lastPathComponent.hasPrefix("doc_") {
                return fileUrl
            } else {
                return nil
            }
        }
        do {
            try importDocFiles(filesUrl: docFilesUrl)
        } catch {
            customLog.log(
                level: .error,
                "Error reading PDF data from file: \(error.localizedDescription)"
            )
            alertTitle = "Échec"
            alertMessage = "L'importation du fichier \(error.localizedDescription) a échouée"
            alertIsPresented = true
        }

        // Importer les annexes PNG des Rooms associés aux Schools
        let roomFilesUrl = filesUrl.compactMap { fileUrl in
            if fileUrl.lastPathComponent.hasPrefix("plan_") {
                return fileUrl
            } else {
                return nil
            }
        }
        do {
            try importRoomFiles(filesUrl: roomFilesUrl)
        } catch {
            customLog.log(
                level: .error,
                "Error reading PNG data from file: \(error.localizedDescription)"
            )
            alertTitle = "Échec"
            alertMessage = "L'importation du fichier \(error.localizedDescription) a échouée"
            alertIsPresented = true
        }

        // Importer les photos PNG des Elèves
        let photoFilesUrl = filesUrl.compactMap { fileUrl in
            if fileUrl.lastPathComponent.hasPrefix("photo_") {
                return fileUrl
            } else {
                return nil
            }
        }
        do {
            try importPhotoFiles(filesUrl: photoFilesUrl)
        } catch {
            customLog.log(
                level: .error,
                "Error reading PNG data from file: \(error.localizedDescription)"
            )
            alertTitle = "Échec"
            alertMessage = "L'importation du fichier \(error.localizedDescription) a échouée"
            alertIsPresented = true
        }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer les annexes PDF des Documents associés aux Schools
    private static func importDocFiles(filesUrl: [URL]) throws {
        try DocumentEntity
            .all()
            .forEach { doc in
                guard let fileName = doc.uuidFileName else {
                    return
                }

                if let fileUrlFound = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == fileName
                }) {
                    do {
                        let data = try Data(contentsOf: fileUrlFound)
                        doc.setPdfData(to: data)
                    } catch {
                        throw error
                    }
                }
            }
    }

    /// Importer les annexes PNG des Rooms associés aux Schools
    private static func importRoomFiles(filesUrl: [URL]) throws {
        try RoomEntity
            .all()
            .forEach { room in
                guard let fileName = room.fileName else {
                    return
                }

                if let fileUrlFound = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == fileName
                }) {
                    do {
                        if let image = try ImageImportExportMng
                            .loadNativeImage(from: fileUrlFound) {
                            room.viewNativeImage = image
                        } else {
                            customLog.log(
                                level: .fault,
                                "La convertion de certains plan de salle a échouée"
                            )
                            throw FileError.failedToReadFile
                        }
                    } catch {
                        throw error
                    }
                }
            }
    }

    /// Importer les photos PNG des Elèves
    private static func importPhotoFiles(filesUrl: [URL]) throws {
        try EleveEntity
            .all()
            .forEach { eleve in
                guard let fileName = eleve.fileName else {
                    return
                }

                if let fileUrlFound = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == fileName
                }) {
                    do {
                        if let image = try ImageImportExportMng
                            .loadNativeImage(from: fileUrlFound) {
                            eleve.viewNativeImageTrombine = image
                        } else {
                            customLog.log(
                                level: .fault,
                                "La convertion de certains plan de salle a échouée"
                            )
                            throw FileError.failedToReadFile
                        }
                    } catch {
                        throw error
                    }
                }
            }
    }
}
