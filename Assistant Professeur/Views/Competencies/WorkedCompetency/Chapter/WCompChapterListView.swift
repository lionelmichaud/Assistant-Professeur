//
//  WorkedCompChapterListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct WCompChapterListView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false
    @State
    private var editedWorkedChapter: WCompChapterEntity?

    @SectionedFetchRequest<String, WCompChapterEntity>(
        fetchRequest: WCompChapterEntity.requestAllSortedByCycleAcronymTitle,
        sectionIdentifier: \.cycleString,
        animation: .default
    )
    private var workedCompChapterSections: SectionedFetchResults<String, WCompChapterEntity>

    var body: some View {
        List(selection: $nav.selectedWorkedCompChapterMngObjId) {
            // pour chaque Cycle
            ForEach(workedCompChapterSections) { cycleChapters in
                if cycleChapters.isNotEmpty {
                    Section {
                        // pour chaque Chapitre
                        ForEach(cycleChapters, id: \.objectID) { workedChapter in
                            // NavigationLink(value: program.objectID) {
                            WCompChapterBrowserRow(chapter: workedChapter)
                                .badge(workedChapter.nbOfWorkedCompetencies)
                                .customizedListItemStyle(
                                    isSelected: workedChapter.objectID == nav.selectedWorkedCompChapterMngObjId
                                )
                                // supprimer le chapitre
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if nav.selectedWorkedCompChapterMngObjId == workedChapter.objectID {
                                                nav.selectedWorkedCompChapterMngObjId = nil
                                            }
                                            try? workedChapter.delete()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                // modifier le chapitre
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        editedWorkedChapter = workedChapter
                                    } label: {
                                        Label("Modifier", systemImage: "square.and.pencil")
                                    }
                                }
                            //                            }
                        }
                    } header: {
                        Text("\(cycleChapters.id)")
                            .style(.sectionHeader)
                    }
                }
            }
            .emptyListPlaceHolder(workedCompChapterSections) {
                ContentUnavailableView(
                    "Aucun élément actuellement...",
                    systemImage: WCompChapterEntity.defaultImageName,
                    description: Text("Les éléments de compétences ajoutés apparaîtront ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Éléments du Socle")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un chapitre de compétence socle
        .sheet(
            isPresented: $isAddingObject
            //            onDismiss: ProgramEntity.rollback()
        ) {
            NavigationStack {
                let chapter = WCompChapterEntity()
                WCompChapterEditorModal(
                    chapter: chapter,
                    isEditing: false
                )
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editedWorkedChapter,
            onDismiss: didDismiss
        ) { chapter in
            NavigationStack {
                WCompChapterEditorModal(
                    chapter: chapter,
                    isEditing: true
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedWorkedChapter = nil
    }
}

// MARK: Toolbar Content

extension WCompChapterListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .status) {
            // Ajouter un chapitre de compétences du socle commun
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter un élément",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.titleAndIcon)
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Modifier un chapitre de compétences du socle commun
            if let selectedObject = nav.selectedWorkedCompChapterMngObjId {
                Button {
                    editedWorkedChapter =
                        WCompChapterEntity
                            .byObjectId(MngObjID: selectedObject)
                } label: {
                    Label("Modifier", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

struct WorkedCompChapterListView_Previews: PreviewProvider {
    static var previews: some View {
        WCompChapterListView()
    }
}
