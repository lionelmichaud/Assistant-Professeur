//
//  SequenceSeanceCoordinator.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/07/2023.
//

import EventKit
import Foundation

enum SequenceSeanceCoordinator {
    static func synchronize(
        classeSeances intervalSeances: DateIntervalSeances,
        withProgresses progresses: [ActivityProgressEntity]
    ) {
        SequenceSeanceCoordinator.synchronize(
            classeProgresses: progresses,
            withSeances: intervalSeances
        )

        intervalSeances.seances.forEach { seance in
            
        }
    }

    /// Renseigne les dates de début et de fin des activités d'une classe
    /// en fonction des séances à venir de la classe.
    /// - Parameters:
    ///   - progresses: progression de chaque activité de la classe
    ///   - seances: séances à venir de la classe
    static func synchronize(
        classeProgresses progresses: [ActivityProgressEntity],
        withSeances intervalSeances: DateIntervalSeances
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
                progress.startDate = intervalSeances.seances[startIdx].event.startDate
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
                progress.endDate = intervalSeances.seances[endIdx].event.endDate
            } else {
                progress.endDate = nil
            }
        }
    }
}
