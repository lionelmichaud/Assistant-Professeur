//
//  TimerVM.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/05/2023.
//

import AppFoundation
import EventKit
import Foundation

/// Mémorise les séances de la journée pour un ou plusieurs établissements.
///
///     @State
///     private var timerVM = TodaySeances.shared
///
///     // (1) Charge les séances de la journée pour tous les établissements
///     await timerVM.loadTodaySeances()
///
///     // (2) Recherche et mémoriser la séance en cours à la `date` dans  `school`
///     timerVM.findOngoingSeance(inSchool: school, at: .now)
///
///     // (3) Utiliser la séance en cours (s'il en existe une)
///     if let timerVM.seanceOngoing {
///         print("Une séance est en cours")
///     }
///
struct TodaySeances {
    // MARK: - Singleton

    static var shared = TodaySeances()

    // MARK: - Properties

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
    ///     private var timerVM = TodaySeances.shared
    ///
    ///     await timerVM.loadTodaySeances()
    ///
    ///     timerVM.findOngoingSeance(inSchool: school, at: .now)
    ///
    /// - Important: Cette méthode doit être appelée en premier pour que les autres méthode donnent un résulat non `nil`.
    ///
    mutating func loadTodaySeances() async {
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
    ///     private var timerVM = TodaySeances.shared
    ///
    ///     await timerVM.loadTodaySeances()
    ///
    ///     timerVM.findOngoingSeance(inSchool: school, at: .now)
    ///
    /// - Important: Cette méthode doit être appelée en premier pour que les autres méthode donnent un résulat non `nil`.
    ///
    mutating func loadTodaySeances(
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
    ///     private var timerVM = TodaySeances.shared
    ///
    ///     await timerVM.loadTodaySeances()
    ///
    ///     timerVM.findOngoingSeance(inSchool: school, at: .now)
    ///
    ///     if let timerVM.seanceOngoing {
    ///         print("Une séance est en cours")
    ///     }
    ///
    /// - Important: Cette méthode doit être appelée en second pour que les autres méthode donnent un résulat non `nil`.
    mutating func findOngoingSeance(
        inSchool school: SchoolEntity,
        at date: Date = .now
    ) {
        seanceOngoing = seanceOngoing(
            inSchool: school,
            at: date
        )
    }

    mutating func resetOngoingSeance() {
        seanceOngoing = nil
    }

    // MARK: - Recherche de la séance en cours

    /// Retourne la séance en cours à la `date` dans  `school`.
    /// - Returns: `nil` si aucune séance n'est en cours.
    ///
    ///     @State
    ///     private var timerVM = TodaySeances.shared
    ///
    ///     await timerVM.loadTodaySeances()
    ///
    ///     if let seance = timerVM.seanceOngoing(inSchool: school, at: .now)
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

    // MARK: - Info sur la séance en cours

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
