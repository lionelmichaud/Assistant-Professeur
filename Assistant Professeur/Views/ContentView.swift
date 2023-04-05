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
    category: "Extensions.Bundle-Codable"
)

struct ContentView: View {
    @SceneStorage("navigation")
    private var navigationData: Data?

    @StateObject
    private var navigationModel = NavigationModel()

    @StateObject
    private var cloudKitVM = CloudKitViewModel()

    @State
    private var initAlertIsPresented = false

    @State
    private var iCloudAlertIsPresented = false

    var body: some View {
        TabView(selection: $navigationModel.selectedTab) {
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
            WarningSpliView()
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.warning.rawValue,
                        systemImage: NavigationModel.TabSelection.warning.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.warning)
                .badge(ObservEntity.cardinal() + ColleEntity.cardinal())

//            if isPad() || isMac() {
            // Les programmes scolaires
            ProgramSplitView(navig: navigationModel)
                .tabItem {
                    Label(
                        NavigationModel.TabSelection.program.rawValue,
                        systemImage: NavigationModel.TabSelection.program.imageName
                    ).symbolVariant(.none)
                }
                .tag(NavigationModel.TabSelection.program)
                .badge(ProgramEntity.cardinal())
//            }
        }
        .environmentObject(navigationModel)

        // Alerte en cas d'erreur d'initilisation de l'App
        .alert(
            isPresented: $initAlertIsPresented,
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
        .alert(
            isPresented: $iCloudAlertIsPresented,
            error: cloudKitVM.iCloudError
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

        .onChange(of: cloudKitVM.iCloudError) { value in
            if value != .available {
                iCloudAlertIsPresented.toggle()
            }
        }
        // Synchronous initializaing of the View
        .onAppear {
            // Afficher une alerte en cas de problème d'initialisation de l'App
            checkAppInitFailure()
        }

        // Asynchronous initializaing of the View
        .task {
            if let navigationData {
                // Remplacer l'état de navigation initial par celui récupéré à partir
                // du décodage de l'état antérieur de navigation stocké dans SceneStorage
                navigationModel.jsonData = navigationData
            }
            // Encoder l'état de navigation (qui vient de changer) dans SceneStorage
            for await _ in navigationModel.objectWillChangeSequence {
                navigationData = navigationModel.jsonData
            }
        }
    }

    /// Afficher une alerte en cas de problème d'initialisation de l'App
    private func checkAppInitFailure() {
        switch AppState.shared.initError {
            case .none:
                initAlertIsPresented = false

            case .failedToLoadUserData,
                 .failedToInitialize,
                 .failedToLoadApplicationData,
                 .failedToCheckCompatibility,
                 .failedToLoadPersistentStores,
                 .failedToInitializeCloudKitSchema:
                initAlertIsPresented = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return ContentView()
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")
    }
}
