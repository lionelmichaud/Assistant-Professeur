//
//  AgendaManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/04/2023.
//

import AppFoundation
import Foundation

enum AmPm: String {
    case morning = "Matin"
    case afternoon = "Après-midi"

    static func partOfTheDay(of date: Date) -> AmPm {
        Calendar.current.component(.hour, from: date) <= 12 ?
            .morning :
            .afternoon
    }
}

struct AgendaManager {
    @Preference(\.hourOfFirstSeance)
    private static var hourOfFirstSeance

    @Preference(\.minutesOfFirstSeance)
    private static var minutesOfFirstSeance

    @Preference(\.seanceDuration)
    private static var seanceDuration

    @Preference(\.interSeancesDuration)
    private static var interSeancesDuration

    @Preference(\.recreationDuration)
    private static var recreationDuration

    @Preference(\.lunchDuration)
    private static var lunchDuration

    static var shared = AgendaManager()

    /// Horaire des heures de cours quotidiennes
    var seances = [DateInterval]()

    // MARK: - Subscripts

    subscript(index: Int) -> AmPm? {
        if seances.indices.contains(index) {
            return AmPm.partOfTheDay(of: seances[index].start)
        } else {
            return nil
        }
    }

    subscript(index: Int) -> DateInterval? {
        get {
            if seances.indices.contains(index) {
                return seances[index]
            } else {
                return nil
            }
        }
        set(newValue) {
            if let newValue, seances.indices.contains(index) {
                seances[index] = newValue
            }
        }
    }

    // MARK: - Type Methods

    static func dateOfFirstSeance() -> Date {
        Calendar.current.date(
            bySettingHour: hourOfFirstSeance,
            minute: minutesOfFirstSeance,
            second: 0,
            of: Date.now
        )!
    }

    // MARK: - Initializers

    /// Initialise toutes les heures de cours **à la date du jour**
    private init() {
        seances = Array(repeating: DateInterval(), count: 8)
        update()
    }

    // MARK: - Methods

    mutating func update() {
        // 1ère heure de cours du matin
        seances[0] =
            DateInterval(
                start: AgendaManager.dateOfFirstSeance(),
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 2ième heure de cours du matin
        var next =
            seances[0]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration * 60))
        seances[1] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 3ième heure de cours du matin
        next =
            seances[1]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.recreationDuration * 60))
        seances[2] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 4ième heure de cours du matin
        next =
            seances[2]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration * 60))
        seances[3] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 1ère heure de cours de l'après-midi
        next =
            seances[3]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.lunchDuration * 60))
        seances[4] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 2ième heure de cours de l'après-midi
        next =
            seances[4]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration * 60))
        seances[5] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 3ième heure de cours de l'après-midi
        next =
            seances[5]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.recreationDuration * 60))
        seances[6] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )

        // 4ième heure de cours de l'après-midi
        next =
            seances[6]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration * 60))
        seances[7] =
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration * 60)
            )
    }

    /// Durée d'une séance de cours en minutes
    func seanceDuration() -> DateComponents {
        AgendaManager.seanceDuration.minutes
    }

    /// Retourne la séance en cours à la `date`
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceOngoing(at date: Date) -> DateInterval? {
        seances.first(where: { $0.contains(date) })
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

    /// Temps écoulé en **heures - minutes - secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul.
    ///                         Si nil alors calcul fait à la date courante
    func elapsedTime(to thisDate: Date? = nil) -> DateComponents? {
        let date = thisDate ?? .now
        if let seance = seanceOngoing(at: date) {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: seance.start,
                to: date
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

    /// Temps restant en **heures - minutes - secondes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    ///                         Si nil alors calcul fait à la date courante
    func remainingTime(from thisDate: Date? = nil) -> DateComponents? {
        let date = thisDate ?? .now
        if let seance = seanceOngoing(at: date) {
            return Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: date,
                to: seance.end
            )
        } else {
            return nil
        }
    }
}
