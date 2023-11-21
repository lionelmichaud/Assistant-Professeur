//
//  MainScene.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/11/2022.
//

import AppFoundation
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "MainScene"
)

/// Defines the main scene of the App
struct MainScene: Scene {
    let coreDataManager: CoreDataManager
    let authentication: Authentication
    let userContext: UserContext

    // object that you want to use throughout your views and that will be specific to each scene
    // @StateObject private var uiState = UIState()

    // MARK: - Environment Properties

    @Environment(\.scenePhase)
    private var scenePhase

    // MARK: - Properties

    var body: some Scene {
        WindowGroup {
            // defines the views hierachy of the scene
            HomeScreen()
                .environment(\.managedObjectContext, coreDataManager.context)
                .environmentObject(authentication)
                .environmentObject(userContext)
        }

        // Gérer les changements de phases
        .onChange(of: scenePhase, manageScenePhaseChanges)

        // Afficher les éventuels daily ToDo reminder
        .backgroundTask(.appRefresh(ReminderTaskManager.shared.backgroundTaskIdentifier)) {
            // This is where you respond the scheduled background task
            // you can also reschedule the background task HERE if you want to keep calling from time to time,
            // just send BGTaskScheduler.shared.submit(request) here again and again.
            await dailyToDoAppRefresh()
        }
        #if os(macOS)
        .commands {
            SidebarCommands()
        }
        #endif
        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }

    // MARK: - Methods

    /// This is where you respond the scheduled background task
    /// you can also reschedule the background task HERE if you want to keep calling from time to time,
    /// just send BGTaskScheduler.shared.submit(request) here again and again.
    func dailyToDoAppRefresh() async {
        customLog.log(
            level: .info,
            "Background refresh task started for identifer: \(ReminderTaskManager.shared.backgroundTaskIdentifier)"
        )
        await withTaskCancellationHandler(
            operation: {
                // Renouveler le réveil le lendemain
                await ReminderTaskManager.shared.schedulNextReminderNotification()

                // Utiliser un calendrier par défaut car accès impossible à UserPref (non initialisé)
                let schoolYear = SchoolYearPref()

                // Notifier le reminder
                await ReminderTaskManager.shared.notifyReminder(
                    schoolYear: schoolYear
                )
            },
            onCancel: {
                customLog.log(
                    level: .debug,
                    "Background refresh canceled by System for identifer: \(ReminderTaskManager.shared.backgroundTaskIdentifier)"
                )
            }
        )
    }

    /// Gérer les changements de phases
    private func manageScenePhaseChanges() {
        // The final step is optional, but recommended:
        // when your app moves to the background,
        // you should call the save() method so that Core Data saves your changes permanently.
        switch scenePhase {
            case .active:
                // An app or custom scene in this phase contains at least one active scene instance.
                break
                //                    print("Scene Phase = .active")

            case .inactive:
                // An app or custom scene in this phase contains no scene instances in the ScenePhase.active phase.
                break
                //                    print("Scene Phase = .inactive")

            case .background:
                // Expect an app that enters the background phase to terminate.

                try? coreDataManager.saveIfContextHasChanged()
                //                    print("Scene Phase = .background")

            @unknown default:
                fatalError()
        }
    }
}
