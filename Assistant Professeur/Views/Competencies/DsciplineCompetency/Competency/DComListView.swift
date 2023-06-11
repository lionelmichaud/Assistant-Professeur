//
//  DComListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DComListView: View {
    var discipline: Discipline

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedCompetency: DCompEntity?

    // MARK: - Computed Properties

    private var selectedSectionId: NSManagedObjectID? {
        nav.selectedDiscSectionMngObjId
    }

    private var selectedSection: DSectionEntity? {
        guard let selectedSectionId else {
            return nil
        }
        return DSectionEntity.byObjectId(MngObjID: selectedSectionId)
    }

    private var selectedSectionExists: Bool {
        selectedSection != nil
    }

    var body: some View {
        Group {
            if selectedSectionExists {
                List(selection: $nav.selectedDiscCompMngObjId) {
                    // Section de compétences disciplinaires
                    DSectionBrowserView(
                        section: selectedSection!,
                        showIcon: false,
                        showProgressivity: true
                    )

                    // Compétences disciplinaires
                    Section {
                        ForEach(
                            selectedSection!.allCompetenciesSortedByNumber,
                            id: \.objectID
                        ) { competency in
                            DCompBrowserView(
                                competency: competency,
                                showIcon: true
                            )
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
                        .emptyListPlaceHolder(selectedSection!.allCompetenciesSortedByNumber) {
                            EmptyListMessage(
                                symbolName: DCompEntity.defaultImageName,
                                title: "Aucune compétence disciplinaire actuellement dans cette section.",
                                message: "Les compétences disciplinaires ajoutées apparaîtront ici.",
                                showAsGroupBox: false
                            )
                        }
                    }
                }
            } else {
                EmptyListMessage(
                    title: "Aucune section sélectionnée.",
                    message: "Sélectionner une section pour en visualiser le détail ici.",
                    showAsGroupBox: true
                )
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
                    nextNumber: (selectedSection?.nbOfCompetencies ?? 0) + 1,
                    inSection: selectedSection!,
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
                    inSection: selectedSection!,
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

extension DComListView {
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
            // Modifier une compétence à la section
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
