//
//  ContentView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import AppFoundation
import CloudKit
import HelpersView
import SwiftUI

struct ContentView: View {
    @SceneStorage("navigation")
    private var navigationData: Data?

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @StateObject
    private var navigationModel = NavigationModel()

    @State
    private var initAlertIsPresented = false

    @State
    private var iCloudAlertIsPresented = false

    @State
    private var iCloudError: ICloudError?

    var body: some View {
        TabView(selection: $navigationModel.selectedTab) {
            // Les établissements scolaires
            SchoolSplitView()
                .tabItem { Label("Etablissement", systemImage: "building.2").symbolVariant(.none) }
                .tag(NavigationModel.Tab.school)
                .badge(SchoolEntity.cardinal())

                // Alerte en cas d'erreur d'initilisation de l'App
                .alert(
                    isPresented: $initAlertIsPresented,
                    error: AppState.shared.initError
                ) { _ in
                    Button("Continuer", role: .cancel) {}
                } message: { error in
                    Text(error.failureReason ?? "Raison inconue.")
                }

            // Les classes
            ClasseSplitView()
                .tabItem { Label("Classes", systemImage: "person.3.sequence").symbolVariant(.none) }
                .tag(NavigationModel.Tab.classe)
                .badge(ClasseEntity.cardinal())

                // Alerte en cas d'erreur de connection iCloud
                .alert(
                    isPresented: $iCloudAlertIsPresented,
                    error: iCloudError
                ) { _ in
                    Button("Continuer", role: .cancel) {}
                } message: { error in
                    Text(error.failureReason ?? "Raison inconue.")
                }

            // Les élèves
            EleveSplitView()
                .tabItem { Label("Elèves", systemImage: "graduationcap").symbolVariant(.none) }
                .tag(NavigationModel.Tab.eleve)
                .badge(EleveEntity.cardinal())

            // Les observations données aux élèves
            ObservSplitView()
                .tabItem { Label("Observations", systemImage: "rectangle.and.text.magnifyingglass").symbolVariant(.none) }
                .tag(NavigationModel.Tab.observation)
                .badge(ObservEntity.cardinal())

            // Les colles données aux élèves
            ColleSplitView()
                .tabItem { Label("Colles", systemImage: "lock").symbolVariant(.none) }
                .tag(NavigationModel.Tab.colle)
                .badge(ColleEntity.cardinal())

            if horizontalSizeClass == .regular {
                // Les programmes scolaires
                ProgramSplitView()
                    .tabItem { Label("Programmes", systemImage: "books.vertical").symbolVariant(.none) }
                    .tag(NavigationModel.Tab.program)
                    .badge(ProgramEntity.cardinal())
            }
        }
        .environmentObject(navigationModel)

        .task {
            // Afficher une alerte en cas de problème d'initialisation de l'App
            checkAppInitFailure()

            // Vérifier le status de iCloud
            checkiCloudSignIn()

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
            break

        case .failedToLoadUserData,
             .failedToInitialize,
             .failedToLoadApplicationData,
             .failedToCheckCompatibility:
            initAlertIsPresented = true
        }
    }

    /// Vérifier le status de iCloud
    private func checkiCloudSignIn() {
        CKContainer.default().accountStatus { accountStatus, _ in
            if accountStatus != .available {
                switch accountStatus {
                case .couldNotDetermine:
                    iCloudError = .couldNotDetermine
                case .available:
                    return
                case .restricted:
                    iCloudError = .restricted
                case .noAccount:
                    iCloudError = .noAccount
                case .temporarilyUnavailable:
                    iCloudError = .temporarilyUnavailable
                @unknown default:
                    iCloudError = .unknown
                }
                iCloudAlertIsPresented = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
