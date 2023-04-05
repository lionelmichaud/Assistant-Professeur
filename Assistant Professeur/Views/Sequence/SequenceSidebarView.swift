//
//  SequenceSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SequenceSidebarView: View {
    @Binding
    var showProgramSteps: Bool

    @EnvironmentObject
    private var navig: NavigationModel

//    @State
//    private var isAddingNewSequence = false

    @State
    private var isEditing = false

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
//                    NavigationLink(value: program) {
//                        Label("Information sur le programme", systemImage: "books.vertical")
//                    }
                    Button {
                        showProgramSteps = true
                    } label: {
                        ProgramDetailGroupBox(program: program)
                    }
                    .buttonStyle(.plain)
                    SequenceList(program: program)

                } else {
                    Text("Programme introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                EmptyListMessage(
                    symbolName: "books.vertical",
                    title: "Aucun programme sélectionné.",
                    message: "Sélectionner un programme pour en visualiser les séquences.",
                    showAsGroupBox: true
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une nouvelle séquence
//        .sheet(
//            isPresented: $isAddingNewSequence,
//            onDismiss: ProgramEntity.rollback
//        ) {
//            if let programId = navig.selectedProgramId,
//               let program = ProgramEntity.byObjectId(id: programId) {
//                NavigationStack {
//                    SequenceCreatorModal(program: program)
//                }
//                .presentationDetents([.large])
//            }
//        }

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
            }
        }
    }
}

// MARK: Toolbar Content

extension SequenceSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let programId = navig.selectedProgramMngObjId,
           ProgramEntity.byObjectId(MngObjID: programId) != nil {
            // Editer le Programme
            ToolbarItemGroup(placement: .automatic) {
                Button("Modifier") {
                    isEditing.toggle()
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
