//
//  AgendaManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/04/2023.
//

import Foundation

struct AgendaManager {
    @Preference(\.timeOfFirstSeance)
    private static var timeOfFirstSeance
    private static var dateOfFirstSeance: Date = {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        return timeOfFirstSeance.from(startOfDay)!
    }()

    @Preference(\.seanceDuration)
    private static var seanceDuration

    @Preference(\.interSeancesDuration)
    private static var interSeancesDuration

    @Preference(\.recreationDuration)
    private static var recreationDuration

    @Preference(\.lunchDuration)
    private static var lunchDuration

    static let shared = AgendaManager()

    /// Horaire des heures de cours quotidiennes
    var seances = [DateInterval]()

    /// Initialise toutes les heures de cours **à la date du jour**
    private init() {
        // 1ère heure de cours du matin
        seances.append(
            DateInterval(
                start: AgendaManager.dateOfFirstSeance,
                duration: TimeInterval(AgendaManager.seanceDuration.minute! * 60)
            ))

        // 2ième heure de cours du matin
        var next =
            seances[0]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute! * 60)
            ))

        // 3ième heure de cours du matin
        next =
            seances[1]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.recreationDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute!.double() * 60)
            ))

        // 4ième heure de cours du matin
        next =
            seances[2]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute!.double() * 60)
            ))

        // 1ère heure de cours de l'après-midi
        next =
            seances[3]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.lunchDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute! * 60)
            ))

        // 2ième heure de cours de l'après-midi
        next =
            seances[4]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute! * 60)
            ))

        // 3ième heure de cours de l'après-midi
        next =
            seances[5]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.recreationDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute!.double() * 60)
            ))

        // 4ième heure de cours de l'après-midi
        next =
            seances[6]
                .end
                .addingTimeInterval(TimeInterval(AgendaManager.interSeancesDuration.minute! * 60))
        seances.append(
            DateInterval(
                start: next,
                duration: TimeInterval(AgendaManager.seanceDuration.minute!.double() * 60)
            ))
    }

    func seanceDuration() -> DateComponents {
        AgendaManager.seanceDuration
    }

    /// Retourne la séance en cours à la `date`
    /// - Returns: `nil` si aucune séance n'est en cours
    func seanceOngoing(at date: Date) -> DateInterval? {
        seances.first(where: { $0.contains(date) })
    }

    /// Temps écoulé en **secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedSeconds(to thisDate: Date?) -> Int? {
        return elapsedTime(to: thisDate)?.second
    }

    /// Temps écoulé en **minutes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedMinutes(to thisDate: Date?) -> Int? {
        return elapsedTime(to: thisDate)?.minute
    }

    /// Temps écoulé en **heures - minutes - secondes** depuis le début de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func elapsedTime(to thisDate: Date?) -> DateComponents? {
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
    func remainingSeconds(from thisDate: Date?) -> Int? {
        return remainingTime(from: thisDate)?.second
    }

    /// Temps restant en **minutes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func remainingMinutes(from thisDate: Date?) -> Int? {
        return remainingTime(from: thisDate)?.minute
    }

    /// Temps restant en **heures - minutes - secondes** avant la fin de la séance.
    /// - Returns: Temps écoulé en secondes
    /// - Parameter thisDate: date/heure à laquelle faire le calcul
    func remainingTime(from thisDate: Date?) -> DateComponents? {
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
