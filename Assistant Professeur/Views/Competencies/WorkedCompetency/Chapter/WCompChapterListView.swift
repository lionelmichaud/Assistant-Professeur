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
        fetchRequest: WCompChapterEntity.requestAllSortedbyCycleTitle,
        sectionIdentifier: \.cycleString,
        animation: .default
    )
    private var workedCompChapterSections: SectionedFetchResults<String, WCompChapterEntity>

    var body: some View {
        List(selection: $nav.selectedWorkedCompChapterMngObjId) {
            // pour chaque Cycle
            ForEach(workedCompChapterSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Chapitre
                        ForEach(section, id: \.objectID) { workedChapter in
                            //                            NavigationLink(value: program.objectID) {
                            WCompChapterBrowserRow(chapter: workedChapter)
                                // .badge(workedChapter.nbOfWorkedCompetencies)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // supprimer le chapitre
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
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    // modifier le chapitre
                                    Button {
                                        editedWorkedChapter = workedChapter
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                }
                            //                            }
                        }
                    } header: {
                        Text("\(section.id)")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                    }
                }
            }
            .emptyListPlaceHolder(workedCompChapterSections) {
                EmptyListMessage(
                    symbolName: WCompChapterEntity.defaultImageName,
                    title: "Aucun élément actuellement.",
                    message: "Les éléments de compétences ajoutées apparaîtront ici."
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
            }
            .presentationDetents([.medium])
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
                Button("Modifier") {
                    editedWorkedChapter =
                        WCompChapterEntity
                            .byObjectId(MngObjID: selectedObject)
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
