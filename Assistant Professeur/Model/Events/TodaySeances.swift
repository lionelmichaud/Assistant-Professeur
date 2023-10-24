//
//  TimerVM.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/05/2023.
//

import EventKit
import Foundation

struct TodaySeances {
    // MARK: - Properties

    /// Séances du jour
    private var seances = [EKEvent]()

    // MARK: - Initializers

    init() {}

    // MARK: - Properties

    /// Charge toutes les séance de la journée pour les`discipline`, `classe` et `schoolName`
    /// ou pour l'ensemble des disciplines et classe de`schoolName`.
    /// - Parameters:
    ///   - discipline: La discipline recherchée ou `nil`.
    ///   - classe: La classe recherchée ou `nil`.
    ///   - schoolName: L'école recherchée.
    ///  - Note: Si `discipline` ou `classe` = `nil` alors toutes les séances sont chargées
    ///           quelque soient la classe ou la discipline.
    mutating func loadTodaySeances(
        forDiscipline discipline: Discipline? = nil,
        forClasse classe: String? = nil,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore
    ) {
        if let classe, let discipline {
            self.seances = EventManager.getTodaySeances(
                forDiscipline: discipline,
                forClasse: classe,
                inCalendar: calendar,
                inEventStore: eventStore
            )
        } else {
            self.seances = EventManager.getTodaySeances(
                inCalendar: calendar,
                inEventStore: eventStore
            )
        }
    }

    /// Retourne la séance en cours à la `date`.
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceOngoing(at date: Date) -> DateInterval? {
        if let seance = seances.first(where: { seance in
            (seance.startDate ... seance.endDate).contains(date)
        }) {
            return DateInterval(
                start: seance.startDate,
                end: seance.endDate
            )
        } else {
            return nil
        }
    }

    /// Durée de la séance en cours à la `date` exprimée en **secondes**.
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceDuration(at thisDate: Date? = nil) -> Int? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(at: date) {
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
    func elapsedTime(to thisDate: Date? = nil) -> DateComponents? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(at: date) {
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
    func elapsedSeconds(to thisDate: Date? = nil) -> Int? {
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
    func elapsedMinutes(to thisDate: Date? = nil) -> Int? {
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
    func remainingTime(from thisDate: Date? = nil) -> DateComponents? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(at: date) {
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
    func remainingSeconds(from thisDate: Date? = nil) -> Int? {
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
    func remainingMinutes(from thisDate: Date? = nil) -> Int? {
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
        for date: Date?,
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
    func cursorValue(for date: Date?) -> Double? {
        if let elapsedMinutes = elapsedMinutes(to: date)?.double(),
           let seanceDuration = seanceDuration(at: date)?.double() {
            return (elapsedMinutes / (seanceDuration / 60.0))
        } else {
            return nil
        }
    }
}
