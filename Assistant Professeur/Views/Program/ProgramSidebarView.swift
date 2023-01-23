//
//  ProgramSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI
import os

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "ProgramSidebarView")

struct ProgramSidebarView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var isAddingNewProgram = false

    @SectionedFetchRequest<String, ProgramEntity>(
        fetchRequest      : ProgramEntity.requestAllSortedbyDisciplineLevelSegpa,
        sectionIdentifier : \.disciplineString,
        animation         : .default)
    private var programsSections: SectionedFetchResults<String, ProgramEntity>

    var body: some View {
        List(selection: $navigationModel.selectedProgramId) {
            if ProgramEntity.all().isEmpty {
                Text("Aucun programme existant")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }
            /// pour chaque Discipline
            ForEach(programsSections) { section in
                if section.isNotEmpty {
                    Section {
                        /// pour chaque Discipline
                        ForEach(section, id: \.objectID) { program in
//                            NavigationLink(value: program.objectID) {
                                ProgramBrowserRow(program: program)
                                    .badge(program.nbOfSequences)

                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        // supprimer le programme et tous ses descendants
                                        Button(role: .destructive) {
                                            withAnimation {
                                                try? program.delete()
                                                if navigationModel.selectedProgramId == program.objectID {
                                                    navigationModel.selectedProgramId = nil
                                                }
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
        .navigationTitle("Programmes")
        .toolbar(content: myToolBarContent)

        /// Modal Sheet de création d'un nouveau programme
        .sheet(isPresented: $isAddingNewProgram,
               onDismiss: { }) {
            NavigationStack {
                ProgramCreatorModal()
            }
            .presentationDetents([.medium])
        }

    }
}

// MARK: Toolbar Content

extension ProgramSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        /// Ajouter un établissement
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
    static var previews: some View {
        ProgramSidebarView()
    }
}
