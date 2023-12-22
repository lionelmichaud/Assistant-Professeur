//
//  Assistant_ProfesseurApp.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import AppFoundation
import Files
import OSLog
import SwiftUI
import TipKit

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "Main"
)

@main
struct Assistant_ProfesseurApp: App {
    /// object that you want to use throughout your scenes and that will be global to the App
    /// @StateObject private var uiState = UIState()
    @State
    private var store = Store()

    @State
    private var authentication = Authentication()

    @State
    private var userContext = UserContext()

    var body: some Scene {
        MainScene()
            .environment(authentication)
            .environment(userContext)
            .environment(store)
    }

    /// Vérifier l'existance du dossier `Documents`.
    /// Vérifier la compatibilité de version entre l'application et les documents utilisateurs
    ///
    /// Si l'application et les documents utilisateurs ne sont pas compatible alors
    /// importer les documents contenus dans le Bundle application.
    init() {
        #if DEBUG
            customLog.info(">> Assistant_ProfesseurApp.init() initialization has started")

            // Optional configure tips for testing.
            self.setupTipsForTesting()
        #endif

        // Configure and load all tips in the app.
        try? Tips.configure()

        // Charger les séances du jour
        Task {
            await TodaySeances.shared.loadTodaySeances()
        }

        // vérifier l'existance du dossier `Documents`
        guard let documentsFolder = Folder.documents else {
            let error = FileError.failedToResolveDocuments
            customLog.log(level: .error, "\(error.rawValue))")
            AppState.shared.initError = AppInitError.failedToInitialize
            return
        }

        // Vérifier la compatibilité de version entre l'application et les documents utilisateurs.
        do {
            let documentsAreCompatibleWithAppVersion =
                try PersistenceManager
                    .checkCompatibilityWithAppVersion(of: documentsFolder)
            #if DEBUG
                customLog.info(">> Compatibilité de versions entre Appli / Contenu du dossier Document : \(documentsAreCompatibleWithAppVersion.frenchString)")
            #endif
            if !documentsAreCompatibleWithAppVersion {
                do {
                    // Copier tous les documents du Bundle de l'appli vers le dossier Document
                    // pour rétablir la compatibilité.
                    try PersistenceManager()
                        .forcedImportAllFilesFromApp(
                            fileExtensions: ["json", "jpg", "png", "pdf"]
                        )

                } catch {
                    let error = AppInitError.failedToLoadApplicationData
                    customLog.log(level: .error, "\(error.errorDescription ?? "forcedImportAllFilesFromApp"))")
                    AppState.shared.initError = error
                }
            }
        } catch {
            let error = FileError.failedToCheckCompatibility
            customLog.log(level: .error, "\(error.rawValue))")
            AppState.shared.initError = error
        }
        #if DEBUG
            customLog.info(">> Assistant_ProfesseurApp.init() initialization has completed")
        #endif
    }

    /// Various way to override tip eligibility for testing.
    /// Note: These must be called before `Tips.configure()`.
    private func setupTipsForTesting() {
        do {
            // Show all defined tips in the app.
            Tips.showAllTipsForTesting()

            // Show some tips, but not all.
            // try Tips.showTipsForTesting([tip1, tip2, tip3])

            // Hide all tips defined in the app.
            //Tips.hideAllTipsForTesting()

            // Purge all TipKit-related data.
            try Tips.resetDatastore()
        } catch {
            print(error)
        }
    }
}
