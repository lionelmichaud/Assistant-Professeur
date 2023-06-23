//
//  WCompListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct WCompListView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedWorkedCompetency: WCompEntity?

    // MARK: - Computed properties

    private var selectedChapterId: NSManagedObjectID? {
        nav.selectedWorkedCompChapterMngObjId
    }

    private var selectedChapter: WCompChapterEntity? {
        guard let selectedChapterId else {
            return nil
        }
        return WCompChapterEntity.byObjectId(MngObjID: selectedChapterId)
    }

    private var selectedChapterExists: Bool {
        selectedChapter != nil
    }

    var body: some View {
        Group {
            if selectedChapterExists {
                List(selection: $nav.selectedWorkedCompMngObjId) {
                    // pour chaque compétence travaillée
                    ForEach(
                        selectedChapter!.allWorkedCompetenciesSortedByNumber
                    ) { competency in
                        WCompBrowserRow(
                            workedComp: competency,
                            showDisciplineCompetencies: true,
                            showSequences: true
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // supprimer la compétence
                            Button(role: .destructive) {
                                withAnimation {
                                    if nav.selectedWorkedCompMngObjId == competency.objectID {
                                        nav.selectedWorkedCompMngObjId = nil
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
                                editedWorkedCompetency = competency
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                        }
                    }
                    .emptyListPlaceHolder(selectedChapter!.allWorkedCompetenciesSortedByNumber) {
                        EmptyListMessage(
                            symbolName: WCompEntity.defaultImageName,
                            title: "Aucune compétence actuellement.",
                            message: "Les compétences ajoutées apparaîtront ici."
                        )
                    }
                }

            } else {
                EmptyListMessage(
                    symbolName: WCompEntity.defaultImageName,
                    title: "Aucun élément de compétence sélectionné.",
                    message: "Sélectionner un élément de compétence pour en visualiser le contenu.",
                    showAsGroupBox: true
                )
                .padding(.horizontal)
            }
        }
        #if os(iOS)
        .navigationTitle("Compétences travaillées")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un chapitre de compétence socle
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                let competency = WCompEntity()
                WCompEditorModal(
                    competency: competency,
                    nextNumber: (selectedChapter?.nbOfWorkedCompetencies ?? 0) + 1,
                    inChapter: selectedChapter!,
                    isEditing: false
                )
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editedWorkedCompetency,
            onDismiss: didDismiss
        ) { competency in
            NavigationStack {
                WCompEditorModal(
                    competency: competency,
                    inChapter: selectedChapter!,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedWorkedCompetency = nil
    }
}

// MARK: Toolbar Content

extension WCompListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        if selectedChapterExists {
            ToolbarItemGroup(placement: .status) {
                // Ajouter une compétence au chapitre
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
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier une compétence du chapitre
            if let selectedCompMngObjId = nav.selectedWorkedCompMngObjId {
                Button("Modifier") {
                    editedWorkedCompetency =
                        WCompEntity
                            .byObjectId(MngObjID: selectedCompMngObjId)
                }
            }
        }
    }
}

struct WorkedCompListView_Previews: PreviewProvider {
    static var previews: some View {
        WCompListView()
    }
}
