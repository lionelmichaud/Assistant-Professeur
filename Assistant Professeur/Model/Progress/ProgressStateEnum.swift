//
//  ProgressState.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import Foundation

enum ProgressStateEnum: String {
    case notStarted = "A venir"
    case inProgress = "En cours"
    case completed = "Terminé"
    case invalid = "Invalide"

    var imageName: String {
        switch self {
            case .notStarted:
                return "record.circle.fill"
            case .inProgress:
                return "inProgress"
            case .completed:
                return "checkmark.circle.fill"
            case .invalid:
                return "questionmark.circle.fill"
        }
    }
}
