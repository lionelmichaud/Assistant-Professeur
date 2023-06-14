//
//  DComListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DCompListView: View {
    @ObservedObject
    var section: DSectionEntity

    var discipline: Discipline

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedCompetency: DCompEntity?

    // MARK: - Computed Properties

    var body: some View {
        List(selection: $nav.selectedDiscCompMngObjId) {
            // Section de compétences disciplinaires
            DSectionBrowserView(
                section: section,
                showIcon: false,
                showProgressivity: true
            )

            // Compétences disciplinaires
            ForEach(
                section.allCompetenciesSortedByNumber,
                id: \.objectID
            ) { competency in
                DCompBrowserView(
                    competency: competency,
                    showIcon: true
                )
                .badge(competency.nbOfKnowledges)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer la compétence
                    Button(role: .destructive) {
                        withAnimation {
                            if nav.selectedDiscCompMngObjId == competency.objectID {
                                nav.selectedDiscCompMngObjId = nil
                            }
                            try? competency.delete()
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // modifier la compétence
                    Button {
                        editedCompetency = competency
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                    }
                }
            }
            .emptyListPlaceHolder(section.allCompetenciesSortedByNumber) {
                EmptyListMessage(
                    symbolName: DCompEntity.defaultImageName,
                    title: "Aucune compétence disciplinaire actuellement dans cette section.",
                    message: "Les compétences disciplinaires ajoutées apparaîtront ici.",
                    showAsGroupBox: false
                )
            }
            .onChange(of: nav.selectedDiscCompMngObjId) { _ in
                nav.selectedDiscKnowMngObjId = nil
            }
        }
        #if os(iOS)
        .navigationTitle("Compétences")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une compétence
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                let competency = DCompEntity()
                DCompEditorModal(
                    competency: competency,
                    nextNumber: section.nbOfCompetencies + 1,
                    inSection: section,
                    isEditing: false
                )
            }
            .presentationDetents([.medium])
        }

        // Modal Sheet de modification d'une compétence
        .sheet(
            item: $editedCompetency,
            onDismiss: didDismiss
        ) { competency in
            NavigationStack {
                DCompEditorModal(
                    competency: competency,
                    inSection: section,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedCompetency = nil
    }
}

// MARK: Toolbar Content

extension DCompListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            // Ajouter une compétence à la section
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter une compétence",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.titleAndIcon)
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier une compétence de la section
            if let selectedDiscCompMngObjId = nav.selectedDiscCompMngObjId {
                Button("Modifier") {
                    editedCompetency =
                        DCompEntity
                            .byObjectId(MngObjID: selectedDiscCompMngObjId)
                }
            }
        }
    }
}

// struct DComListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DComListView()
//    }
// }
