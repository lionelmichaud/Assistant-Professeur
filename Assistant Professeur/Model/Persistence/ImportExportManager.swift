//
//  Share.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/05/2022.
//

import SwiftUI
import os
import HelpersView
import Files

private let customLog = Logger(subsystem : "com.michaud.lionel.Cahier-du-Professeur",
                               category  : "ImportExportManager")

struct ImportExportManager {

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
//
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

    /// Fournit la litse des URL des fichiers contenus dans le dossier Document
    /// et qui contiennent `fileNames`dans leur nom de fichier.
    /// - Parameter fileNames: critère de collecte (par exemple ".json")
    static func documentsURLsToShare(fileNames : [String]? = nil) -> [URL] {
        do {
            return try PersistenceManager().collectedURLs(fileNames: fileNames)
        } catch {
            customLog.log(level: .info, "Echec de la recherche des URL des fichiers contenus dans le dossier Document \(error)")
            return [ ]
        }
    }

    static func importTrombinesImages(filesUrl: [URL]) throws {
        try filesUrl.forEach { fileUrl in
            let data = try Data(contentsOf: fileUrl)
            guard let image = UIImage(data: data) else { return }
            let urlFileNameWithExtension = fileUrl.lastPathComponent
            let eleves = EleveEntity.all()
            eleves.forEach { eleve in
                let imageFileName = eleve.imageFileName
                if imageFileName == urlFileNameWithExtension {
                    eleve.viewUIImageTrombine = image
                }
            }
        }
    }

    /// Importer les fichiers dont les URL sont `filesUrl`vers le dossier Document.
    /// Exécute l'`action` pour chaque fichier importé.
    /// - Parameters:
    ///   - filesUrl: URLs des fichiers à importer
    ///   - action: Action à exécuter pour chaque fichier importé
    ///   - importIfAlreadyExist: Si true alors importe le fichier même s'il existe déjà dans le dossier Document
    /// - throws: `FileError.failedToReadFile` si un des fichiers ne peut pas être trouvé.
    /// `FileError.failedToCopyFile` si un des fichiers ne peut pas être copier.
    static func importURLsToDocumentsFolder(filesUrl             : [URL],
                                            importIfAlreadyExist : Bool,
                                            action               : ((File) -> Void)? = nil) throws {
        guard let documentsFolder = Folder.documents else { return }

        try filesUrl.forEach { fileUrl in
            guard fileUrl.startAccessingSecurityScopedResource() else { return }

            var file: File

            /// Trouver le fichier correspondant à l'URL
            do {
                file = try File(path: fileUrl.path)
            } catch {
                fileUrl.stopAccessingSecurityScopedResource()
                let errorStr = String(describing: (error as! LocationError))
                customLog.log(level: .error, "\(errorStr)")
                throw FileError.failedToReadFile
            }

            /// Copier le fichier trouvé vers le dossier Document
            do {
                if importIfAlreadyExist || !documentsFolder.contains(file) {
                    try file.copy(to: documentsFolder)
                }
                if let action {
                    action(file)
                }
            } catch {
                fileUrl.stopAccessingSecurityScopedResource()
                let errorStr = String(describing: (error as! LocationError))
                customLog.log(level: .error, "\(errorStr)")
                throw FileError.failedToCopyFile
            }

            fileUrl.stopAccessingSecurityScopedResource()
        }
    }
}
