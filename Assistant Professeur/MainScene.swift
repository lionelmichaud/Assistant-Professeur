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
    @Bindable var authentication: Authentication
    @Bindable var userContext: UserContext

    // object that you want to use throughout your views and that will be specific to each scene
    // @StateObject private var uiState = UIState()

    // MARK: - Environment Properties

    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage("warningRemainingMinutes")
    private var warningRemainingMinutes: Int = 10

    @AppStorage("alertRemainingMinutes")
    private var alertRemainingMinutes: Int = 5

    // MARK: - Properties

    var body: some Scene {
        WindowGroup {
            // defines the views hierachy of the scene
            HomeScreen()
                .environment(\.managedObjectContext, coreDataManager.context)
                .environment(authentication)
                .environment(userContext)
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

        // Mettre à jour la Live Activity
        .backgroundTask(.appRefresh(TodaySeances.shared.liveActivityTaskIdentifier)) {
            await liveActivityAppRefresh()
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
        await withTaskCancellationHandler(
            operation: {
                customLog.log(
                    level: .info,
                    "Background refresh task started for identifer: \(ReminderTaskManager.shared.backgroundTaskIdentifier)"
                )

                // Renouveler le réveil le lendemain
                await ReminderTaskManager.shared.schedulNextReminderNotification()

                // Notifier le reminder
                // Utiliser un calendrier par défaut car accès impossible à UserPref (non initialisé)
                await ReminderTaskManager.shared.notifyReminder(
                    schoolYear: SchoolYearPref()
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

    func liveActivityAppRefresh() async {
        await withTaskCancellationHandler(
            operation: {
                customLog.log(
                    level: .info,
                    "Background refresh task started for identifer: \(TodaySeances.shared.liveActivityTaskIdentifier)"
                )

                // Mettre à jour la Live Activity
                await TodaySeances.shared.updateLiveActivity(
                    alertRemainingMinutes: alertRemainingMinutes,
                    warningRemainingMinutes: warningRemainingMinutes
                )

                // Renouveler le réveil
                TodaySeances.shared.schedulNextUpdate()
            },
            onCancel: {
                customLog.log(
                    level: .debug,
                    "Background refresh canceled by System for identifer: \(TodaySeances.shared.liveActivityTaskIdentifier)"
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
                print(">> Scene Phase = .inactive")
                break

            case .background:
                // Expect an app that enters the background phase to terminate.
                print(">> Scene Phase = .background")
                try? coreDataManager.saveIfContextHasChanged()
                TodaySeances.shared.schedulNextUpdate()

            @unknown default:
                fatalError()
        }
    }
}
