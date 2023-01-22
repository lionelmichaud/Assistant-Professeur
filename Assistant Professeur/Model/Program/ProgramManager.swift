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
    /// - Warning: Les modification ne sont pas auvegardées dans le contexte.
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
}
