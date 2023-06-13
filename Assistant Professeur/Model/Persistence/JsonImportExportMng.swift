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
    static let ownerFileName = String(describing: OwnerEntity.self) + ".json"
    static let schoolsFileName = String(describing: SchoolEntity.self) + ".json"
    static let programsFileName = String(describing: ProgramEntity.self) + ".json"
    static let wCompetenciesFileName = String(describing: WCompChapterEntity.self) + ".json"
    static let dCompetenciesFileName = String(describing: DThemeEntity.self) + ".json"

    // MARK: - Export

    /// Exporter les données du Model vers des fichiers au format JSON.
    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités.
    ///
    /// Les classe d'objet tête de graphe sont exportées chacune dans un fichier qui lui est propre.
    /// - Les fichiers JSON sont enregistrés dans le dossier `cache`.
    /// - Les fichiers PDF, JPEG, PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers **annexes** exportés.
    static func exportToJsonFiles() -> [String] {
        // Exporter l'entité unique **OwnerEntity** vers un fichier au format JSON.
        exportOwnerToJson()
        // Exporter toutes les entités **SchoolEntity** et leurs descendants vers un fichier au format JSON.
        exportSchoolsToJson()
        // Exporter toutes les entités **ProgramEntity** et leurs descendants vers un fichier au format JSON.
        exportProgramsToJson()
        // Exporter toutes les entités **WCompChapterEntity** et leurs descendants vers un fichier au format JSON.
        exportWorkedCompetenciesToJson()
        // Exporter toutes les entités **DThemeEntity** et leurs descendants vers un fichier au format JSON.
        exportDisciplineThemesToJson()

        // Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités.
        return exportedAnnexeFiles()
    }

    /// Exporter l'entité unique **OwnerEntity** vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportOwnerToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            OwnerEntity.all(),
            to: ownerFileName
        )
    }

    /// Exporter toutes les entités **SchoolEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportSchoolsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            SchoolEntity.all(),
            to: schoolsFileName
        )
    }

    /// Exporter toutes les entités **ProgramEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportProgramsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            ProgramEntity.all(),
            to: programsFileName
        )
    }

    /// Exporter toutes les entités **WCompChapterEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportWorkedCompetenciesToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            WCompChapterEntity.all(),
            to: wCompetenciesFileName
        )
    }

    /// Exporter toutes les entités **DThemeEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportDisciplineThemesToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            DThemeEntity.all(),
            to: dCompetenciesFileName
        )
    }

    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des entités.
    ///
    /// Les fichiers PDF, JPEG, PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
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
    ///
    /// Les fichiers PDF sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
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
    ///
    /// Les fichiers PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
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
    ///
    /// Les fichiers Photos sont enregistrés dans le dossier `cache` au format PNG.
    /// - Returns: La liste des noms de fichiers exportés.
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

                /// RECHERCHER LES FICHIERS REQUIS

                /// Rechercher le fichier contenant les données du Owner du Modèle
                guard let ownerJsonFile = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == ownerFileName
                }) else {
                    alertTitle = "Échec"
                    alertMessage = "Le fichier **\(ownerFileName)** n'a pas été trouvé"
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
                /// Rechercher le fichier contenant la branche des Compétences Socle du Modèle
                guard let wCompetenciesJsonFile = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == wCompetenciesFileName
                }) else {
                    alertTitle = "Échec"
                    alertMessage = "Le fichier **\(wCompetenciesFileName)** n'a pas été trouvé"
                    alertIsPresented = true
                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                /// Rechercher le fichier contenant la branche des Compétences Disciplinaires du Modèle
                guard let dCompetenciesJsonFile = filesUrl.first(where: { fileUrl in
                    fileUrl.lastPathComponent == dCompetenciesFileName
                }) else {
                    alertTitle = "Échec"
                    alertMessage = "Le fichier **\(dCompetenciesFileName)** n'a pas été trouvé"
                    alertIsPresented = true
                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }

                /// IMPORTER LES FICHIERS REQUIS

                // Importer les données contenant les données du Owner du Modèle
                guard ownerJsonFile.startAccessingSecurityScopedResource() else {
                    alertTitle = "Échec"
                    alertMessage = "L'importation du fichier **\(ownerFileName)** a échouée!"
                    alertIsPresented = true

                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                importOwnerFromJson(fileUrl: ownerJsonFile)
                ownerJsonFile.stopAccessingSecurityScopedResource()

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
                // WARNING: Il faut que les Programs soient chargées AVANT
                // les Compétences Disciplinaires pour que les entités
                // des Compétences Disciplinaires puissent
                // établir la connection avec les entités des Programs
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

                // Importer les données des Compétences Socle et de leurs descendants
                // WARNING: Il faut que les Compétences Socle soient chargées AVANT
                // les Compétences Disciplinaires pour que les entités
                // des Compétences Disciplinaires puissent
                // établir la connection avec les entités des Compétences Socle
                guard wCompetenciesJsonFile.startAccessingSecurityScopedResource() else {
                    alertTitle = "Échec"
                    alertMessage = "L'importation du fichier **\(wCompetenciesFileName)** a échouée!"
                    alertIsPresented = true

                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                importWCompetenciesFromJson(fileUrl: wCompetenciesJsonFile)
                wCompetenciesJsonFile.stopAccessingSecurityScopedResource()

                // Importer les données des Compétences Disciplinaires et de leurs descendants
                guard dCompetenciesJsonFile.startAccessingSecurityScopedResource() else {
                    alertTitle = "Échec"
                    alertMessage = "L'importation du fichier **\(dCompetenciesFileName)** a échouée!"
                    alertIsPresented = true

                    return (
                        alertTitle: alertTitle,
                        alertMessage: alertMessage,
                        alertIsPresented: alertIsPresented
                    )
                }
                importDCompetenciesFromJson(fileUrl: dCompetenciesJsonFile)
                dCompetenciesJsonFile.stopAccessingSecurityScopedResource()

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

    // MARK: - Importation des fichiers JSON

    /// Importer les données contenant les données du Owner du Modèle depuis un fichier au format JSON
    private static func importOwnerFromJson(fileUrl: URL) {
        let owner = fileUrl.decode(
            OwnerEntity.self,
            from: ""
        )
        #if DEBUG
            print(String(describing: owner))
        #endif
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

    /// Importer les Compétences Scocle depuis des fichiers au format JSON
    private static func importWCompetenciesFromJson(fileUrl: URL) {
        let wCompChapters = fileUrl.decode(
            [WCompChapterEntity].self,
            from: ""
        )
        #if DEBUG
            print(String(describing: wCompChapters))
        #endif
    }

    /// Importer les Compétences Disciplinaires depuis des fichiers au format JSON
    private static func importDCompetenciesFromJson(fileUrl: URL) {
        let dCompThemes = fileUrl.decode(
            [DThemeEntity].self,
            from: ""
        )
        #if DEBUG
            print(String(describing: dCompThemes))
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
