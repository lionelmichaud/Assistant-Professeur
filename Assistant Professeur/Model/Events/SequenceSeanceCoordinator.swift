//
//  SequenceSeanceCoordinator.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/07/2023.
//

import AppFoundation
import EventKit
import Foundation

/// Synchronise les séances à venir et les progression d'activité
/// - Synchronise les séances à venir d'une classe avec la progresison pédagogique prévue.
/// - Synchronise les dates de début et fin de progression d'activité à venir d'une classe avec les dates des  séances à venir.
enum SequenceSeanceCoordinator {
    /// Renseigne les dates de début et de fin des séances à venir `intervalSeances` d'une classe
    /// en fonction des `progresses` dans les activités de  la classe.
    /// Renseigne les activités pédagogiques abordées lors de chacune des séances à venir .
    /// de `intervalSeances` en exploitant les `progresses`.
    /// - Parameters:
    ///   - intervalSeances: séances à venir de la classe
    ///   - progresses: progression annuelle de chaque activité de la classe
    /// - Attention: Seules les progressions non encore achevées sont utilisées.
    /// - Attention: Les activités de durée nulle ne sont pas prises en compte.
    /// - Precondition: Les `progresses` doivent être triés par Séquences/Activités croissantes.
    static func synchronize(
        classeSeances intervalSeances: inout SeancesInDateInterval,
        withProgresses progresses: [ActivityProgressEntity]
    ) {
        // Renseigne les dates de début et de fin des activités d'une classe
        // qui n'ont pas encore été achevées en fonction des séances de `intervalSeances`.
        SequenceSeanceCoordinator.synchronize(
            classeProgresses: progresses,
            withSeances: intervalSeances
        )

        for seanceIdx in intervalSeances.seances.indices {
            let seanceStartDate = intervalSeances[seanceIdx].interval.start
            let seanceEndDate = intervalSeances[seanceIdx].interval.end

            // rechercher toutes les progressions non commencées ou en cours, de durée non nulle et
            // qui commencent ou se terminent durant la séance
            progresses.forEach { progress in
                guard let activity = progress.activity,
                      progress.status == .notStarted || progress.status == .inProgress,
                      progress.startDate != progress.endDate else {
                    return
                }

                let activityStartDate = progress.startDate
                let activityEndDate = progress.endDate

                if let activityStartDate,
                   seanceEndDate <= activityStartDate {
                    // l'activité débute à ou après la fin de la séance
                    return
                } else if let activityStartDate, let activityEndDate,
                          (seanceStartDate ... seanceEndDate).contains(activityStartDate),
                          (seanceStartDate ... seanceEndDate).contains(activityEndDate) {
                    // l'activité commence et se termine pendant la séance
                    intervalSeances[seanceIdx].activities.append(activity)

                } else if let activityEndDate,
                          (1.seconds.from(seanceStartDate)! ... seanceEndDate).contains(activityEndDate) {
                    // l'activité se termine pendant la séance
                    intervalSeances[seanceIdx].activities.append(activity)

                } else if let activityStartDate,
                          (seanceStartDate ..< seanceEndDate).contains(activityStartDate) {
                    // l'activité commence pendant la séance
                    intervalSeances[seanceIdx].activities.append(activity)

                } else if let activityStartDate, let activityEndDate,
                          activityStartDate < seanceStartDate,
                          activityEndDate > seanceEndDate {
                    // l'activité commence avant la séance et se termine après la séance
                    intervalSeances[seanceIdx].activities.append(activity)
                }
            }
        }
    }

    /// Renseigne les dates de début et de fin des `progresses` des activités d'une classe
    /// qui n'ont pas encore été achevées en fonction des séances de `intervalSeances`.
    /// - Parameters:
    ///   - progresses: progression de chaque activité de la classe
    ///   - intervalSeances: séances à venir de la classe
    /// - Attention: Seules les débuts et fins des `progresses` non encore achevées sont renseignées.
    /// - Attention: Les activités de durée nulle ne sont pas prises en compte.
    /// - Precondition: Les `progresses` doivent être triés par Séquences/Activités croissantes.
    static func synchronize(
        classeProgresses progresses: [ActivityProgressEntity],
        withSeances intervalSeances: SeancesInDateInterval
    ) {
        let nbSeances: Int = intervalSeances.seances.count
        guard nbSeances > 0 else {
            return
        }
        var cumulatedDuration = 0.0
        var nbOfSeanceRequired = 0.0

        progresses.forEach { progress in
            guard let activity = progress.activity, activity.duration > 0 else {
                return
            }

            switch progress.status {
                case .notStarted:
                    // nb de seances requisent pour réaliser l'activité noncommencée
                    nbOfSeanceRequired = activity.duration

                case .inProgress:
                    // nb de seances requisent pour compléter l'activité en cours
                    nbOfSeanceRequired =
                        activity.duration * (1.0 - progress.progress)

                case .completed, .invalid:
                    // do nothing
                    progress.startDate = nil
                    progress.endDate = nil
                    return
            }

            // Date de début de l'activité
            let startIdx = Int(cumulatedDuration.rounded(.towardZero))
            if startIdx < nbSeances {
                progress.startDate = intervalSeances[startIdx].interval.start
            } else {
                progress.startDate = nil
            }

            // Durée cumulée à la fin de la séance (en nombre de séance)
            cumulatedDuration += nbOfSeanceRequired

            // Date de fin de l'activité
            var endIdx: Int
            if cumulatedDuration.rounded(.towardZero) == cumulatedDuration {
                endIdx = Int(cumulatedDuration.rounded(.towardZero)) - 1
            } else {
                endIdx = Int(cumulatedDuration.rounded(.towardZero))
            }
            if endIdx < nbSeances {
                progress.endDate = intervalSeances[endIdx].interval.end
            } else {
                progress.endDate = nil
            }
        }
    }

    static func plannedDateOfCurrentActivity(
        inProgram program: ProgramEntity,
        classeProgresses progresses: [ActivityProgressEntity],
        yearSeances seances: SeancesInDateInterval
    ) -> Date? {
        /// Marge éventuelle ayant précedée l'activité `activity`
        func interSequenceSeances(activity: ActivityEntity) -> Int {
            if activity.number == 1 {
                // Première activité de la séquence
                guard let sequence = activity.sequence,
                      sequence.number > 1 else {
                    // la séquence courante est la première
                    return 0
                }
                // Séquence courante
                let currentSequenceNumber = sequence.viewNumber
                // Séquence précédente
                let previousSequenceNumber = currentSequenceNumber - 1
                let previousSequence = program.sequencesSortedByNumber[previousSequenceNumber]
                return previousSequence.viewMargePostSequence

            } else {
                return 0
            }
        }

        let nbSeances: Int = seances.seances.count
        guard nbSeances > 0 else {
            return nil
        }
        var cumulatedDuration = 0.0
        var nbOfSeanceRequired = 0.0

        progresses.forEach { progress in
            guard let activity = progress.activity,
                  activity.duration > 0 else {
                return
            }

            switch progress.status {
                case .completed:
                    // nb de seances requisent pour réaliser l'activité terminée
                    nbOfSeanceRequired = activity.duration

                case .inProgress:
                    // nb de seances requisent pour réaliser l'activité en cours
                    nbOfSeanceRequired =
                        activity.duration * progress.progress

                case .invalid, .notStarted:
                    // do nothing
                    return
            }
            // Marge éventuelle ayant précedée l'activité
            let preMargin = interSequenceSeances(activity: activity)

            // Durée cumulée à la fin de la séance (en nombre de séance)
            cumulatedDuration += (Double(preMargin) + nbOfSeanceRequired)
        }

        // Date de fin de l'activité
        var endIdx: Int
        if cumulatedDuration.rounded(.towardZero) == cumulatedDuration {
            endIdx = Int(cumulatedDuration.rounded(.towardZero)) - 1
        } else {
            endIdx = Int(cumulatedDuration.rounded(.towardZero))
        }
        if endIdx < nbSeances {
            return seances[endIdx].interval.end
        } else {
            return nil
        }
    }
}
