//
//  Share.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/05/2022.
//

import Files
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ImportExportManager"
)

enum ImportExportManager {
//    static func share(items      : [Any],
//                      activities : [UIActivity]?  = nil,
//                      animated   : Bool           = true,
//                      fromX      : Double?        = nil,
//                      fromY      : Double?        = nil) {
//        let activityView = UIActivityViewController(activityItems: items,
//                                                    applicationActivities: activities)
//        UIApplication.shared.windows.first?.rootViewController?.present(activityView,
//                                                                        animated   : animated,
//                                                                        completion : nil)
//
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            activityView.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
//            activityView.popoverPresentationController?.sourceRect = CGRect(
//                x: (fromX == nil) ? UIScreen.main.bounds.width / 2.1 : fromX!,
//                y: (fromY == nil) ? UIScreen.main.bounds.height / 2.3 : fromY!,
//                width: 32,
//                height: 32)
//        }
//    }

//    /// Partager les fichiers contenus dans le dossier actif de `dataStore`
//    /// et qui contiennent l'une des Strings de `fileNames`
//    /// ou bien tous les fichiers si `fileNames` = `nil`
//    /// - Parameters:
//    ///   - dataStore: dataStore de l'application
//    ///   - fileNames: permet d'identifier les fichiers à partager (par exemple .json)
//    ///   - geometry: gemetry de la View qui appèle la fonction
//    static func shareFiles(fileNames : [String]? = nil,
//                           alertItem : inout AlertItem?,
//                           geometry  : GeometryProxy) {
//        var urls: [URL] = []
//
//        do {
//            urls = try PersistenceManager().collectedURLs(fileNames: fileNames)
//        } catch {
//            alertItem = AlertItem(title         : Text("Echec de l'exportation: dossier Documents introuvable !"),
//                                  dismissButton : .default(Text("OK")))
//        }
//
//        // partage des fichiers collectés
//        if urls.isNotEmpty {
//            share(items: urls,
//                  fromX: Double(geometry.frame(in: .global).maxX-32),
//                  fromY: 24.0)
//        }
//    }

    static let schoolsFileName = String(describing: SchoolEntity.self) + ".json"
    static let programsFileName = String(describing: ProgramEntity.self) + ".json"

    /// Fournit la litse des URL des fichiers contenus dans le dossier Document
    /// et qui contiennent `fileNames`dans leur nom de fichier.
    /// - Parameter fileNames: critère de collecte (par exemple ".json")
    static func documentsURLsToShare(fileNames: [String]? = nil) -> [URL] {
        // vérifier l'existence du Folder Document
        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .fault, "\(error.rawValue))")
            fatalError()
        }

        let foundURLs = PersistenceManager()
            .collectedURLs(
                fromFolder: documentsFolder,
                fileNames: fileNames
            )
        if foundURLs.isEmpty {
            customLog.log(
                level: .info,
                "Echec de la recherche des URL des fichiers contenus dans le dossier \(documentsFolder.name)"
            )
        }
        return []
    }

    /// Fournit la litse des URL des fichiers contenus dans le dossier Caches
    /// et qui contiennent `fileNames`dans leur nom de fichier.
    /// - Parameter fileNames: critère de collecte (par exemple ".json")
    static func cachesURLsToShare(fileNames: [String]? = nil) -> [URL] {
        // vérifier l'existence du Folder Caches
        guard let cachesFolder = Folder.caches else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .fault, "\(error.rawValue))")
            fatalError()
        }

        let foundURLs = PersistenceManager()
            .collectedURLs(
                fromFolder: cachesFolder,
                fileNames: fileNames
            )
        if foundURLs.isEmpty {
            customLog.log(
                level: .info,
                "Echec de la recherche des URL des fichiers contenus dans le dossier \(cachesFolder.name)"
            )
        }
        return foundURLs
    }

    // MARK: - Export/Import vers/depuis des fichiers CSV

    static func exportGroupsToCSV(deClasse _: ClasseEntity) {
        // TODO: - Exporter les groupes au format CSV
    }

    // MARK: - Export/Import vers/depuis des fichiers JSON

    /// Exporter les School et leurs descendants vers un fichier au format JSON
    static func exportSchoolsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            SchoolEntity.all(),
            to: schoolsFileName
        )
    }

    /// Exporter les Program et leurs descendants vers un fichier au format JSON
    static func exportProgramsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            ProgramEntity.all(),
            to: programsFileName
        )
    }

    /// Exporter les données vers des fichiers au format JSON
    static func exportToJsonFiles() {
        exportSchoolsToJson()
        exportProgramsToJson()
    }

    /// Importer les Schools depuis des fichiers au format JSON
    static func importSchoolsFromJson(fileUrl: URL) {
        let schools = fileUrl.decode(
            [SchoolEntity].self,
            from: ""
        )
        print(String(describing: schools))
    }

    /// Importer les Programs depuis des fichiers au format JSON
    static func importProgramsFromJson(fileUrl: URL) {
        let programs = fileUrl.decode(
            [ProgramEntity].self,
            from: ""
        )
        print(String(describing: programs))
    }

    /// Peupler la base de donnée à patir des données importées des fichiers  JSON sélectionnés.
    /// - Parameter filesUrl: URLs des fichiers sélectionnés
    static func importJsonData(result: Result<[URL], Error>,
                               resetNavigationData: () -> Void)
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

                    if urlFileNameWithExtension.contains(String(describing: SchoolEntity.self)) {
                        // Importer les données des Schools et de leurs descendants
                        importSchoolsFromJson(fileUrl: fileUrl)

                    } else if urlFileNameWithExtension.contains(String(describing: ProgramEntity.self)) {
                        // Importer les données des Programs et de leurs descendants
                        importProgramsFromJson(fileUrl: fileUrl)
                    }

                    fileUrl.stopAccessingSecurityScopedResource()
                }

                DataBaseManager.rebuildConnections()
                try? SchoolEntity.saveIfContextHasChanged()
        }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    // MARK: - Export/Import vers/depuis des fichiers Image

    /// Loads image data from a `fileUrl`  and converts it as UIImage.
    /// - Parameter fileUrl: fichier image
    /// - Returns: An initialized UIImage object, or nil if the method could not initialize the image from the loaded data.
    /// - Throws: si le contenu du fichier est ilisible
    private static func loadUIImage(from fileUrl: URL) throws -> UIImage? {
        guard fileUrl.startAccessingSecurityScopedResource() else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            fileUrl.stopAccessingSecurityScopedResource()
            return UIImage(data: data)
        } catch {
            fileUrl.stopAccessingSecurityScopedResource()
            throw error
        }
    }

    /// Importer un fichier image dans un format convertible en UIImage
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    /// - Returns: An initialized UIImage object, or nil if the method could not initialize the image from the loaded data.
    static func importImage(result: Result<[URL], Error>)
        -> (
            image: UIImage?,
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false
        var loadedImage: UIImage?

        switch result {
            case let .failure(error):
                customLog.log(
                    level: .error,
                    "Error selecting file: \(error.localizedDescription)"
                )
                alertTitle = "Échec"
                alertMessage = "L'importation du fichier a échouée"
                alertIsPresented = true

            case let .success(filesUrl):
                if let theFileURL = filesUrl.first {
                    do {
                        if let image = try ImportExportManager.loadUIImage(from: theFileURL) {
                            loadedImage = image
                        } else {
                            customLog.log(
                                level: .error,
                                "Le contenu de l'image n'est pas lisible."
                            )
                            alertTitle = "Échec"
                            alertMessage = "Le contenu de l'image n'est pas lisible."
                            alertIsPresented = true
                        }

                    } catch {
                        customLog.log(
                            level: .error,
                            "L'importation du fichier a échouée."
                        )
                        alertTitle = "Échec"
                        alertMessage = "L'importation du fichier a échouée."
                        alertIsPresented = true
                    }
                }
        }

        return (
            image: loadedImage,
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer les fichiers image  pour le trombinoscope
    /// - Parameter filesUrl: URLs des fichiers sélectionnés
    static func importTrombinesImages(result: Result<[URL], Error>)
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
                alertIsPresented.toggle()

            case let .success(filesUrl):
                filesUrl.forEach { fileUrl in
                    do {
                        if let image = try ImportExportManager.loadUIImage(from: fileUrl) {
                            let urlFileNameWithExtension = fileUrl.lastPathComponent
                            let eleves = EleveEntity.all()

                            eleves.forEach { eleve in
                                let imageFileName = eleve.imageFileName
                                if imageFileName == urlFileNameWithExtension {
                                    eleve.viewUIImageTrombine = image
                                }
                            }
                        } else {
                            customLog.log(
                                level: .fault,
                                "La convertion de certains des fichiers trombines a échouée"
                            )
                            alertTitle = "Échec"
                            alertMessage = "L'importation de certains fichiers a échouée!"
                            alertIsPresented = true
                        }

                    } catch {
                        customLog.log(
                            level: .fault,
                            "L'importation des fichiers trombines a échouée: \(error.localizedDescription)"
                        )
                        alertTitle = "Échec"
                        alertMessage = "L'importation de certains fichiers a échouée!"
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

    // MARK: - Autres Export/Import vers/depuis le dossier Document

    /// Importer les fichiers dont les URL sont `filesUrl`vers le dossier Document.
    /// Exécute l'`action` pour chaque fichier importé.
    /// - Parameters:
    ///   - filesUrl: URLs des fichiers à importer
    ///   - action: Action à exécuter pour chaque fichier importé
    ///   - importIfAlreadyExist: Si true alors importe le fichier même s'il existe déjà dans le dossier Document
    /// - throws: `FileError.failedToReadFile` si un des fichiers ne peut pas être trouvé.
    /// `FileError.failedToCopyFile` si un des fichiers ne peut pas être copier.
    static func importURLsToDocumentsFolder(
        filesUrl: [URL],
        importIfAlreadyExist: Bool,
        action: ((File) -> Void)? = nil
    ) throws {
        guard let documentsFolder = Folder.documents else {
            return
        }

        try filesUrl.forEach { fileUrl in
            guard fileUrl.startAccessingSecurityScopedResource() else {
                return
            }

            var file: File

            // Trouver le fichier correspondant à l'URL
            do {
                file = try File(path: fileUrl.path)
            } catch {
                fileUrl.stopAccessingSecurityScopedResource()
                let errorStr = String(describing: error as! LocationError)
                customLog.log(level: .error, "\(errorStr)")
                throw FileError.failedToReadFile
            }

            // Copier le fichier trouvé vers le dossier Document
            do {
                if importIfAlreadyExist || !documentsFolder.contains(file) {
                    try file.copy(to: documentsFolder)
                }
                if let action {
                    action(file)
                }
            } catch {
                fileUrl.stopAccessingSecurityScopedResource()
                let errorStr = String(describing: error as! LocationError)
                customLog.log(level: .error, "\(errorStr)")
                throw FileError.failedToCopyFile
            }

            fileUrl.stopAccessingSecurityScopedResource()
        }
    }
}
