//
//  Assistant_ProfesseurApp.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import Files
import os
import SwiftUI
import AppFoundation

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "Main"
)

@main
struct Assistant_ProfesseurApp: App {
    /// The managed object context for your Core Data container
    let coreDataManager = CoreDataManager.shared

    // object that you want to use throughout your scenes and that will be global to the App
    // @StateObject private var uiState = UIState()
    @State
    private var authentication = Authentication()

    @StateObject
    private var userContext = UserContext()

    var body: some Scene {
        MainScene(
            coreDataManager: coreDataManager,
            authentication: authentication,
            userContext: userContext
        )
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

        // Stopper les éventuelles Live Activity en cours
        #if canImport(ActivityKit)
//            Task {
//                await LiveActivityManager.shared.endAllRunningActivities()
//            }
        #endif

        Task {
            // Charger les séances du jour
            await TodaySeances.shared.loadTodaySeances()
        }

        // vérifier l'existance du dossier `Documents`
        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .error, "\(error.rawValue))")
            AppState.shared.initError = AppInitError.failedToInitialize
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
                        .forcedImportAllFilesFromApp(
                            fileExtensions: ["json", "jpg", "png", "pdf", "wave"]
                        )

                } catch {
                    AppState.shared.initError = AppInitError.failedToLoadApplicationData
                }
            }
        } catch {
            let error = FileError.failedToCheckCompatibility
            customLog.log(level: .fault, "\(error.rawValue))")
            AppState.shared.initError = AppInitError.failedToCheckCompatibility
        }
        #if DEBUG
            print(">> Assistant_ProfesseurApp.init() initialization has completed")
        #endif
    }
}
