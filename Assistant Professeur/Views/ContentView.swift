//
//  ContentView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import AppFoundation
import CloudKit
import HelpersView
import OSLog
import SwiftUI
import StoreKit

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ContentView"
)

struct ContentView: View {
    @SceneStorage("navigation")
    private var navigationData: Data?

    @StateObject
    private var navig = NavigationModel()

    @State
    private var cloudKitVM = CloudKitViewModel()

    @Environment(UserContext.self)
    private var userContext

    @Environment(Store.self)
    private var store

    @State
    private var isiCloudAlertPresented = false

    @State
    private var alertInfo = AlertInfo()

    @State
    private var showTabBar = true

    var body: some View {
        @Bindable var store = store
        
        TabView(selection: navig.tabSelection()) {
            // Pour chaque onglet
            ForEach(AppScreen.allCases) { screen in
                if isPad() || isMac() || screen != AppScreen.competence {
                    screen.view
                        .tabItem { screen.label }
                        .toolbar(showTabBar ? .visible : .hidden, for: .tabBar)
                }
            }
        }
        .environmentObject(navig)
        .badgeProminence(.decreased)

        .onRotate { newOrientation in
            showTabBar = !isPhone() ||
                (newOrientation.isPortrait || newOrientation.isFlat)
        }

        .sheet(isPresented: $store.isShowingStore) {
            NavigationStack {
                AppShopView()
//                    .onInAppPurchaseCompletion { _, purchaseResult in
//                        guard case .success(let verificationResult) = purchaseResult,
//                              case .success = verificationResult else {
//                            return
//                        }
//                        store.isShowingStore = false
//                    }
            }
        }

        // Alerte en cas d'erreur d'initilisation de l'App
        .errorAlert(
            error: .constant(AppState.shared.initError), // cette propriété n'est pas un Binding @Published
            actions: { error in
                customLog.error("\(error.errorDescription ?? "Raison inconue.")")
            }
        )
        // Alerte en cas d'erreur de connection iCloud
        .errorAlert(
            error: $cloudKitVM.iCloudError,
            actions: { error in
                customLog.error("\(error.errorDescription ?? "Raison inconue.")")
            }
        )
        // Alerte des ToDo du jour
        .alert(
            alertInfo.title,
            isPresented: $alertInfo.isPresented,
            actions: {},
            message: { Text(alertInfo.message) }
        )

        // Deep Link
        .onOpenURL { incomingURL in
            DeepLinkManager.handleIncomingURL(
                incomingURL,
                using: navig
            )
        }

        // Synchronous initializing of the View
        .onAppear {
            // Set the Style of the TabBar
            setTabBarStyle()
        }

        // Asynchronous initializing of the View
        // Persistence dans SceneStorage de l'état de navigation
        .task {
            await persistNavigationData()
        }
        // vérifier la liste des ToDo du jour et alerter l'utilisateur si besoin
        .task {
            await checkTodayToDoList()
        }
        .task {
            await checkNotificationAuthorisation()
        }
//        .alert(
//            isPresented: .constant(cloudKitVM.iCloudError != nil),
//            error: cloudKitVM.iCloudError
//        ) { error in
//            #if os(iOS) || os(tvOS)
//                // Ouvre les réglages de l'App sous iOS ou tvOS
//                //                Button("Réglages") {
//                //                    Task {
//                //                        // Create the URL that deep links to your app's custom settings.
//                //                        if let url = URL(string: UIApplication.openSettingsURLString) {
//                //                            // Ask the system to open that URL.
//                //                            await UIApplication.shared.open(url)
//                //                        }
//                //                    }
//                //                }
//            #endif
//            Button("OK", role: .cancel) {
//                customLog.log(level: .error, "\(error.failureReason ?? "Raison inconue.")")
//                // set the error back to nil so our alert will be dismissed
//                cloudKitVM.iCloudError = nil
//            }
//        } message: { error in
//            let failureReason = error.failureReason ?? "Raison inconnue."
//            let recoverySuggestion = error.recoverySuggestion ?? ""
//            let message = failureReason + (recoverySuggestion == "" ? "" : "\n\(recoverySuggestion)")
//            Text(message)
//        }
    }
}

// MARK: - Methods

extension ContentView {
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

// MARK: - Tâches

extension ContentView {
    /// Persistence dans SceneStorage de l'état de navigation
    @MainActor
    private func persistNavigationData() async {
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

    /// Vérifier la cohérence entre les autorisations et les préférences
    @MainActor
    private func checkNotificationAuthorisation() async {
        guard let prefs = userContext.prefs,
              prefs.notificationsEnabled else {
            return
        }
        // Les notifications quotidiennes sont autorisée

        // Requests authorization to allow local and remote notifications for your app.
        let UNCenter = UNUserNotificationCenter.current()
        let settings = await UNCenter.notificationSettings()

        // Vérifier que l'utilisateur a autorisé les notifications
        if (settings.authorizationStatus != .authorized) &&
            (settings.authorizationStatus != .provisional) {
            // Les notifications ne sont pas autorisées
            // => les demander
            _ = try? await UNCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        }
    }

    /// Vérifier la liste des ToDo du jour et alerter l'utilisateur si besoin
    @MainActor
    private func checkTodayToDoList() async {
        guard let prefs = userContext.prefs,
              prefs.launchAlertEnabled else {
            return
        }

        // Utiliser un calendrier par défaut car accès impossible à UserPref (non initialisé)
        let schoolYear = SchoolYearPref()

        let (nbOfDocsToBePrinted, nbOfDocsToBeLoaded) =
            await ReminderTaskManager.shared.actionsToDo(schoolYear: schoolYear)

        guard nbOfDocsToBePrinted > 0 || nbOfDocsToBeLoaded > 0 else {
            return
        }

        // Alerter sur les ToDo
        let printStr = if nbOfDocsToBePrinted == 0 {
            ""
        } else {
            " • \(nbOfDocsToBePrinted) documents à imprimer.\n"
        }
        let loadStr = if nbOfDocsToBeLoaded == 0 {
            ""
        } else {
            " • \(nbOfDocsToBeLoaded) documents à partager sur l'ENT.\n"
        }

        alertInfo.title = ReminderTaskManager.shared.alertTitle
        alertInfo.message = "\n" + printStr + loadStr +
            "\nConsultez-en la liste dans chaque établissement."
        alertInfo.isPresented = true
    }
}

#Preview {
    ContentView()
        .generateData()
        .padding()
//        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
}
