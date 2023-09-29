//
//  ProgressClasseCoordinator.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/09/2023.
//

import Foundation

/// Gère les relations entre Progression / Activité / Classe
enum ProgressClasseCoordinator {
    /// Retourne la progression d'une `classe`pour une `activtity`données.
    static func progressFor(
        thisActivity activity: ActivityEntity,
        thisClasse classe: ClasseEntity
    ) -> ActivityProgressEntity? {
        activity.allProgresses.first { progress in
            progress.classe == classe
        }
    }
}
