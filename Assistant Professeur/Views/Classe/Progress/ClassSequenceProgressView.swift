//
//  ClassSequenceProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Séquence
struct ClassSequenceProgressView: View {
    // MARK: - Initializer

    init(
        sequence: SequenceEntity,
        classe: ClasseEntity
    ) {
        self.sequence = sequence
        self.classe = classe
        self._isExpanded =
            State(initialValue: sequence.statusFor(classe: classe) == .inProgress)
    }

    // MARK: - Properties

    @ObservedObject
    private var sequence: SequenceEntity

    @ObservedObject
    private var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = false

    private var progresses: [ActivityProgressEntity] {
        classe.allProgresses
    }

    /// Retourne la liste des progresssions de classe triée pour l'activité et la séquence sélectionnées
    ///
    /// Ordre de tri des progressions:
    ///   1. Numéro d'activité
    private var sortedProgressesInSequence: [ActivityProgressEntity] {
        let sortComparators = [
            SortDescriptor(\ActivityProgressEntity.activity?.number, order: .forward)
        ]

        return progresses
            .filter { progress in
                progress.activity?.sequence == sequence
            }
            .sorted(using: sortComparators)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(sortedProgressesInSequence) { progress in
                ClassActivityProgressView(progress: progress)
                    .padding(.leading)
                    .listRowSeparatorTint(.secondary, edges: .bottom)
            }
            .emptyListPlaceHolder(sortedProgressesInSequence) {
                Text("Aucune activité suivie par cette classe")
            }
        } label: {
            HStack {
                CompletionSymbol(
                    status: sequence.statusFor(classe: classe)
                )
                LabeledSequenceView(sequence: sequence)
            }
            .font(hClass == .compact ? .callout : .title3)
            .bold()
            .listRowSeparatorTint(.secondary, edges: .bottom)
        }
    }
}

// struct ClassSequenceProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassSequenceProgressView()
//    }
// }
