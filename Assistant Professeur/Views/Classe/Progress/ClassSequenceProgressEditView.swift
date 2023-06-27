//
//  ClassSequenceProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import HelpersView
import SwiftUI

/// Situation de la progression d'une Classe pour une Séquence donnée
struct ClassSequenceProgressEditView: View {
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

    /// Retourne la liste des progresssions d'activités de classe triée pour la classe et la séquence sélectionnées
    ///
    /// Ordre de tri des progressions:
    ///   1. Numéro d'activité
    private var sortedProgressesInSequence: [ActivityProgressEntity] {
        classe.sortedProgressesInSequence(sequence)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ProgressView(value: classe.progressInSequence(sequence))
                .tint(.mint)
            ForEach(sortedProgressesInSequence) { progress in
                ClassActivityProgressEditView(progress: progress)
                    .padding(.leading)
                    .listRowSeparatorTint(.secondary, edges: .bottom)
            }
            .emptyListPlaceHolder(sortedProgressesInSequence) {
                Text("Aucune activité suivie par cette classe")
            }
        } label: {
            HStack(alignment: .center) {
                CompletionSymbol(
                    status: sequence.statusFor(classe: classe)
                )
                SequenceTag(
                    sequence: sequence,
                    font: hClass == .compact ? .body : .title3
                )
                Text(sequence.viewName)
                    .font(hClass == .compact ? .body : .title3)
                    .textSelection(.enabled)
            }
            .listRowSeparatorTint(.secondary, edges: .bottom)
        }
    }
}

// struct ClassSequenceProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassSequenceProgressView()
//    }
// }
