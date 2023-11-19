//
//  TimerVM.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/05/2023.
//

import AppFoundation
import EventKit
import Foundation

struct TodaySeances {
    // MARK: - Singleton

    static var shared = TodaySeances()

    // MARK: - Properties

    /// Calendriers des établissements
    private(set) var seances = [SchoolEntity: [EKEvent]]()

    /// Séances du jour par établissement
    private(set) var calendars = [SchoolEntity: EKCalendar]()

    /// Date de dernière mise à jour
    private(set) var lastUpdateDate: Date?

    // MARK: - Initializers

    private init() {}

    // MARK: - Chargement des sénaces

    /// Charge toutes les séances de la journée pour tous les étabissements,
    /// toutes les disciplines et toutes les classes.
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
            seances[school] = EventManager.getTodayEvents(
                inCalendar: calendar,
                inEventStore: eventStore
            )
            await filterSeances(forSchool: school)
        }

        if !calendars.isEmpty {
            lastUpdateDate = .now
        }
    }

    /// Charge toutes les séances de la journée pour tous les étabissements,
    /// toutes les disciplines et toutes les classes.
    mutating func loadTodaySeances(
        forSchool school: SchoolEntity
    ) async {
        // Demander les droits d'accès aux calendriers de l'utilisateur
        let eventStore = EKEventStore()
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
            return
        }

        calendars[school] = calendar
        seances[school] = EventManager.getTodayEvents(
            inCalendar: calendar,
            inEventStore: eventStore
        )
        await filterSeances(forSchool: school)

        if !calendars.isEmpty {
            lastUpdateDate = .now
        }
    }

    /// Ne concerver que les événements qui contiennent
    /// le nom d'une des classes de l'établissemeent.
    private mutating func filterSeances(forSchool school: SchoolEntity) async {
        if seances.isNotEmpty {
            var classeNames = [String]()
            // Récupérer la liste des noms des classe de cet établissement
            await SchoolEntity.context.perform {
                classeNames = school.allClasses.map(\.displayString)
            }
            seances[school] = seances[school]?.filter { event in
                // Le nom de l'événement contient-il le nom d'une des classes
                // de l'établissement ?
                for classeName in classeNames where event.title.contains(classeName) {
                    return true
                }
                return false
            }
        }
    }

    // MARK: - Vérification de séance en cours

    /// Retourne la séance en cours à la `date` dans  `school`.
    /// - Returns: `nil` si aucune séance n'est en cours.
    func seanceOngoing(
        inSchool school: SchoolEntity,
        at date: Date = .now
    ) -> DateInterval? {
        if let seances = seances[school],
           let seance =
           seances.first(
               where: { seance in
                   (seance.startDate ... seance.endDate).contains(date)
               }
           ) {
            return DateInterval(
                start: seance.startDate,
                end: seance.endDate
            )
        } else {
            return nil
        }
    }

    // MARK: - Info sur la séance en cours

    /// Durée de la séance en cours à la `date` exprimée en **secondes**.
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceDuration(
        inSchool school: SchoolEntity,
        at thisDate: Date? = nil
    ) -> Int? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(
            inSchool: school,
            at: date
        ) {
            let seconds = ongoingSeance.duration
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
        inSchool school: SchoolEntity,
        to thisDate: Date? = nil
    ) -> DateComponents? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(
            inSchool: school,
            at: date
        ) {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: ongoingSeance.start,
                to: date
            )
        } else {
            return nil
        }
    }

    /// Temps écoulé en **secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedSeconds(
        inSchool school: SchoolEntity,
        to thisDate: Date? = nil
    ) -> Int? {
        guard let elapsedTime = elapsedTime(inSchool: school, to: thisDate),
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
        inSchool school: SchoolEntity,
        to thisDate: Date? = nil
    ) -> Int? {
        guard let elapsedTime = elapsedTime(inSchool: school, to: thisDate),
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
        inSchool school: SchoolEntity,
        from thisDate: Date? = nil
    ) -> DateComponents? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(inSchool: school, at: date) {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: date,
                to: ongoingSeance.end
            )
        } else {
            return nil
        }
    }

    /// Temps restant en **secondes** avant la fin de la séance.
    /// - Returns: Temps restant en secondes
    /// - Parameter thisDate: Date/heure à laquelle faire le calcul
    func remainingSeconds(
        inSchool school: SchoolEntity,
        from thisDate: Date? = nil
    ) -> Int? {
        guard let remainingTime = remainingTime(inSchool: school, from: thisDate),
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
        inSchool school: SchoolEntity,
        from thisDate: Date? = nil
    ) -> Int? {
        guard let remainingTime = remainingTime(inSchool: school, from: thisDate),
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
        inSchool school: SchoolEntity,
        for date: Date?,
        seuilAlert: Int,
        seuilWarning: Int
    ) -> TimerZone {
        guard let remainingMinutes = remainingMinutes(inSchool: school, from: date) else {
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
        inSchool school: SchoolEntity,
        for date: Date?
    ) -> Double? {
        if let elapsedMinutes = elapsedMinutes(inSchool: school, to: date)?.double(),
           let seanceDuration = seanceDuration(inSchool: school, at: date)?.double() {
            return (elapsedMinutes / (seanceDuration / 60.0))
        } else {
            return nil
        }
    }
}
