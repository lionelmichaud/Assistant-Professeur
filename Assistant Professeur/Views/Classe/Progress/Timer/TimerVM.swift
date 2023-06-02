//
//  TimerVM.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/05/2023.
//

import EventKit
import Foundation

struct TimerVM {
    // MARK: - Properties

    /// Séances du jour
    private var seances = [EKEvent]()

    // MARK: - Initializers

    init() {}

    // MARK: - Properties

    /// Charge toutes les séance de la journée pour les
    /// `discipline`, `classe` et `schoolName`.
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: La classe recherchée.
    ///   - schoolName: L'école recherchée.
    mutating func loadTodaySeances(
        forDiscipline discipline: Discipline,
        forClasse classe: String,
        schoolName: String
    ) async {
        self.seances = await EventManager.getTodaySeances(
            forDiscipline: discipline,
            forClasse: classe,
            inCalendarNamed: schoolName
        )
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

    /// Durée de la séance en cours à la `date`.
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceDuration(at thisDate: Date? = nil) -> DateComponents? {
        let date = thisDate ?? .now
        if let ongoingSeance = seanceOngoing(at: date) {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: ongoingSeance.start,
                to: ongoingSeance.end
            )
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
        return elapsedTime(to: thisDate)?.second
    }

    /// Temps écoulé en **minutes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedMinutes(to thisDate: Date? = nil) -> Int? {
        return elapsedTime(to: thisDate)?.minute
    }

    /// Temps restant en **heures - minutes - secondes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
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
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func remainingSeconds(from thisDate: Date? = nil) -> Int? {
        return remainingTime(from: thisDate)?.second
    }

    /// Temps restant en **minutes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func remainingMinutes(from thisDate: Date? = nil) -> Int? {
        return remainingTime(from: thisDate)?.minute
    }
}
