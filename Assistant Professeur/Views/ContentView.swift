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
                .tabItem { Label("Etablissement", systemImage: "building.2").symbolVariant(.none) }
                .tag(NavigationModel.Tab.school)
                .badge(SchoolEntity.cardinal())
                // passer les infos CloudKit pour les Infos
                .environmentObject(cloudKitVM)

            // Les classes
            ClasseSplitView()
                .tabItem { Label("Classes", systemImage: "person.3.sequence").symbolVariant(.none) }
                .tag(NavigationModel.Tab.classe)
                .badge(ClasseEntity.cardinal())

            // Les élèves
            EleveSplitView()
                .tabItem { Label("Elèves", systemImage: "graduationcap").symbolVariant(.none) }
                .tag(NavigationModel.Tab.eleve)
                .badge(EleveEntity.cardinal())

            // Les observations données aux élèves
            // Les colles données aux élèves
            WarningSpliView()
                .tabItem { Label("Avertissements", systemImage: "hand.raised").symbolVariant(.none) }
                .tag(NavigationModel.Tab.warning)
                .badge(ObservEntity.cardinal() + ColleEntity.cardinal())

//            if isPad() || isMac() {
            // Les programmes scolaires
            ProgramSplitView(navig: navigationModel)
                .tabItem { Label("Programmes", systemImage: "books.vertical").symbolVariant(.none) }
                .tag(NavigationModel.Tab.program)
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
            // décoder le dernier status de navigation dans l'App
            if let navigationData {
                navigationModel.jsonData = navigationData
            }
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
    static var previews: some View {
        ContentView()
    }
}
