//
//  ClassSequenceProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import HelpersView
import SwiftUI

/// Situation de la progression d'une Classe pour une Séquence donnée
/// permettant de mettre à jour la progression de la classe
struct ClassSequenceProgressEditView: View {
    // MARK: - Properties

    @ObservedObject
    var sequence: SequenceEntity

    @ObservedObject
    var classe: ClasseEntity

    @Binding
    var progressChanged: Bool

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = false

    @State
    private var sortedProgressesInSequence = [ActivityProgressEntity]()

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ProgressView(value: classe.actualProgressInSequence(sequence))
                .tint(.green)

            ForEach(sortedProgressesInSequence) { progress in
                ClassActivityProgressEditView(
                    progress: progress,
                    progressChanged: $progressChanged
                )
                .padding(.leading)
//                .listRowSeparatorTint(.secondary, edges: .bottom)
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
        .onAppear {
            // Liste des progresssions d'activités triée pour la classe et la séquence sélectionnées
            isExpanded = sequence.statusFor(classe: classe) == .inProgress
        }
        .task {
            sortedProgressesInSequence = classe.sortedProgressesInSequence(sequence)
        }
    }
}

// struct ClassSequenceProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassSequenceProgressView()
//    }
// }
