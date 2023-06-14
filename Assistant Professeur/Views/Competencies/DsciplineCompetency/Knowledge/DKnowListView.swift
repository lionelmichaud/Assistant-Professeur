//
//  KnowledgeListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DKnowListView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedKnowledge: DKnowledgeEntity?

    // MARK: - Computed Properties

    private var selectedCompetencyId: NSManagedObjectID? {
        nav.selectedDiscCompMngObjId
    }

    private var selectedCompetency: DCompEntity? {
        guard let selectedCompetencyId else {
            return nil
        }
        return DCompEntity.byObjectId(MngObjID: selectedCompetencyId)
    }

    private var selectedCompetencyExists: Bool {
        selectedCompetency != nil
    }

    var body: some View {
        Group {
            if selectedCompetencyExists {
                List(selection: $nav.selectedDiscKnowMngObjId) {
                    // Compétence disciplinaire
                    DCompBrowserView(
                        competency: selectedCompetency!,
                        showIcon: false
                    )

                    // Connaissances disciplinaires
                    Section {
                        ForEach(
                            selectedCompetency!.allKnowledgesSortedByNumber,
                            id: \.objectID
                        ) { knowledge in
                            DKnowBrowserView(
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
                        .emptyListPlaceHolder(selectedCompetency!.allKnowledgesSortedByNumber) {
                            EmptyListMessage(
                                symbolName: DKnowledgeEntity.defaultImageName,
                                title: "Aucune connaissance disciplinaire actuellement pour cette compétence.",
                                message: "Les connaissances disciplinaires ajoutées apparaîtront ici.",
                                showAsGroupBox: false
                            )
                        }
                    }
                }
            } else {
                EmptyListMessage(
                    title: "Aucune compétence sélectionnée.",
                    message: "Sélectionner une compétence pour en visualiser le détail ici.",
                    showAsGroupBox: true
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Connaissances")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une compétence
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                let knowledge = DKnowledgeEntity()
                DKnowEditorModal(
                    knowledge: knowledge,
                    nextNumber: (selectedCompetency?.nbOfKnowledges ?? 0) + 1,
                    inCompetency: selectedCompetency!,
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
                    inCompetency: selectedCompetency!,
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

// MARK: Toolbar Content

extension DKnowListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            // Ajouter une compétence à la section
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter une connaissance",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.titleAndIcon)
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier une connaissance à la section
            if let selectedDiscKnowMngObjId = nav.selectedDiscKnowMngObjId {
                Button("Modifier") {
                    editedKnowledge =
                        DKnowledgeEntity
                            .byObjectId(MngObjID: selectedDiscKnowMngObjId)
                }
            }
        }
    }
}

// struct KnowledgeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        KnowledgeListView()
//    }
// }
