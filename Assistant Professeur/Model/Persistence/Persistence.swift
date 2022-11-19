//
//  Persistence.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 09/05/2022.
//

import Foundation
import os
import Files
import FileAndFolder
import AppFoundation

private let customLog = Logger(subsystem : "com.michaud.lionel.Cahier-du-Professeur",
                               category  : "PersistenceManager")

public enum FileError: String, Error {
    case failedToResolveAppBundle          = "Impossible de trouver le répertoire 'App Bundle'"
    case failedToResolveCsvFolder          = "Impossible de trouver le répertoire 'CSV'"
    case failedToResolveDocuments          = "Impossible de trouver le répertoire 'Documents' de l'utilisateur"
    case failedToResolveLibrary            = "Impossible de trouver le répertoire 'Library' de l'utilisateur"
    case directoryToDuplicateDoesNotExist  = "Le répertoire à dupliquer n'est pas défini"
    case failedToReadFile                  = "Echec de lecture du fichier"
    case failedToCopyFile                  = "Echec de la copie du fichier"
    case failedToDeleteFile                = "Echec de la suppression du fichier"
    case failedToDuplicateFiles            = "Echec de la duplication des fichiers"
    case templatesDossierNotInitialized    = "Dossier 'templates' non initializé"
    case failedToImportTemplates           = "Echec de l'importation des templates depuis Bundle.Main vers 'Library'"
    case failedToCheckCompatibility        = "Impossible de vérifier la compatibilité avec la version de l'application"
}

public enum BddErrod: String, Error {
    case failedToRepair = "Echec de réparation de la base de données"
}

// MARK: - Extension de Folder

public extension Folder {
    // The current Application folder
    static var application: Folder? {
        guard let resourcePath = Bundle.main.resourcePath else {
            return nil
        }
        return try? Folder(path: resourcePath)
    }
}

// MARK: - Gestion de la persistence

public struct PersistenceManager {

    // MARK: - Methods

    /// Fournit la litse des URL des fichiers contenus dans le répertoir Document
    /// et qui contiennent `fileNames`dans leur nom de fichier.
    /// - Parameter fileNames: critère de collecte (par exemple ".json")
    public func collectedURLs(fileNames : [String]?  = nil) throws -> [URL] {
        // vérifier l'existence du Folder Document
        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .fault, "\(error.rawValue))")
            throw error
        }

        var urls = [URL]()
        // collecte des URL des fichiers contenus dans le dossier Documents
        documentsFolder.files.forEach { file in
            if let fileNames {
                fileNames.forEach { fileName in
                    if file.name.contains(fileName) {
                        urls.append(file.url)
                    }
                }
            } else {
                urls.append(file.url)
            }
        }

        return urls
    }

    /// Importer les fichiers dont le nom contient `fileExt`
    /// depuis le `Bundle Main` de l'Application
    /// vers le répertoire `Documents` même si'ils y sont déjà présents.
    public func forcedImportAllFilesFromApp(fileExtensions: [String]) throws {
        guard let originFolder = Folder.application else {
            let error = FileError.failedToResolveAppBundle
            customLog.log(level: .fault, "\(error.rawValue))")
            throw error
        }

        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .fault, "\(error.rawValue))")
            throw error
        }

        do {
            try fileExtensions.forEach { fileExtension in
                try duplicateAllFiles(from        : originFolder,
                                      to          : documentsFolder,
                                      fileExt     : fileExtension,
                                      forceUpdate : true)
            }
        } catch {
            let error = FileError.failedToImportTemplates
            customLog.log(level: .fault, "\(error.rawValue))")
            throw error
        }
    }

    /// Dupliquer tous les fichiers `JSON` présents dans le répertoire `originFolder` vers le répertoire `targetFolder`
    ///
    /// Si `forceUpdate` = false : ne copie le fichier que s'il n'existe pas déjà dans `targetFolder`
    ///
    /// - Parameters:
    ///   - originFolder: répertoire source
    ///   - targetFolder: répertoire destination
    ///   - forceUpdate: si false alors ne copie pas les fichiers s'ils sont déjà présents dans le répertoire `targetFolder`
    /// - Throws:`FileError.failedToDuplicateFiles`
    fileprivate func duplicateAllFiles(from originFolder : Folder,
                                       to targetFolder   : Folder,
                                       fileExt           : String,
                                       forceUpdate       : Bool = false) throws {
        do {
            try originFolder.files.forEach { originFile in
                if let ext = originFile.extension, ext == fileExt {
                    // recopier le fichier s'il n'est pas présent dans le directory targetFolder
                    if !targetFolder.containsFile(named: originFile.name) || forceUpdate {
                        if originFile.name == AppVersion.fileName {
                            // enregister la version de l'app dans le directory targetFolder
                            try targetFolder.saveAsJSON(AppVersion.shared,
                                                        to                   : originFile.name,
                                                        dateEncodingStrategy : .iso8601,
                                                        keyEncodingStrategy  : .useDefaultKeys)
                        } else {
                            do {
                                let targetFile = try targetFolder.file(named: originFile.name)
                                try targetFile.delete()
                            } catch {
                            }
                            try originFile.copy(to: targetFolder)
                        }
                    }
                }
            }
        } catch {
            customLog.log(level: .fault,
                          "\(FileError.failedToDuplicateFiles.rawValue) de \(originFolder.name) vers \(targetFolder.name)")
            throw FileError.failedToDuplicateFiles
        }
    }

    // MARK: - Type Methods

    /// Vérifier la compatibilité de version entre l'App et le directory `targetFolder`
    /// - Note: Les versions sont compatibles si elles portent la même version majeure
    public static func checkCompatibilityWithAppVersion(of targetFolder: Folder) throws -> Bool {
        if let appMajorVersion = AppVersion.shared.version.major {
            do {
                let targetMajorVersion = try targetFolder.loadFromJSON(
                    AppVersion.self,
                    from                 : AppVersion.fileName,
                    dateDecodingStrategy : .iso8601,
                    keyDecodingStrategy  : .useDefaultKeys).version.major
                return (appMajorVersion == targetMajorVersion)

            } catch {
                // le chargement du fichier AppVersion.json du dossier s'est mal passé
                if let theError = (error as? LocationError) {
                    // à cause d'un pb de gestion de fichier
                    switch theError.reason {
                        case .missing:
                            // le fichier AppVersion.json en manquant dans le dossier
                            return false
                        default:
                            // à cause d'une autre raison
                            customLog.log(level: .fault,
                                          "\(FileError.failedToCheckCompatibility.rawValue) de '\(AppVersion.fileName)'")
                            throw FileError.failedToCheckCompatibility
                    }
                } else {
                    // à cause d'une autre raison
                    customLog.log(level: .fault,
                                  "\(FileError.failedToCheckCompatibility.rawValue) de '\(AppVersion.fileName)'")
                    throw FileError.failedToCheckCompatibility
                }
            }

        } else {
            customLog.log(level: .fault,
                          "\(FileError.failedToCheckCompatibility.rawValue) de '\(AppVersion.fileName)'")
            throw FileError.failedToCheckCompatibility
        }
    }

    /// Suprimer el fichier désigné par `url`.
    /// - Parameter url: URL du fichier à supprimer
    func deleteFile(withURL url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else { return }

        var file: File

        /// Trouver le fichier correspondant à l'URL
        do {
            file = try File(path: url.path)

            /// Supprimer le fichier trouvé
            do {
                try file.delete()
            } catch {
                url.stopAccessingSecurityScopedResource()
                let errorStr = String(describing: (error as! LocationError))
                customLog.log(level: .fault, "\(errorStr)")
                throw FileError.failedToReadFile
            }

        } catch {
            url.stopAccessingSecurityScopedResource()
            let errorStr = String(describing: (error as! LocationError))
            customLog.log(level: .fault, "\(errorStr)")
            throw FileError.failedToDeleteFile
        }
    }
}
