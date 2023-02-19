//
//  ClassGlobalProgress.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

struct ClassProgressesView: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

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
//                        DisclosureGroup("test") {
                            ClassActivityProgressView(progress: progress)
                                .listRowSeparatorTint(.secondary, edges: .bottom)
//                        }
                    }
                } label: {
                    LabeledSequenceView(sequence: sequence)
                        .font(hClass == .compact ? .callout : .title3)
                        .bold()
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
    ///   1. Numéro d'activité
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

// struct ClassGlobalProgress_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassGlobalProgress()
//    }
// }
