//
//  ProgramSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ProgramSidebarView"
)

struct ProgramSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var isAddingNewProgram = false

    @State
    private var isExportingModel = false

    @State
    private var fileExportOperation = FileExportOperation.none

    @SectionedFetchRequest<String, ProgramEntity>(
        fetchRequest: ProgramEntity.requestAllSortedbyDisciplineLevelSegpa,
        sectionIdentifier: \.disciplineString,
        animation: .default
    )
    private var programsSections: SectionedFetchResults<String, ProgramEntity>

    var body: some View {
        List(selection: $navigationModel.selectedProgramId) {
            if ProgramEntity.all().isEmpty {
                GroupBox {
                    Text("Aucun programme")
                        .bold()
                    Text("Les programmes ajoutés apparaîtront ici.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .verticallyAligned(.top)
            }

            // pour chaque Discipline
            ForEach(programsSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Discipline
                        ForEach(section, id: \.objectID) { program in
//                            NavigationLink(value: program.objectID) {
                            ProgramBrowserRow(program: program)
                                .badge(program.nbOfSequences)

                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // supprimer le programme et tous ses descendants
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if navigationModel.selectedProgramId == program.objectID {
                                                navigationModel.selectedProgramId = nil
                                            }
                                            try? program.delete()
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
        }
        #if os(iOS)
        .navigationTitle("Programmes")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un nouveau programme
        .sheet(
            isPresented: $isAddingNewProgram
            // onDismiss: {}
        ) {
            NavigationStack {
                ProgramCreatorModal()
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

extension ProgramSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Ajouter un établissement
        ToolbarItemGroup(placement: .status) {
            Button {
                isAddingNewProgram = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un programme")
                    Spacer()
                }
            }
        }
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
                            "Exporter les Programmes",
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

struct ProgramSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSidebarView()
    }
}
