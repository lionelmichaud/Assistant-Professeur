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
    private var navigationModel = NavigationModel()

    @StateObject
    private var cloudKitVM = CloudKitViewModel()

    @State
    private var isInitAlertPresented = false

    @State
    private var isiCloudAlertPresented = false

    var body: some View {
        TabView(selection: tabSelection()) {
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
        .environmentObject(navigationModel)

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
        // Synchronous initializaing of the View
        .onAppear {
            // Afficher une alerte en cas de problème d'initialisation de l'App
            checkAppInitFailure()

            // Style de la TabBar
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(.tabBarColor)

            // Use this appearance when scrolling behind the TabView:
            UITabBar.appearance().standardAppearance = appearance
            // Use this appearance when scrolled all the way up:
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        // Asynchronous initializing of the View
        // Persistence dans SceneStorage de l'état de navigation
        .task {
            if let navigationData {
                // Remplacer l'état de navigation initial par celui récupéré à partir
                // du décodage de l'état antérieur de navigation stocké dans SceneStorage
                navigationModel.jsonData = navigationData
            }
            // Encoder le nouvel état de navigation (qui vient de changer)
            // dans navigationData et les faire persister dans SceneStorage
            for await _ in navigationModel.objectWillChangeSequence {
                navigationData = navigationModel.jsonData
            }
        }
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

    /// Pop to root view when the current tab is tapped again
    private func tabSelection() -> Binding<NavigationModel.TabSelection> {
        Binding { // this is the get block
            navigationModel.selectedTab

        } set: { tappedTab in
            if tappedTab == navigationModel.selectedTab {
                // User tapped on the currently active tab icon => Pop to root/Scroll to top
                switch tappedTab {
                    case .school:
                        if navigationModel.schoolPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            navigationModel.schoolPath = []
                        }

                    case .classe:
                        if navigationModel.classPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            navigationModel.classPath = []
                        }

                    case .program:
                        if navigationModel.programPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            navigationModel.programPath.removeLast(navigationModel.programPath.count)
                        }

                    case .competence:
                        if navigationModel.competencePath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            navigationModel.competencePath.removeLast(navigationModel.competencePath.count)
                        }

                    default: break
                }
            }

            // Set the tab to the tabbed tab
            navigationModel.selectedTab = tappedTab
        }
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
