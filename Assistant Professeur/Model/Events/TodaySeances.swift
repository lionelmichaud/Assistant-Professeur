//
//  self.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/05/2023.
//

import ActivityKit
import AppFoundation
import BackgroundTasks
import EventKit
import Foundation
import os
import UserNotifications

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Fundation-Package",
    category: "TodaySeances"
)

/// Mémorise les séances de la journée pour un ou plusieurs établissements.
///
///     @State
///     private var viewModel = TodaySeances.shared
///
///     // (1) Charge les séances de la journée pour tous les établissements
///     await viewModel.loadTodaySeances()
///
///     // (2) Recherche et mémoriser la séance en cours à la `date` dans  `school`
///     viewModel.findOngoingSeance(inSchool: school, at: .now)
///
///     // (3) Utiliser la séance en cours (s'il en existe une)
///     if let viewModel.seanceOngoing {
///         print("Une séance est en cours")
///     }
///
///     // (4) Remettre à zéro la séance en cours
///     viewModel.resetOngoingSeance()
///
@Observable final class TodaySeances {
    // MARK: - Singleton

    static var shared = TodaySeances()

    // MARK: - Properties

    /// Identifiant de la BackgroundTask
    let liveActivityTaskIdentifier = "LIVE_COUNTDOWN"
    let backgroundUpdatePeriod: Int = 30 // seconds

    private(set) var seanceOngoing: Seance?

    /// Séances du jour par établissement
    private(set) var seances = [SchoolEntity: Seances]()

    /// Calendriers des établissements
    private(set) var calendars = [SchoolEntity: EKCalendar]()

    /// Date de dernière mise à jour
    private(set) var lastUpdateDate: Date?

    // MARK: - Initializers

    private init() {}

    // MARK: - Chargement des sénaces

    /// Charge toutes les séances de la journée pour tous les étabissements,
    /// toutes les disciplines et toutes les classes.
    ///
    ///     @State
    ///     private var self = TodaySeances.shared
    ///
    ///     await self.loadTodaySeances()
    ///
    ///     self.findOngoingSeance(inSchool: school, at: .now)
    ///
    /// - Important: Cette méthode doit être appelée en premier pour que les autres méthode donnent un résulat non `nil`.
    ///
    func loadTodaySeances() async {
        // Demander les droits d'accès aux calendriers de l'utilisateur
        let eventStore = EKEventStore()
        var schools = [SchoolEntity]()
        await SchoolEntity.context.perform {
            schools = SchoolEntity.all()
        }

        for school in schools {
            var calendar: EKCalendar?
            var alert = AlertInfo()
            var calendarName = ""
            await SchoolEntity.context.perform {
                calendarName = school.viewName
            }
            (
                calendar,
                alert.isPresented,
                alert.title,
                alert.message
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: calendarName
                )
            guard let calendar else {
                continue
            }
            calendars[school] = calendar

            var classeNames = [String]()
            // Récupérer la liste des noms des classe de cet établissement
            await SchoolEntity.context.perform {
                classeNames = school.allClasses.map(\.displayString)
            }
            seances[school] = EventManager.getTodayEvents(
                inCalendar: calendar,
                inEventStore: eventStore
            ).compactMap { event in
                // Le nom de l'événement contient-il le nom d'une des classes
                // de l'établissement ?
                for classeName in classeNames where event.title.contains(classeName) {
                    return Seance(
                        name: classeName,
                        schoolName: calendarName,
                        interval: DateInterval(
                            start: event.startDate,
                            end: event.endDate
                        )
                    )
                }
                return nil
            }
        }

        if !calendars.isEmpty {
            lastUpdateDate = .now
        }
    }

    /// Charge toutes les séances de la journée pour tous les étabissements,
    /// toutes les disciplines et toutes les classes.
    ///
    ///     @State
    ///     private var self = TodaySeances.shared
    ///
    ///     await self.loadTodaySeances()
    ///
    ///     self.findOngoingSeance(inSchool: school, at: .now)
    ///
    /// - Important: Cette méthode doit être appelée en premier pour que les autres méthode donnent un résulat non `nil`.
    ///
    func loadTodaySeances(
        forSchool school: SchoolEntity
    ) async {
        // Demander les droits d'accès aux calendriers de l'utilisateur
        let eventStore = EKEventStore()
        var calendar: EKCalendar?
        var alert = AlertInfo()
        var calendarName = ""
        var classeNames = [String]()
        await SchoolEntity.context.perform {
            calendarName = school.viewName
            classeNames = school.allClasses.map(\.displayString)
        }
        (
            calendar,
            alert.isPresented,
            alert.title,
            alert.message
        ) = await EventManager.shared
            .requestCalendarAccess(
                eventStore: eventStore,
                calendarName: calendarName
            )
        guard let calendar else {
            return
        }
        calendars[school] = calendar

        seances[school] = EventManager.getTodayEvents(
            inCalendar: calendar,
            inEventStore: eventStore
        ).compactMap { event in
            // Le nom de l'événement contient-il le nom d'une des classes
            // de l'établissement ?
            for classeName in classeNames where event.title.contains(classeName) {
                return Seance(
                    name: classeName,
                    schoolName: calendarName,
                    interval: DateInterval(
                        start: event.startDate,
                        end: event.endDate
                    )
                )
            }
            return nil
        }

        if !calendars.isEmpty {
            lastUpdateDate = .now
        }
    }

    // MARK: - Mémorisation de la séance en cours

    /// Recherche et mémoriser la séance en cours à la `date` dans  `school`.
    ///
    ///     @State
    ///     private var self = TodaySeances.shared
    ///
    ///     await self.loadTodaySeances()
    ///
    ///     self.findOngoingSeance(inSchool: school, at: .now)
    ///
    ///     if let self.seanceOngoing {
    ///         print("Une séance est en cours")
    ///     }
    ///
    /// - Important: Cette méthode doit être appelée en second pour que les autres méthode donnent un résulat non `nil`.
    @MainActor
    func findOngoingSeance(
        inSchool school: SchoolEntity,
        at date: Date = .now
    ) {
        seanceOngoing = seanceOngoing(
            inSchool: school,
            at: date
        )
    }

    @MainActor
    func resetOngoingSeance() async {
        seanceOngoing = nil
    }

    // MARK: - Recherche de la séance en cours

    /// Retourne la séance en cours à la `date` dans  `school`.
    /// - Returns: `nil` si aucune séance n'est en cours.
    ///
    ///     @State
    ///     private var self = TodaySeances.shared
    ///
    ///     await self.loadTodaySeances()
    ///
    ///     if let seance = self.seanceOngoing(inSchool: school, at: .now)
    ///         print("Une séance est en cours")
    ///     }
    ///
    /// - Warning: Cette méthode ne modifie pas l'état interne de l'objet. Les autres méthode donneront un résulat `nil`
    ///
    func seanceOngoing(
        inSchool school: SchoolEntity,
        at date: Date = .now
    ) -> Seance? {
        seances[school]?.first { $0.interval.contains(date) }
    }
}

// MARK: - Info sur la séance en cours

extension TodaySeances {
    /// Durée de la séance en cours à la `date` exprimée en **secondes**.
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceDuration() -> Int? {
        if let seconds = seanceOngoing?.interval.duration {
            if seconds > 0 {
                return Int(seconds)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    /// Temps écoulé en **heures - minutes - secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul.
    ///                         Si nil alors calcul fait à la date courante
    func elapsedTime(
        to thisDate: Date = .now
    ) -> DateComponents? {
        if let seanceOngoing {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: seanceOngoing.interval.start,
                to: thisDate
            )
        } else {
            return nil
        }
    }

    /// Temps écoulé en **secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedSeconds(
        to thisDate: Date = .now
    ) -> Int? {
        guard let elapsedTime = elapsedTime(to: thisDate),
              let hours = elapsedTime.hour,
              let minutes = elapsedTime.minute,
              let seconds = elapsedTime.second else {
            return nil
        }
        return hours * 60 * 60 + minutes * 60 + seconds
    }

    /// Temps écoulé en **minutes** depuis le début de la séance.
    /// - Returns: Temps écoulé en minutes entières
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedMinutes(
        to thisDate: Date = .now
    ) -> Int? {
        guard let elapsedTime = elapsedTime(to: thisDate),
              let hours = elapsedTime.hour,
              let minutes = elapsedTime.minute else {
            return nil
        }
        return hours * 60 + minutes
    }

    /// Temps restant en **heures - minutes - secondes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul.
    ///                         Si nil alors calcul fait à la date courante
    func remainingTime(
        from thisDate: Date = .now
    ) -> DateComponents? {
        if let seanceOngoing {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: thisDate,
                to: seanceOngoing.interval.end
            )
        } else {
            return nil
        }
    }

    /// Temps restant en **secondes** avant la fin de la séance.
    /// - Returns: Temps restant en secondes
    /// - Parameter thisDate: Date/heure à laquelle faire le calcul
    func remainingSeconds(
        from thisDate: Date = .now
    ) -> Int? {
        guard let remainingTime = remainingTime(from: thisDate),
              let hours = remainingTime.hour,
              let minutes = remainingTime.minute,
              let seconds = remainingTime.second else {
            return nil
        }
        return hours * 60 * 60 + minutes * 60 + seconds
    }

    /// Temps restant en **minutes** avant la fin de la séance.
    /// - Returns: Temps restant en minutes
    /// - Parameter thisDate: Date/heure à laquelle faire le calcul
    func remainingMinutes(
        from thisDate: Date = .now
    ) -> Int? {
        guard let remainingTime = remainingTime(from: thisDate),
              let hours = remainingTime.hour,
              let minutes = remainingTime.minute else {
            return nil
        }
        return hours * 60 + minutes
    }

    /// Retourne la zone dans laquelle se trouve le temps restant.
    /// - Note: `.normal` si Temps restant > `seuilWarning`
    /// - Note: `.warning` si `seuilWarning` > Temps restant > `seuilAlert`
    /// - Note: `.alert` si `seuilAlert` > Temps restant
    /// - Parameters:
    ///   - date: Date/heure à laquelle faire le calcul
    ///   - seuilAlert: Seuil d'alerte en minutes.
    ///   - seuilWarning: Seuil de warning en minutes > `seuilAlert`.
    func timerZone(
        for date: Date,
        seuilAlert: Int,
        seuilWarning: Int
    ) -> TimerZone {
        guard let remainingMinutes = remainingMinutes(from: date) else {
            return .undefined
        }

        switch remainingMinutes + 1 {
            case 0 ... seuilAlert:
                return .alert

            case seuilAlert ... seuilWarning:
                return .warning

            default:
                return .normal
        }
    }

    /// Position du curseur en % [0; 1]
    func cursorValue(
        for date: Date = .now
    ) -> Double? {
        if let elapsedMinutes = elapsedMinutes(to: date)?.double(),
           let seanceDuration = seanceDuration()?.double() {
            return (elapsedMinutes / (seanceDuration / 60.0))
        } else {
            return nil
        }
    }
}

// MARK: - Gestion d'une Live Activity associée à la séance en cours

extension TodaySeances {
    func schedulNextUpdate() {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        guard let elapsedSeconds = TodaySeances.shared.elapsedSeconds(),
              TimeInterval(elapsedSeconds) <= seanceOngoing.interval.duration else {
//            (TimeInterval(elapsedSeconds) + TimeInterval(backgroundUpdatePeriod)) <= seanceOngoing.interval.duration else {
            return
        }

        let request = BGAppRefreshTaskRequest(identifier: liveActivityTaskIdentifier)
        request.earliestBeginDate = nextWakeupDate()
        do {
            /* sending the request to the Scheduler so it can be kept by the system.
             This is the last step of the process and now we are good when
             the background task scheduler calls our app on the scheduled date
             */
            try BGTaskScheduler.shared.submit(request)
            customLog.log(
                level: .info,
                "LiveActivity background Task Scheduled"
            )

        } catch {
            customLog.log(
                level: .error,
                "LiveActivity scheduling Error: \(error.localizedDescription)"
            )
        }
    }

    private func nextWakeupDate() -> Date {
        backgroundUpdatePeriod.seconds.fromNow!
    }

    /// Démarrer la Live Activity
    func startLiveActivity(
        alertRemainingMinutes: Int,
        warningRemainingMinutes: Int
    ) async {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        let initialState =
            LiveCoursProgressState(
                elapsedMinutes: self.elapsedMinutes(to: .now),
                remainingMinutes: self.remainingMinutes(from: .now),
                cursorValue: self.cursorValue(for: .now),
                timerZone: self.timerZone(
                    for: .now,
                    seuilAlert: alertRemainingMinutes,
                    seuilWarning: warningRemainingMinutes
                )
            )
        let attribute =
            LiveCoursProgressFixedAttributes(
                seance: seanceOngoing.interval,
                schoolName: seanceOngoing.schoolName ?? "",
                classeName: seanceOngoing.name ?? "",
                warningRemainingMinutes: warningRemainingMinutes,
                alertRemainingMinutes: alertRemainingMinutes
            )
        await LiveActivityManager.shared.start(
            withInitialState: initialState,
            fixedAttributes: attribute
        )
        #if DEBUG
            print(">> Activité lancée")
        #endif
    }

    /// Mettre à jour périodiquement la Live Activity
    func periodicUpdateOfLiveActivity(
        alertRemainingMinutes: Int,
        warningRemainingMinutes: Int
    ) async {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        var keepOnLooping = true
        repeat {
            await updateLiveActivity(
                alertRemainingMinutes: alertRemainingMinutes,
                warningRemainingMinutes: warningRemainingMinutes
            )

            do {
                try await Task.sleep(for: .seconds(backgroundUpdatePeriod)) // exception thrown when cancelled by SwiftUI when this view disappears.
            } catch is CancellationError {
                // If the task is cancelled before the time ends, this function throws CancellationError
                break
            } catch {
                customLog.log(
                    level: .error,
                    "LiveActivity Task.sleep Error: \(error.localizedDescription)"
                )
                break
            }

            if let elapsedSeconds = self.elapsedSeconds() {
//                keepOnLooping = (TimeInterval(elapsedSeconds) + updatePeriod) < seanceOngoing.interval.duration
                keepOnLooping = TimeInterval(elapsedSeconds) < seanceOngoing.interval.duration
            } else {
                keepOnLooping = false
            }
        } while !Task.isCancelled && keepOnLooping
    }

    /// Mise à jour unitaire de la Live Activity
    func updateLiveActivity(
        alertRemainingMinutes: Int,
        warningRemainingMinutes: Int
    ) async {
        var alertConfig: AlertConfiguration?
        // code you want to repeat
        // Update périodique de la Live Activity
        // TODO: - Gérer le déclenchement des message d'alerte dans Live Activity
        if false {
            alertConfig = AlertConfiguration(
                title: "Title",
                body: "Body",
                sound: .default
            )
        }
        let newState =
            LiveCoursProgressState(
                elapsedMinutes: self.elapsedMinutes(to: .now),
                remainingMinutes: self.remainingMinutes(from: .now),
                cursorValue: self.cursorValue(for: .now),
                timerZone: self.timerZone(
                    for: .now,
                    seuilAlert: alertRemainingMinutes,
                    seuilWarning: warningRemainingMinutes
                )
            )
        await LiveActivityManager.shared.update(
            withNewState: newState,
            alertConfiguration: alertConfig
        )
    }

    /// Arrêter la Live Activity
    func endLiveActivity(
        alertRemainingMinutes: Int,
        warningRemainingMinutes: Int
    ) async {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        var finalState: LiveCoursProgressState
        if Task.isCancelled {
            // Tâche annulée par la disparition de la View avant la fin du cours
            finalState = LiveCoursProgressState(
                elapsedMinutes: self.elapsedMinutes(to: .now),
                remainingMinutes: self.remainingMinutes(from: .now),
                cursorValue: self.cursorValue(for: .now),
                timerZone: self.timerZone(
                    for: .now,
                    seuilAlert: alertRemainingMinutes,
                    seuilWarning: warningRemainingMinutes
                )
            )
        } else {
            // Fin du cours avant la disparition de la View
            finalState = LiveCoursProgressState(
                elapsedMinutes: 1,
                remainingMinutes: 0,
                cursorValue: 1.0,
                timerZone: .alert
            )
        }
        await LiveActivityManager.shared.end(
            withFinalState: finalState
        )
        await self.resetOngoingSeance()
        #if DEBUG
            print(">> Activité canceled")
        #endif
    }
}

// MARK: - Notifications

extension TodaySeances {
    /// Envoyer une notification  à l'utilisateur
    func sendWarningNotification(
        warningRemainingMinutes: Int
    ) {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        // Définir le contenu affichable de la notification
        let content = UNMutableNotificationContent()
        content.title = "Fin du cours dans \(warningRemainingMinutes) minutes"

        // content.subtitle = printStr + loadStr + "Consultez-en la liste!"
        content.sound = .default

        // Définir le déclecncheur
        guard let date = warningRemainingMinutes.minutes.before(seanceOngoing.interval.end),
              date > 10.seconds.fromNow! else {
            return
        }
        var dateComp = DateComponents()
        dateComp.hour = date.hours
        dateComp.minute = date.minutes
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComp,
            repeats: true
        )

        // Définir la requête
        let request = UNNotificationRequest(
            identifier: "WARNING_NOTIFICATION",
            content: content,
            trigger: trigger
        )

        // Enregistrer la notification
        do {
            UNUserNotificationCenter.current()
                .add(request )
            customLog.log(
                level: .info,
                "Warning notification added to Notifcation Center."
            )
        }
    }

    /// Envoyer une notification  à l'utilisateur
    func sendAlertNotification(
        alertRemainingMinutes: Int
    ) {
        guard let seanceOngoing = seanceOngoing else {
            return
        }

        // Définir le contenu affichable de la notification
        let content = UNMutableNotificationContent()
        content.title = "Fin du cours dans \(alertRemainingMinutes) minutes"

        // content.subtitle = printStr + loadStr + "Consultez-en la liste!"
        content.sound = .default

        // Définir le déclecncheur
        guard let date = alertRemainingMinutes.minutes.before(seanceOngoing.interval.end),
              date > 10.seconds.fromNow! else {
            return
        }
        var dateComp = DateComponents()
        dateComp.hour = date.hours
        dateComp.minute = date.minutes
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComp,
            repeats: true
        )

        // Définir la requête
        let request = UNNotificationRequest(
            identifier: "ALERT_NOTIFICATION",
            content: content,
            trigger: trigger
        )

        // Enregistrer la notification
        do {
            UNUserNotificationCenter.current()
                .add(request )
            customLog.log(
                level: .info,
                "Warning notification added to Notifcation Center."
            )
        }
    }
}
