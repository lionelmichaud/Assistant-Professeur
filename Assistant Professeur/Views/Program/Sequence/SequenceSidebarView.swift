//
//  SequenceSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceSidebarView: View {
    @Binding
    var showProgramSteps: Bool

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isEditing = false

    @State
    var searchString: String = ""

    var body: some View {
        VStack {
            if let programId = nav.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                    if program.sequencesSortedByNumber.isNotEmpty {
                        List(selection: $nav.selectedSequenceMngObjId) {
                            ProgramDetailGroupBox(program: program)

                            SequenceList(
                                program: program,
                                searchString: searchString
                            )
                        }
                        .searchable(
                            text: $searchString,
                            placement: .toolbar,
                            prompt: "Nom de la séquence"
                        )

                    } else {
                        EmptyListMessage(
                            title: "Aucune séquence actuellement dans ce programme.",
                            message: "Les séquences ajoutées apparaîtront ici."
                        )
                    }

                } else {
                    Text("Programme introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                EmptyListMessage(
                    symbolName: ProgramEntity.defaultImageName,
                    title: "Aucun programme sélectionné.",
                    message: "Sélectionner un programme pour en visualiser les séquences ici.",
                    showAsGroupBox: true
                )
                .padding(.horizontal)
            }
        }
        #if os(iOS)
        .navigationTitle("Programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de modification du programme
        .sheet(
            isPresented: $isEditing,
            onDismiss: ProgramEntity.rollback
        ) {
            if let programId = nav.selectedProgramMngObjId,
               let program = ProgramEntity.byObjectId(MngObjID: programId) {
                NavigationStack {
                    ProgramEditorModal(program: program)
                }
                .presentationDetents([.medium])
            } else {
                Text("Aucun programme sélectionné")
            }
        }
    }
}

// MARK: Toolbar Content

extension SequenceSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let programId = nav.selectedProgramMngObjId,
           ProgramEntity.byObjectId(MngObjID: programId) != nil {
            // Editer le Programme
            ToolbarItemGroup(placement: .automatic) {
                ControlGroup {
                    Button {
                        showProgramSteps.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    Button {
                        isEditing.toggle()
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                }
            } label: {
                Label("Plus", systemImage: "ellipsis.circle")
            }

            // Ajouter une Séquence
            ToolbarItemGroup(placement: .status) {
                Button {
                    if let programId = nav.selectedProgramMngObjId {
                        if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                            withAnimation {
                                _ = SequenceEntity.create(
                                    name: "Nouvelle séquence",
                                    dans: program
                                )
                            }
                        }
                    }
//                    isAddingNewSequence.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter une séquence")
                        Spacer()
                    }
                }
            }
        }
    }
}

// struct SequenceSidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceSidebarView(showProgramSteps: .constant(true))
//    }
// }
