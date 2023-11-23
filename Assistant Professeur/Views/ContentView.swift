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

    @EnvironmentObject
    private var userContext: UserContext

    @State
    private var isiCloudAlertPresented = false

    @State
    private var alertInfo = AlertInfo()

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
        .errorAlert(
            error: .constant(AppState.shared.initError), // cette propriété n'est pas un Binding @Published
            actions: { error in
                customLog.log(level: .error, "\(error.errorDescription ?? "Raison inconue.")")
            }
        )

        // Deep Link
        .onOpenURL { incomingURL in
            handleIncomingURL(incomingURL)
        }

        // Alerte en cas d'erreur de connection iCloud
        .errorAlert(
            error: $cloudKitVM.iCloudError,
            actions: { error in
                customLog.log(level: .error, "\(error.errorDescription ?? "Raison inconue.")")
            }
        )

        // Alerte des ToDo du jour
        .alert(
            alertInfo.title,
            isPresented: $alertInfo.isPresented,
            actions: {},
            message: { Text(alertInfo.message) }
        )

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
    /// Persistence dans SceneStorage de l'état de navigation
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
            let authorized = try? await UNCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        }
    }

    /// Vérifier la liste des ToDo du jour et alerter l'utilisateur si besoin
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

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return ContentView()
        .padding()
//        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
