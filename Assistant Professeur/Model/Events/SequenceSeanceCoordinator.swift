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
        classeProgresses progresses: [ActivityProgressEntity],
        withSeances seances: DateIntervalSeances
    ) {
        let nbSeances: Int = seances.seances.count
        guard nbSeances > 0 else {
            return
        }
        var cumulatedDuration = 0.0
        var nbOfSeanceRequired: Double = 0.0

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
                progress.startDate = seances.seances[startIdx].startDate
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
                progress.endDate = seances.seances[endIdx].endDate
            } else {
                progress.endDate = nil
            }
        }
    }
}
