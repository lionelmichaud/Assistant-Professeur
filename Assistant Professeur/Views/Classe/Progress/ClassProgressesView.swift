//
//  ClassGlobalProgress.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Séquence / Activité
struct ClassProgressesView: View {
    @ObservedObject
    var classe: ClasseEntity

    var progresses: [ActivityProgressEntity] {
        classe.allProgresses
    }

    /// Liste des activités suivies par cette classe
    var sequences: [SequenceEntity] {
        let sortComparators = [
            SortDescriptor(\SequenceEntity.viewNumber, order: .forward)
        ]

        var sequences = [SequenceEntity]()

        progresses.forEach { progress in
            if let sequence = progress.activity?.sequence,
               !sequences.contains(sequence) {
                sequences.append(sequence)
            }
        }
        return sequences.sorted(using: sortComparators)
    }

    var body: some View {
        List {
            ForEach(sequences) { sequence in
                ClassSequenceProgressView(sequence: sequence, classe: classe)
            }
            .emptyListPlaceHolder(sequences) {
                Text("Aucune séquence suivie par cette classe")
            }
        }
        #if os(iOS)
        .navigationTitle("Progression")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

// struct ClassGlobalProgress_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassGlobalProgress()
//    }
// }
