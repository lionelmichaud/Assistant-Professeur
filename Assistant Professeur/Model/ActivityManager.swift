//
//  ActivityManager.swift
//
//
//  Created by Lionel MICHAUD on 10/10/2023.
//

import ActivityKit
import Combine
import Foundation

/// This class is responsible for the live activity management
///  - Reference: [medium](https://medium.com/kinandcartacreated/how-to-build-ios-live-activity-d1b2f238819e)
final class ActivityManager: ObservableObject {
    /// The identifier of the activity that its generated once the activity is created
    /// (note that actually you can have multiple running activities in your app,
    /// but for this example we are going to basically always have just one)
    @MainActor @Published
    private(set) var activityID: String?

    /// The token generated for the current activity,
    /// used in the backend for creating the activity-update push notification
    @MainActor @Published
    private(set) var activityToken: String?

    private var attributes: LiveCoursProgressAttributes?

    /// Cancel all running activities and then start a new one
    func start(
        withInitialState initialState: LiveCoursProgressState,
        fixedAttributes: LiveCoursProgressFixedAttributes
    ) async {
        await endActivity()
        await startNewLiveActivity(
            withInitialState: initialState,
            fixedAttributes: fixedAttributes
        )
    }

    /// Actually request the initialisation and the start of a new activity,
    /// passing the the initial properties values, and obtaining its activityID and activityToken
    private func startNewLiveActivity(
        withInitialState initialState: LiveCoursProgressState,
        fixedAttributes: LiveCoursProgressFixedAttributes
    ) async {
        self.attributes = LiveCoursProgressAttributes(fixedAttributes: fixedAttributes)

        // Etat initial de l'activité
        let initialContent = ActivityContent(
            state: LiveCoursProgressAttributes.ContentState(
                dynamicAttributes: initialState
            ),
            staleDate: nil
        )
        let activity = try? Activity.request(
            attributes: attributes!,
            content: initialContent,
            pushType: .token
        )
        guard let activity = activity else {
            return
        }

        await MainActor.run {
            activityID = activity.id
        }

        for await data in activity.pushTokenUpdates {
            let token = data.map {
                String(
                    format: "%02x",
                    $0
                )
            }.joined()
            #if DEBUG
                print("Activity token: \(token)")
            #endif
            await MainActor.run {
                activityToken = token
            }
            // HERE SEND THE TOKEN TO THE SERVER
        }
    }

    /// Where the current running activity (if any) is updated with some random values
    func updateActivity(
        withNewState newState: LiveCoursProgressState,
        alertConfiguration: AlertConfiguration? = nil
    ) async {
        // Recover the running live activity
        guard let activityID = await activityID,
              let runningActivity = Activity<LiveCoursProgressAttributes>
              .activities
              .first(where: {
                  $0.id == activityID
              }) else {
            return
        }

        // Define the new dynamic content of the live activity
        let newContentState = LiveCoursProgressAttributes.ContentState(dynamicAttributes: newState)
        let newActivityContent = ActivityContent(
            state: newContentState,
            staleDate: nil
        )

        // Update the live activity
        await runningActivity
            .update(
                newActivityContent,
                alertConfiguration: alertConfiguration
            )
    }

    /// Find in the running activities (of the specified type LiveCoursProgressAttributes)
    /// the one with the activityID that we stored in the manager and end it,
    /// so that means it will not be shown anymore in the dynamic island and in the lock screen
    func endActivity() async {
        guard let activityID = await activityID,
              let runningActivity = Activity<LiveCoursProgressAttributes>.activities.first(where: {
                  $0.id == activityID
              }) else {
            return
        }
        let endContentState = LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: .defaultEndState
        )

        await runningActivity.end(
            ActivityContent(
                state: endContentState,
                staleDate: Date.distantFuture
            ),
            dismissalPolicy: .immediate
        )

        await MainActor.run {
            self.activityID = nil
            self.activityToken = nil
        }
    }

    /// Run through all the current running activities (of the specified type MatchLiveScoreAttributes) and end it all
    func cancelAllRunningActivities() async {
        let endContentState = LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: .defaultEndState
        )
        for activity in Activity<LiveCoursProgressAttributes>.activities {
            await activity.end(
                ActivityContent(
                    state: endContentState,
                    staleDate: Date.distantFuture
                ),
                dismissalPolicy: .immediate
            )
        }

        await MainActor.run {
            activityID = nil
            activityToken = nil
        }
    }
}
