//
//  SequenceSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceSidebar: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isEditing = false

    @State
    var searchString: String = ""

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                    List(selection: $navig.selectedSequenceMngObjId) {
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
                    Text("Progression introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                ContentUnavailableView(
                    "Aucune progression sélectionnée...",
                    systemImage: ProgramEntity.defaultImageName,
                    description: Text("Sélectionner une progression pour en visualiser les séquences ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Progression")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de modification du programme
        .sheet(
            isPresented: $isEditing,
            onDismiss: ProgramEntity.rollback
        ) {
            if let programId = navig.selectedProgramMngObjId,
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

extension SequenceSidebar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let programId = navig.selectedProgramMngObjId,
           ProgramEntity.byObjectId(MngObjID: programId) != nil {
            ToolbarItemGroup(placement: .automatic) {
                // Afficher la vue Stepper du Programme
                Button {
                    // afficher la time-line du programme dans la colonne de droite (détail)
                    navig.showProgramTimeLine()
                } label: {
                    Label(
                        "Infos",
                        systemImage: "info.circle"
                    )
                }

                // Modifier le Programme
                Button {
                    isEditing.toggle()
                } label: {
                    Label(
                        "Modifier",
                        systemImage: "pencil"
                    )
                }
            }

            // Ajouter une Séquence
            ToolbarItemGroup(placement: .status) {
                Button {
                    if let programId = navig.selectedProgramMngObjId {
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
