//
//  CompetencySidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import HelpersView
import SwiftUI

struct CompetencySidebarView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isAddingNewWorkedComp = false

    @State
    private var isExportingModel = false

    @State
    private var fileExportOperation = FileExportOperation.none

    @SectionedFetchRequest<String, WorkedCompChapterEntity>(
        fetchRequest: WorkedCompChapterEntity.requestAllSortedbyCycleTitle,
        sectionIdentifier: \.cycleString,
        animation: .default
    )
    private var workedCompChapterSections: SectionedFetchResults<String, WorkedCompChapterEntity>

    var body: some View {
        List(selection: $nav.selectedWorkedCompChapterMngObjId) {
            /// Section des compétences travaillées du socle commun
            Section {
                // Ajouter une compétence du socle commun
                Button {
                    isAddingNewWorkedComp = true
                } label: {
                    Label("Ajouter une compétence", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)

                // pour chaque Cycle
                ForEach(workedCompChapterSections) { section in
                    if section.isNotEmpty {
                        Section {
                            // pour chaque Chapitre
                            ForEach(section, id: \.objectID) { workedChapter in
                                //                            NavigationLink(value: program.objectID) {
                                WorkedCompChapterBrowserRow(chapter: workedChapter)
                                    .badge(workedChapter.nbOfWorkedCompetencies)

                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        // supprimer le programme et tous ses descendants
                                        Button(role: .destructive) {
                                            withAnimation {
                                                // if nav.selectedWorkedCompMngObjId == workedComp.objectID {
                                                //     nav.selectedWorkedCompMngObjId = nil
                                                // }
                                                try? workedChapter.delete()
                                            }
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    }
                                //                            }
                            }
                        } header: {
                            Text("\(section.id)")
                                .font(.callout)
                                .foregroundColor(.secondary)
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
            } header: {
                Text("Socle commun")
            }

            /// Section des compétences disciplinaires
            Section {
                // Ajouter une compétence du socle commun
                Button {
                    isAddingNewWorkedComp = true
                } label: {
                    Label("Ajouter une compétence", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
            } header: {
                Text("Compétences discipinaires")
            }
        }
        #if os(iOS)
        .navigationTitle("Compétences")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un nouveau programme
        .sheet(
            isPresented: $isAddingNewWorkedComp
            //            onDismiss: ProgramEntity.rollback()
        ) {
            NavigationStack {
                WorkedCompCreatorModal()
            }
            .presentationDetents([.medium])
        }

        // Exporter des fichiers JSON pour le modèle
        .fileMover(
            isPresented: $isExportingModel,
            files: isExportingModel ? fileExportOperation.urls : []
        ) { _ in
        }
    }
}

// MARK: Toolbar Content

extension CompetencySidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Menu
        ToolbarItemGroup(placement: .automatic) {
            Menu {
                Menu("Exporter") {
                    Button {
                        CsvImportExportMng.exportPrograms()
                        fileExportOperation = .exportCsvPrograms
                        isExportingModel.toggle()
                    } label: {
                        Label(
                            "Exporter les compétences en CSV",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

struct CompetencySidebarView_Previews: PreviewProvider {
    static var previews: some View {
        CompetencySidebarView()
    }
}
