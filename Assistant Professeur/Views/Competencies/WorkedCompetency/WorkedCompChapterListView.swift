//
//  WorkedCompChapterListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct WorkedCompChapterListView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingObject = false

    @State
    private var editeWorkedChapter: WorkedCompChapterEntity?

    @SectionedFetchRequest<String, WorkedCompChapterEntity>(
        fetchRequest: WorkedCompChapterEntity.requestAllSortedbyCycleTitle,
        sectionIdentifier: \.cycleString,
        animation: .default
    )
    private var workedCompChapterSections: SectionedFetchResults<String, WorkedCompChapterEntity>

    var body: some View {
        List(selection: $nav.selectedWorkedCompChapterMngObjId) {
            // pour chaque Cycle
            ForEach(workedCompChapterSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Chapitre
                        ForEach(section, id: \.objectID) { workedChapter in
                            //                            NavigationLink(value: program.objectID) {
                            WorkedCompChapterBrowserRow(chapter: workedChapter)
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
                                        editeWorkedChapter = workedChapter
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                }.tint(.green)

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
                    symbolName: WorkedCompChapterEntity.defaultImageName,
                    title: "Aucune compétence actuellement.",
                    message: "Les compétences ajoutées apparaîtront ici."
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Éléments du Socle")
        #endif
        .toolbar(content: myToolBarContent)

        /// Modal Sheet de création d'un chapitre de compétence socle
        .sheet(
            isPresented: $isAddingObject
            //            onDismiss: ProgramEntity.rollback()
        ) {
            NavigationStack {
                WorkedCompCreatorModal()
            }
            .presentationDetents([.medium])
        }

        /// Modal Sheet de modification d'un chapitre de compétence socle
        .sheet(
            item: $editeWorkedChapter,
            onDismiss: didDismiss
        ) { chapter in
            NavigationStack {
                WorkedCompEditorModal(chapter: chapter)
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editeWorkedChapter = nil
    }
}

// MARK: Toolbar Content

extension WorkedCompChapterListView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        // Ajouter un établissement
        ToolbarItemGroup(placement: .status) {
            // Ajouter une compétence du socle commun
            Button {
                isAddingObject = true
            } label: {
                Label(
                    "Ajouter une élément",
                    systemImage: "plus.circle.fill"
                )
                .labelStyle(.titleAndIcon)
            }
        }
    }
}

struct WorkedCompChapterListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkedCompChapterListView()
    }
}
