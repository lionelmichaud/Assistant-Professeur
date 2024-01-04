//
//  ReminderTaskManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/11/2023.
//

import AppFoundation
import BackgroundTasks
import EventKit
import Foundation
import OSLog
import UserNotifications

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ReminderManager"
)

actor ReminderTaskManager {
    static let shared = ReminderTaskManager()

    // MARK: - Properties

    /// Identifiant de la BackgroundTask
    let backgroundTaskIdentifier = "REMINDER"

    /// Heure d'exécution de la BackgroundTask
    let reminderWakeupTime = DateComponents(hour: 8, minute: 0)

    /// Titre des Notification / Alerte
    let alertTitle = "Vous avez des actions à réaliser..."

    // MARK: - Initializer

    private init() {}

    // MARK: - Methods

    /// Register the next notification request for daily ToDo reminders
    func schedulNextReminderNotification() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        // Vérifier que l'utilisateur a autorisé les notifications
        guard (settings.authorizationStatus == .authorized) ||
            (settings.authorizationStatus == .provisional) else {
            return
        }

//        if settings.alertSetting == .enabled {
//            // Schedule an alert-only notification.
//            #if DEBUG
//                print("settings.alertSetting == .enabled")
//            #endif
//        } else {
//            // Schedule a notification with a badge and sound.
//            #if DEBUG
//                print("settings.alertSetting == .disabled")
//            #endif
//        }

        // creating the background task request,
        // this is where you will specify the identifier that
        // you will use later to invoke code in your app in the background.
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        /* setting the scheduling date. This is where you tell iOS
         when to update the app in the background. Remember,
         that this is a SUGGESTION to the iOS because
         it takes other things into consideration and
         this is by no means a hard scheduled date.
         You can and you should expect this won’t be triggered when you want it.
         */
        request.earliestBeginDate = nextWakeupDate()
        do {
            /* sending the request to the Scheduler so it can be kept by the system.
             This is the last step of the process and now we are good when
             the background task scheduler calls our app on the scheduled date
             */
            try BGTaskScheduler.shared.submit(request)
            customLog.debug(
                "ToDo daily reminder background Task Scheduled"
            )

        } catch {
            customLog.error(
                "ToDo daily reminder scheduling Error: \(error.localizedDescription)"
            )
        }
    }

    /// Vérifier si l''utilisateur a des actions à réaliser poru la journée en cours.
    /// - Parameter schoolYear: Calendrier scolaire
    /// - Returns: nombre de documents à imprimer et nombre de documents à charger sur l'ENT
    func actionsToDo(
        schoolYear: SchoolYearPref
    ) async -> (nbOfDocsToBePrinted: Int, nbOfDocsToBeLoaded: Int) {
        var schools = [SchoolEntity]()
        SchoolEntity.context.performAndWait {
            schools = SchoolEntity.allSortedByLevelName()
        }
        var seances = Seances()
        for school in schools {
            var schoolName = ""
            SchoolEntity.context.performAndWait {
                schoolName = school.viewName
            }
            let schoolSeances = await todaySeances(
                forSchool: school,
                schoolName: schoolName,
                schoolYear: schoolYear
            )
            seances += schoolSeances
        }

        if seances.isEmpty {
            return (0, 0)
        }

        let toDoModel = ToDoViewModel()
        await toDoModel.getAllDocsToBeActioned(
            fromSeances: seances,
            forThisAction: .print
        )
        await toDoModel.getAllDocsToBeActioned(
            fromSeances: seances,
            forThisAction: .load
        )

        return await (
            nbOfDocsToBePrinted: toDoModel.batchesOfDocsToBePrinted.count,
            nbOfDocsToBeLoaded: toDoModel.batchesOfDocsToBeLoaded.count
        )
    }

    private func nextWakeupDate() -> Date {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: today
        )!
        return Calendar.current.date(
            byAdding: reminderWakeupTime,
            to: tomorrow
        )!
    }

    private func todaySeances(
        forSchool school: SchoolEntity,
        schoolName: String,
        schoolYear: SchoolYearPref
    ) async -> Seances {
        // Demander les droits d'accès aux calendriers de l'utilisateur
        let eventStore = EKEventStore()
        var calendar: EKCalendar?
        var alert = AlertInfo()
        (
            calendar,
            alert.isPresented,
            alert.title,
            alert.message
        ) = await EventManager.shared
            .requestCalendarAccess(
                eventStore: eventStore,
                calendarName: schoolName
            )
        guard let calendar else {
            return []
        }

        let period: PeriodEnum = .restOfTheDay

        // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
        // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
        let schoolSeances = await SeancesInDateInterval
            .nextSeancesForSchool(
                school: school,
                inCalendar: calendar,
                inEventStore: eventStore,
                inDateInterval: period.dateInterval,
                schoolYear: schoolYear
            )

        return schoolSeances.seances
    }

    /// Envoyer une notification immédiate à l'utilisateur s'il faut lui rappeler qu'il a des actions
    /// à réaliser en prévision de la journée à venir.
    func notifyReminder(
        schoolYear: SchoolYearPref
    ) async {
        let (nbOfDocsToBePrinted, nbOfDocsToBeLoaded) = await actionsToDo(schoolYear: schoolYear)
        if nbOfDocsToBePrinted > 0 || nbOfDocsToBeLoaded > 0 {
            sendNotification(
                nbOfDocsToBePrinted: nbOfDocsToBePrinted,
                nbOfDocsToBeLoaded: nbOfDocsToBeLoaded
            )
        }
    }

    /// Envoyer une notification immédiate à l'utilisateur
    private func sendNotification(
        nbOfDocsToBePrinted: Int,
        nbOfDocsToBeLoaded: Int
    ) {
        // Définir le contenu affichable de la notification
        let content = UNMutableNotificationContent()
        content.title = self.alertTitle

        let printStr = if nbOfDocsToBePrinted == 0 {
            ""
        } else {
            " - \(nbOfDocsToBePrinted) documents à imprimer.\n"
        }

        let loadStr = if nbOfDocsToBeLoaded == 0 {
            ""
        } else {
            " - \(nbOfDocsToBeLoaded) documents à partager sur l'ENT.\n"
        }

        content.subtitle = printStr + loadStr + "Consultez-en la liste!"
        content.sound = .default
        content.badge = (nbOfDocsToBePrinted + nbOfDocsToBeLoaded) as NSNumber

        // Définir le déclecncheur
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        // Définir la requête
        let request = UNNotificationRequest(
            identifier: backgroundTaskIdentifier + "_NOTIFICATION",
            content: content,
            trigger: trigger
        )

        // Enregistrer la notification
        do {
            UNUserNotificationCenter.current()
                .add(request )
            customLog.info(
                "ToDo daily notification added to Notifcation Center."
            )
        }
    }

    func removeNextReminderNotification() async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [backgroundTaskIdentifier]
            )
    }
}
