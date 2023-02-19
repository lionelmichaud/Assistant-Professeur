//
//  ClassCurrentActivityView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

struct ClassCurrentActivityView: View {
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
                DisclosureGroup {
                    ForEach(sortedProgressesIn(sequence)) { progress in
                        ActivityClassProgressView(progress: progress)
                            .listRowSeparatorTint(.secondary, edges: .bottom)
                    }
                } label: {
                    Text(sequence.viewName)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
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

    /// Retourne la liste des progresssions de classe triée pour l'activité et la séquence sélectionnées
    ///
    /// Ordre de tri des progressions:
    ///   1. Niveau de la Classe
    ///   2. Classe SEGPA ou non
    ///   3. Numéro de la Classe
    private func sortedProgressesIn(_ sequence: SequenceEntity) -> [ActivityProgressEntity] {
        let sortComparators = [
            SortDescriptor(\ActivityProgressEntity.activity?.number, order: .forward)
        ]

        return progresses
            .filter { progress in
                progress.activity?.sequence == sequence
            }
            .sorted(using: sortComparators)
    }
}

// struct ClassCurrentActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassCurrentActivityView()
//    }
// }
