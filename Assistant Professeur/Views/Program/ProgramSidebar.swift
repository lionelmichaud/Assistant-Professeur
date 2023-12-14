//
//  ProgramSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import HelpersView
import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ProgramSidebarView"
)

struct ProgramSidebar: View {
    @EnvironmentObject
    private var navig: NavigationModel

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
        List(selection: $navig.selectedProgramMngObjId) {
            // pour chaque Discipline
            ForEach(programsSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Niveau
                        ForEach(section, id: \.objectID) { program in
                            ProgramBrowserRow(program: program)
                                .badge(program.nbOfSequences)

                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // supprimer le programme et tous ses descendants
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if navig.selectedProgramMngObjId == program.objectID {
                                                navig.selectedProgramMngObjId = nil
                                            }
                                            try? program.delete()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text("\(section.id)")
                            .style(.sectionHeader)
                    }
                }
            }
            .emptyListPlaceHolder(programsSections) {
                ContentUnavailableView(
                    "Aucune progression actuellement...",
                    systemImage: ProgramEntity.defaultImageName,
                    description: Text("Les progressions ajoutées apparaîtront ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Progressions")
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

extension ProgramSidebar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Menu
        ToolbarItem(placement: .automatic) {
            Menu {
                Button {
                    CsvImportExportMng.exportPrograms()
                    fileExportOperation = .exportCsvPrograms
                    isExportingModel.toggle()
                } label: {
                    Label(
                        "Exporter les progressions en CSV",
                        systemImage: "square.and.arrow.up"
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }

        // Ajouter un établissement
        ToolbarItem(placement: .status) {
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
            ProgramSidebar()
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ProgramSidebar()
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
