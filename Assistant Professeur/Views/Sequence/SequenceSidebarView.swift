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

    @State
    private var isAddingNewSequence = false

    @State
    private var isEditing = false

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramId {
                if let program = ProgramEntity.byObjectId(id: programId) {
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
                VStack(alignment: .center) {
                    Text("Aucun programme sélectionné.")
                    Text("Sélectionner un programme.")
                }
                .foregroundStyle(.secondary)
                .font(.title2)
            }
        }
        #if os(iOS)
        .navigationTitle("Programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une nouvelle séquence
        .sheet(
            isPresented: $isAddingNewSequence,
            onDismiss: ProgramEntity.rollback
        ) {
            if let programId = navig.selectedProgramId,
               let program = ProgramEntity.byObjectId(id: programId) {
                NavigationStack {
                    SequenceCreatorModal(program: program)
                }
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification du programme
        .sheet(
            isPresented: $isEditing,
            onDismiss: ProgramEntity.rollback
        ) {
            if let programId = navig.selectedProgramId,
               let program = ProgramEntity.byObjectId(id: programId) {
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
        if let programId = navig.selectedProgramId,
           ProgramEntity.byObjectId(id: programId) != nil {
            // Editer le Programme
            ToolbarItemGroup(placement: .automatic) {
                Button("Modifier") {
                    isEditing.toggle()
                }
            }

            // Ajouter une Séquence
            ToolbarItemGroup(placement: .status) {
                Button {
                    isAddingNewSequence.toggle()
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

struct SequenceSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceSidebarView(showProgramSteps: .constant(true))
    }
}
