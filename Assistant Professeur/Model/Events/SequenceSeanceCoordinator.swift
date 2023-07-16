//
//  SequenceSeanceCoordinator.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/07/2023.
//

import EventKit
import Foundation

enum SequenceSeanceCoordinator {
    /// Renseigne les dates de début et de fin des activités d'une classe
    /// qui n'ont pas encore été achevées en fonction des séances de `intervalSeances`.
    /// Renseigne les activités pédagogiques abordées lors de chacune des séances
    /// de `intervalSeances` en exploitant les `progresses`.
    /// - Parameters:
    ///   - intervalSeances: séances à venir de la classe
    ///   - progresses: progression de chaque activité de la classe
    /// - Attention: Seules les progressions non encore achevées sont utilisées.
    /// - Precondition: Les `progresses` doivent être triés par Séquences/Activités croissantes.
    static func synchronize(
        classeSeances intervalSeances: inout SeancesInDateInterval,
        withProgresses progresses: [ActivityProgressEntity]
    ) {
        SequenceSeanceCoordinator.synchronize(
            classeProgresses: progresses,
            withSeances: intervalSeances
        )

        for seanceIdx in intervalSeances.seances.indices {
            guard let seanceStartDate = intervalSeances[seanceIdx].event.startDate,
                  let seanceEndDate = intervalSeances[seanceIdx].event.endDate else {
                // la séance n'est pas datée, on passe à la suivante
                continue
            }

            // rechercher toutes les progressions qui commencent ou se terminent
            // durant la séance
            progresses.forEach { progress in
                if let activity = progress.activity,
                   let activityStartDate = progress.startDate,
                   let activityEndDate = progress.endDate,
                   (seanceStartDate ... seanceEndDate).contains(activityStartDate),
                   (seanceStartDate ... seanceEndDate).contains(activityEndDate) {
                    // l'activité commence et se termine pendant la séance
                    intervalSeances[seanceIdx].activities.append(activity)
                } else {
                    if let activity = progress.activity,
                       let activityEndDate = progress.endDate,
                       (seanceStartDate ... seanceEndDate).contains(activityEndDate) {
                        // l'activité se termine pendant la séance
                        intervalSeances[seanceIdx].activities.append(activity)
                    }
                    if let activity = progress.activity,
                       let activityStartDate = progress.startDate,
                       (seanceStartDate ... seanceEndDate).contains(activityStartDate) {
                        // l'activité commence pendant la séance
                        intervalSeances[seanceIdx].activities.append(activity)
                    }
                }
                if let activity = progress.activity,
                   let activityStartDate = progress.startDate,
                   let activityEndDate = progress.endDate,
                   activityStartDate < seanceStartDate,
                   activityEndDate > seanceEndDate {
                    // l'activité commence avnt la séance et se termine après la séance
                    intervalSeances[seanceIdx].activities.append(activity)
                }
            }
        }
    }

    /// Renseigne les dates de début et de fin des activités d'une classe
    /// qui n'ont pas encore été achevées en fonction des séances de `intervalSeances`.
    /// - Parameters:
    ///   - progresses: progression de chaque activité de la classe
    ///   - intervalSeances: séances à venir de la classe
    /// - Attention: Seules les progressions non encore achevées sont renseignées.
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
            guard let activity = progress.activity else {
                return
            }

            switch progress.status {
                case .notStarted:
                    // nb de seances requisent pour réaliser l'activité
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
                progress.startDate = intervalSeances[startIdx].event.startDate
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
                progress.endDate = intervalSeances[endIdx].event.endDate
            } else {
                progress.endDate = nil
            }
        }
    }
}
