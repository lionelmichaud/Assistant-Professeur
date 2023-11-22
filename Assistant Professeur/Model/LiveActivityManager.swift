//
//  ActivityManager.swift
//
//
//  Created by Lionel MICHAUD on 10/10/2023.
//

#if canImport(ActivityKit)
    import ActivityKit
    import AppFoundation
    import Combine
    import Foundation
    import os

    private let customLog = Logger(
        subsystem: "com.michaud.lionel.Fundation-Package",
        category: "LiveActivityManager"
    )

    /// This class is responsible for the live activity management.
    /// Only one Live Activity may be active at a time.
    /// When a new activity is started, any running actity is stopped.
    ///  - Reference: [medium](https://medium.com/kinandcartacreated/how-to-build-ios-live-activity-d1b2f238819e)
    //@MainActor
    actor LiveActivityManager {
        // MARK: - Type Properties

        static let shared = LiveActivityManager()

        // MARK: - Initializer

        private init() {}

        // MARK: - Properties

        let staleTimeInterval: TimeInterval? = 2.0 * 60.0 // seconds
        let dismissTimeInterval: TimeInterval? = 5.0 * 60.0 // seconds: nil = .default

        /// The identifier of the activity that its generated once the activity is created
        /// (note that actually you can have multiple running activities in your app,
        /// but for this example we are going to basically always have just one)
        private var runningActivityID: String?

        /// The token generated for the current activity,
        /// used in the backend for creating the activity-update push notification
        private var runningActivityToken: String?

        private var runningActivity: Activity<LiveCoursProgressAttributes>?

        // MARK: - Computed Properties

        private var dismissalPolicy: ActivityUIDismissalPolicy {
            if let dismissTimeInterval {
                if dismissTimeInterval <= 0 {
                    .immediate
                } else {
                    .after(.now + dismissTimeInterval)
                }
            } else {
                .default
            }
        }

        private var staleDate: Date? {
            if let staleTimeInterval {
                .now + max(0.0, staleTimeInterval)
            } else {
                nil
            }
        }

        // MARK: - Methods

        private func runningActivity(withID: String) -> Activity<LiveCoursProgressAttributes>? {
            Activity<LiveCoursProgressAttributes>
                .activities
                .first {
                    $0.id == withID
                }
        }

        /// Retuns a boolean value that indicates whether your app can start a Live Activity
        /// - Important: retourne `false` si le matériel n'est pas un iPhone.
        func areActivitiesEnabled() -> Bool {
            guard isPhone() else {
                // Ne jamais exécuter des opérations LiveActivity sur un Mac
                return false
            }
            let authorization = ActivityAuthorizationInfo()
            return authorization.areActivitiesEnabled
        }

        /// Cancel all running activities and then start a new one if authorized.
        /// - Note: No activity is started if Live Activity is not authorized.
        func start(
            withInitialState initialState: LiveCoursProgressState,
            fixedAttributes: LiveCoursProgressFixedAttributes
        ) async {
            guard isPhone() else {
                // Ne jamais exécuter des opérations LiveActivity sur un Mac
                return
            }

            await endAllRunningActivities()

            guard areActivitiesEnabled() else {
                return
            }

            await startNewLiveActivity(
                withInitialState: initialState,
                fixedAttributes: fixedAttributes
            )
        }

        /// Requests the initialisation and the start of a new activity,
        /// passing the initial properties values, and obtaining its activityID and activityToken.
        /// - Note: No activity is started if Live Activity is not authorized.
        private func startNewLiveActivity(
            withInitialState initialState: LiveCoursProgressState,
            fixedAttributes: LiveCoursProgressFixedAttributes
        ) async {
            guard areActivitiesEnabled() else {
                return
            }

            let attributes =
                LiveCoursProgressAttributes(
                    fixedAttributes: fixedAttributes
                )

            // Etat initial de l'activité: fin 10 mintes après la fin du cours
            let initialState =
                LiveCoursProgressAttributes.ContentState(
                    dynamicAttributes: initialState
                )
            let initialContent =
                ActivityContent(
                    state: initialState,
                    staleDate: staleDate,
                    relevanceScore: 0
                )

            // Démarrer l'activité
            do {
                let activity = try Activity<LiveCoursProgressAttributes>.request(
                    attributes: attributes,
                    content: initialContent,
                    pushType: .token
                )

                self.runningActivityID = activity.id
                self.runningActivity = activity
            } catch {
                customLog.log(
                    level: .error,
                    "Couldn't start activity: '\(String(describing: error))'."
                )
            }
        }

        /// Where the current running activity (if any) is updated.
        /// - Note: No activity is updated if Live Activity is not authorized.
        func update(
            withNewState newState: LiveCoursProgressState,
            alertConfiguration: AlertConfiguration? = nil
        ) async {
            guard let activity = runningActivity,
                  areActivitiesEnabled() else {
                return
            }

            // Define the new dynamic content of the live activity
            let newContentState =
                LiveCoursProgressAttributes.ContentState(
                    dynamicAttributes: newState
                )
            let newActivityContent = ActivityContent(
                state: newContentState,
                staleDate: staleDate,
                relevanceScore: alertConfiguration == nil ? 0 : 50
            )

            // Update the live activity
            await activity.update(
                newActivityContent,
                alertConfiguration: alertConfiguration
            )
        }

        /// Find in the running activities (of the specified type LiveCoursProgressAttributes)
        /// the one with the activityID that we stored in the manager and end it,
        /// so that means it will not be shown anymore in the dynamic island and in the lock screen
        /// - Note: Any runing activity is ended, even if Live Activity is not authorized.
        func end(
            withFinalState finalState: LiveCoursProgressState
        ) async {
            guard isPhone() else {
                // Ne jamais exécuter des opérations LiveActivity sur un Mac
                return
            }

            guard let activity = runningActivity else {
                return
            }

            let endContentState = LiveCoursProgressAttributes.ContentState(
                dynamicAttributes: finalState
            )

            await activity.end(
                ActivityContent(
                    state: endContentState,
                    staleDate: staleDate
                ),
                dismissalPolicy: dismissalPolicy
            )

            self.runningActivity = nil
            self.runningActivityID = nil
            self.runningActivityToken = nil
        }

        /// Run through all the current running activities (of the specified type MatchLiveScoreAttributes) and end it all
        /// - Note: Any runing activity is ended, even if Live Activity is not authorized.
        func endAllRunningActivities() async {
            guard isPhone() else {
                // Ne jamais exécuter des opérations LiveActivity sur un Mac
                return
            }

            let activities = Activity<LiveCoursProgressAttributes>.activities
            for activity in activities {
                let endContentState = LiveCoursProgressAttributes.ContentState(
                    dynamicAttributes: .defaultEndState
                )
                await activity.end(
                    ActivityContent(
                        state: endContentState,
                        staleDate: .now
                    ),
                    dismissalPolicy: dismissalPolicy
                )
            }

            self.runningActivity = nil
            self.runningActivityID = nil
            self.runningActivityToken = nil
        }
    }
#endif
