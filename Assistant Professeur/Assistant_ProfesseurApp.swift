//
//  Assistant_ProfesseurApp.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import Files
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "Main"
)

@main
struct Assistant_ProfesseurApp: App {
    /// the managed object context for your Core Data container
    let coreDataManager = CoreDataManager.shared

    var body: some Scene {
        MainScene(coreDataManager: coreDataManager)
    }

    /// Vérifier l'existance du dossier `Documents`.
    /// Vérifier la compatibilité de version entre l'application et les documents utilisateurs
    ///
    /// Si l'application et les documents utilisateurs ne sont pas compatible alors
    /// importer les documents contenus dans le Bundle application.
    init() {
        #if DEBUG
            print(">> Assistant_ProfesseurApp.init() initialization has started")
        #endif
        // URLCache.shared.memoryCapacity = 100_000_000 // ~100 MB memory space

        // vérifier l'existance du dossier `Documents`
        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .error, "\(error.rawValue))")
            AppState.shared.initError = .failedToInitialize
            return
        }

        // vérifier la compatibilité de version entre l'application et les documents utilisateurs
        do {
            let documentsAreCompatibleWithAppVersion =
                try PersistenceManager
                    .checkCompatibilityWithAppVersion(of: documentsFolder)
            #if DEBUG
                print(">> Compatibilité de versions entre Appli / Dossier Document : \(documentsAreCompatibleWithAppVersion.frenchString)")
            #endif
            if !documentsAreCompatibleWithAppVersion {
                do {
                    // charger tous les documents de l'appli pour rétablir la compatibilité
                    try PersistenceManager()
                        .forcedImportAllFilesFromApp(fileExtensions: ["json", "jpg", "png", "pdf"])

                } catch {
                    AppState.shared.initError = .failedToLoadApplicationData
                }
            }
        } catch {
            let error = FileError.failedToCheckCompatibility
            customLog.log(level: .fault, "\(error.rawValue))")
            AppState.shared.initError = .failedToCheckCompatibility
        }
        #if DEBUG
            print(">> Assistant_ProfesseurApp.init() initialization has completed")
        #endif
    }
}
