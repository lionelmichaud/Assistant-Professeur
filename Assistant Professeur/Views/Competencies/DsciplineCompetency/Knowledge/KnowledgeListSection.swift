//
//  KnowledgeListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import HelpersView
import SwiftUI

struct KnowledgeListSection: View {
    @ObservedObject
    var dCompetency: DCompEntity

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false

    @State
    private var editedKnowledge: DKnowledgeEntity?

    var body: some View {
        Section {
            // Ajouter une compétence à la section
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter une connaissance",
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(.borderless)

            ForEach(
                dCompetency.allKnowledgesSortedByNumber
            ) { knowledge in
                DKnowBrowserRow(
                    knowledge: knowledge,
                    showIcon: true
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer la connaissance
                    Button(role: .destructive) {
                        withAnimation {
                            if nav.selectedDiscKnowMngObjId == knowledge.objectID {
                                nav.selectedDiscKnowMngObjId = nil
                            }
                            try? knowledge.delete()
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // modifier la connaissance
                    Button {
                        editedKnowledge = knowledge
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                    }
                }
            }
            .emptyListPlaceHolder(dCompetency.allKnowledgesSortedByNumber) {
                EmptyListMessage(
                    symbolName: DKnowledgeEntity.defaultImageName,
                    title: "Aucune connaissance disciplinaire actuellement pour cette compétence.",
                    message: "Les connaissances disciplinaires ajoutées apparaîtront ici.",
                    showAsGroupBox: false
                )
            }
        } header: {
            Text("Connaissances disciplinaires")
                .font(.headline)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }

        // Modal Sheet de création d'une connaissance
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                let knowledge = DKnowledgeEntity()
                DKnowEditorModal(
                    knowledge: knowledge,
                    nextNumber: (dCompetency.nbOfKnowledges) + 1,
                    inCompetency: dCompetency,
                    isEditing: false
                )
            }
            .presentationDetents([.medium])
        }

        // Modal Sheet de modification d'une compétence
        .sheet(
            item: $editedKnowledge,
            onDismiss: didDismiss
        ) { knowledge in
            NavigationStack {
                DKnowEditorModal(
                    knowledge: knowledge,
                    inCompetency: dCompetency,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedKnowledge = nil
    }
}

// struct KnowledgeListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        KnowledgeListSection()
//    }
// }
