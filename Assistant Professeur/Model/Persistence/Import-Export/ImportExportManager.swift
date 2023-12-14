//
//  Share.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/05/2022.
//

import Files
import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ImportExportManager"
)

enum ImportExportManager {
    // MARK: - Autres Export/Import vers/depuis le dossier Caches

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

    // MARK: - Autres Export/Import vers/depuis le dossier Document

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

    /// Ajouter un document à l'établissement pour chaque fichier importé.
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    static func importUserSelectedFiles(
        result: Result<[URL], Error>,
        creatDocument: (Data, String) -> Void
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
                    level: .error,
                    "Error selecting PDF file: \(error.localizedDescription)"
                )
                return (
                    alertTitle: "Échec de l'importation",
                    alertMessage: "L'importation des fichiers a échouée",
                    alertIsPresented: true
                )

            case let .success(filesUrl):
                guard filesUrl.isNotEmpty else {
                    customLog.log(
                        level: .error,
                        "Error creating PDF data from file"
                    )
                    return (
                        alertTitle: "Échec de l'importation",
                        alertMessage: "L'importation des fichiers a échouée",
                        alertIsPresented: true
                    )
                }

                // créer le document et l'associer à l'établissement
                filesUrl.forEach { url in
                    do {
                        let data = try Data(contentsOf: url)
                        let fileName = url.lastPathComponent
                        creatDocument(data, fileName)

                    } catch {
                        customLog.log(
                            level: .error,
                            "Error creating PDF data from file: \(error.localizedDescription)"
                        )
                        alertTitle = "Échec de l'importation"
                        alertMessage = "L'importation du fichier \(error.localizedDescription) a échouée"
                        alertIsPresented = true
                    }
                }

                return (
                    alertTitle: alertTitle,
                    alertMessage: alertMessage,
                    alertIsPresented: alertIsPresented
                )
        }
    }
}
