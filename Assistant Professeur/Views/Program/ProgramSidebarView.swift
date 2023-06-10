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
        List(selection: $navigationModel.selectedProgramMngObjId) {
            // pour chaque Discipline
            ForEach(programsSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Niveau
                        ForEach(section, id: \.objectID) { program in
//                            NavigationLink(value: program.objectID) {
                            ProgramBrowserRow(program: program)
                                .badge(program.nbOfSequences)

                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // supprimer le programme et tous ses descendants
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if navigationModel.selectedProgramMngObjId == program.objectID {
                                                navigationModel.selectedProgramMngObjId = nil
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
            .emptyListPlaceHolder(programsSections) {
                EmptyListMessage(
                    symbolName: ProgramEntity.defaultImageName,
                    title: "Aucun programme actuellement.",
                    message: "Les programmes ajoutés apparaîtront ici."
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Programmes")
        #endif
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'un nouveau programme
        .sheet(
            isPresented: $isAddingNewProgram
//            onDismiss: ProgramEntity.rollback()
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
                            "Exporter les programmes en CSV",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        
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
    }
}

struct ProgramSidebarView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ProgramSidebarView()
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ProgramSidebarView()
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
