//
//  ProgramManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import Foundation
import SwiftUI

struct ProgramManager {
    /// Supprimer la `sequence` du `program` et
    /// re-numéroter les séquences restantes en conséquence.
    ///
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    static func delete(
        sequence   : SequenceEntity,
        de program : ProgramEntity
    ) {
        let orderedSequences = program.sequencesSortedByNumber
        guard let index = orderedSequences.firstIndex(of: sequence) else {
            return
        }

        // renuméroter les éléments restants
        if index < orderedSequences.endIndex {
            for idx in index+1 ..< orderedSequences.endIndex {
                orderedSequences[idx].number -= 1
            }
        }

        // Supprimer l'élément
        SequenceEntity.viewContext.delete(orderedSequences[index])
    }

    /// Supprimer l'`activity` de la `sequence` et
    /// re-numéroter les activités restantes en conséquence.
    ///
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    static func delete(
        activity    : ActivityEntity,
        de sequence : SequenceEntity
    ) {
        let orderedActivities = sequence.activitiesSortedByNumber
        guard let index = orderedActivities.firstIndex(of: activity) else {
            return
        }

        // renuméroter les éléments restants
        if index < orderedActivities.endIndex {
            for idx in index+1 ..< orderedActivities.endIndex {
                orderedActivities[idx].number -= 1
            }
        }

        // Supprimer l'élément
        ActivityEntity.viewContext.delete(orderedActivities[index])
    }

}
