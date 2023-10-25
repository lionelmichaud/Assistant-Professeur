//
//  ContentView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import AppFoundation
import CloudKit
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ContentView"
)

struct ContentView: View {
    @SceneStorage("navigation")
    private var navigationData: Data?

    @StateObject
    private var navig = NavigationModel()

    @StateObject
    private var cloudKitVM = CloudKitViewModel()

    @State
    private var isInitAlertPresented = false

    @State
    private var isiCloudAlertPresented = false

    var body: some View {
        TabView(selection: navig.tabSelection()) {
            // Les établissements scolaires
            SchoolSplitView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.school.rawValue,
                        systemImage: NavigationModel.TabSelection.school.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.school)
                .badge(SchoolEntity.cardinal())
                // passer les infos CloudKit pour les Infos
                .environmentObject(cloudKitVM)

            // Les classes
            ClasseSplitView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.classe.rawValue,
                        systemImage: NavigationModel.TabSelection.classe.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.classe)
                .badge(ClasseEntity.cardinal())

            // Les élèves
            EleveSplitView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.eleve.rawValue,
                        systemImage: NavigationModel.TabSelection.eleve.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.eleve)
                .badge(EleveEntity.cardinal())

            // Les observations données aux élèves
            // Les colles données aux élèves
            WarningSplitView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.warning.rawValue,
                        systemImage: NavigationModel.TabSelection.warning.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.warning)
                .badge(ObservEntity.cardinal() + ColleEntity.cardinal())

            // Les programmes scolaires
            ProgramSplitView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.program.rawValue,
                        systemImage: NavigationModel.TabSelection.program.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.program)
                .badge(ProgramEntity.cardinal())

            if isPad() || isMac() {
                // Les compétences
                CompetencySplitView()
                    .tabItem {
                        Label(
                            NavigationModel.TabSelection.competence.rawValue,
                            systemImage: NavigationModel.TabSelection.competence.imageName
                        ).symbolVariant(.none)
                    }
                    .tag(NavigationModel.TabSelection.competence)
            }
        }
        .environmentObject(navig)
        .badgeProminence(.decreased)

        // Alerte en cas d'erreur d'initilisation de l'App
        .alert(
            isPresented: $isInitAlertPresented,
            error: AppState.shared.initError
        ) { error in
            Button("OK", role: .cancel) {
                customLog.log(level: .error, "\(error.failureReason ?? "Raison inconue.")")
            }
        } message: { error in
            let failureReason = error.failureReason ?? "Raison inconnue."
            let recoverySuggestion = error.recoverySuggestion ?? ""
            let message = failureReason + (recoverySuggestion == "" ? "" : "\n\(recoverySuggestion)")
            Text(message)
        }
        // Deep Link
        .onOpenURL { incomingURL in
            handleIncomingURL(incomingURL)
        }
        // Alerte en cas d'erreur de connection iCloud
        .onChange(of: cloudKitVM.iCloudError, initial: false) {
            if cloudKitVM.iCloudError != .available {
                isiCloudAlertPresented = true
            }
        }
        .alert(
            isPresented: $isiCloudAlertPresented,
            error: cloudKitVM.iCloudError
        ) { error in
            #if os(iOS) || os(tvOS)
                // Ouvre les réglages de l'App sous iOS ou tvOS
                //                Button("Réglages") {
                //                    Task {
                //                        // Create the URL that deep links to your app's custom settings.
                //                        if let url = URL(string: UIApplication.openSettingsURLString) {
                //                            // Ask the system to open that URL.
                //                            await UIApplication.shared.open(url)
                //                        }
                //                    }
                //                }
            #endif
            Button("OK", role: .cancel) {
                customLog.log(level: .error, "\(error.failureReason ?? "Raison inconue.")")
            }
        } message: { error in
            let failureReason = error.failureReason ?? "Raison inconnue."
            let recoverySuggestion = error.recoverySuggestion ?? ""
            let message = failureReason + (recoverySuggestion == "" ? "" : "\n\(recoverySuggestion)")
            Text(message)
        }
        // Synchronous initializing of the View
        .onAppear {
            // Afficher une alerte en cas de problème d'initialisation de l'App
            checkAppInitFailure()

            // Set the Style of the TabBar
            setTabBarStyle()
        }

        // Asynchronous initializing of the View
        // Persistence dans SceneStorage de l'état de navigation
        .task {
            if let navigationData {
                // Remplacer l'état de navigation initial par celui récupéré à partir
                // du décodage de l'état antérieur de navigation stocké dans SceneStorage
                navig.jsonData = navigationData
            }
            // Encoder le nouvel état de navigation (qui vient de changer)
            // dans navigationData et les faire persister dans SceneStorage
            for await _ in navig.objectWillChangeSequence {
                navigationData = navig.jsonData
            }
        }
    }
}

// MARK: - Deep Link URL

extension ContentView {
    /// Gérer un deep link URL entrant
    private func handleIncomingURL(_ url: URL) {
        // Vérifier la légalité de l'URL
        var scheme = ""
        var action = ""
        var components = URLComponents()

        guard urlIsLegal(
            url: url,
            scheme: &scheme,
            action: &action,
            components: &components
        ) else {
            return
        }

        // Exécuter l'action requise
        let urlScheme = "assistprof"
        let urlUpdateProgressAction = "update-progress"

        guard scheme == urlScheme else {
            customLog.log(level: .error, "Detected scheme \(scheme) is not the right one!: \(url)")
            return
        }

        switch action {
            case urlUpdateProgressAction:
                handleUpdateProgressAction(components: components)

            default:
                // Action : inconnue
                customLog.log(level: .debug, "Action unknown: \(action) in \(url)")
        }
    }

    /// Vérifier la légalité de l'URL reçue.
    /// - Parameters:
    ///   - url: URL reçue
    ///   - scheme: Schéma détecté.
    ///   - action: Action (host) détectée.
    ///   - components: Queries détectés.
    /// - Returns: `false` si l'URL est illégale.
    private func urlIsLegal(
        url: URL,
        scheme: inout String,
        action: inout String,
        components: inout URLComponents
    ) -> Bool {
        // Vérifier la légalité de l'URL
        guard let _scheme = url.scheme else {
            customLog.log(level: .debug, "No scheme detected in incoming URL: \(url)")
            return false
        }

        guard let _components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            customLog.log(level: .debug, "No compnent detected: \(url)")
            return false
        }

        guard let _action = _components.host else {
            customLog.log(level: .debug, "No action (host) detected: \(url)")
            return false
        }

        scheme = _scheme
        action = _action
        components = _components
        return true
    }

    /// Gérer l'action "update-progress".
    /// - Parameter components: Queries de l'URL reçue.
    private func handleUpdateProgressAction(
        components: URLComponents
    ) {
        // Action : Actualiser la progression d'une classe d'un établissement
        guard let schoolName = components.queryItems?.first(where: { $0.name == "school" })?.value else {
            customLog.log(level: .debug, "School name not found in queries: \(String(describing: components))")
            return
        }
        guard let classeName = components.queryItems?.first(where: { $0.name == "classe" })?.value else {
            customLog.log(level: .debug, "Classe name not found in queries: \(String(describing: components))")
            return
        }

        guard let classe = SchoolEntity.school(withName: schoolName)?.classe(withAcronym: classeName) else {
            customLog.log(level: .debug, "Classe inexistante pour: **\(schoolName) - \(classeName)**")
            return
        }

        DeepLinkManager.handle(
            navigateTo: .classeProgressUpdate(classe: classe),
            using: navig
        )
    }
}

// MARK: - Methods

extension ContentView {
    /// Afficher une alerte en cas de problème d'initialisation de l'App
    private func checkAppInitFailure() {
        switch AppState.shared.initError {
            case .none,
                 .failedToInitializeCloudKitSchema:
                isInitAlertPresented = false

            case .failedToLoadUserData,
                 .failedToInitialize,
                 .failedToLoadApplicationData,
                 .failedToCheckCompatibility,
                 .failedToLoadPersistentStores:
                isInitAlertPresented = true
        }
    }

    /// Set the Style of the TabBar
    private func setTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor(.tabBarColor)

        // Use this appearance when scrolling behind the TabView:
        UITabBar.appearance().standardAppearance = appearance
        // Use this appearance when scrolled all the way up:
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ContentView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
