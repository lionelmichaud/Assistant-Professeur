//
//  ActivitySideBar.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import CoreData
import SwiftUI

struct ActivitySideBar: View {
    @ObservedObject
    var sequence: SequenceEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isAddingNewActivity = false

    @State
    private var isEditing = false

    // MARK: - Computed Properties

    private var selectedSequenceId: NSManagedObjectID? {
        navig.selectedSequenceId
    }

    private var selectedSequence: SequenceEntity? {
        guard let selectedSequenceId else {
            return nil
        }
        return SequenceEntity.byObjectId(id: selectedSequenceId)
    }

    private var selectedASequenceExists: Bool {
        selectedSequence != nil
    }

    private var selectedSequenceNumber: String {
        selectedSequence?.viewNumber.formatted() ?? ""
    }

    var body: some View {
        VStack {
            if selectedASequenceExists {
                if selectedSequence != nil {
                    if selectedSequence!.program != nil {
                        SequenceDetailGroupBox(sequence: selectedSequence!)
                    } else {
                        Text("Programme associé introuvable")
                    }
                    ActivityList(sequence: selectedSequence!)
                } else {
                    Text("Séquence introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            } else {
                VStack(alignment: .center) {
                    Text("Aucune séquence sélectionnée.")
                    Text("Sélectionner une séquence.")
                }
                .foregroundStyle(.secondary)
                .font(.title2)
            }
        }
        #if os(iOS)
        .navigationTitle("Séquence " + selectedSequenceNumber)
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une nouvelle activité
        .sheet(
            isPresented: $isAddingNewActivity,
            onDismiss: SequenceEntity.rollback
        ) {
            if let sequenceId = navig.selectedSequenceId,
               let sequence = SequenceEntity.byObjectId(id: sequenceId) {
                NavigationStack {
                    ActivityCreatorModal(sequence: sequence)
                }
                .presentationDetents([.medium])
            }
        }

        // Modal Sheet de modification de la séquence
        .sheet(
            isPresented: $isEditing,
            onDismiss: SequenceEntity.rollback
        ) {
            if let sequenceId = navig.selectedSequenceId,
               let sequence = SequenceEntity.byObjectId(id: sequenceId) {
                NavigationStack {
                    SequenceEditorModal(sequence: sequence)
                }
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: Toolbar Content

extension ActivitySideBar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let sequenceId = navig.selectedSequenceId,
           SequenceEntity.byObjectId(id: sequenceId) != nil {
            // Editer la Séquence
            ToolbarItemGroup(placement: .automatic) {
                Button("Modifier") {
                    isEditing.toggle()
                }
            }

            // Ajouter une Activité
            ToolbarItemGroup(placement: .status) {
                Button {
                    isAddingNewActivity.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter une activité")
                        Spacer()
                    }
                }
            }
        }
    }
}

// struct ActivitySideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySideBar()
//    }
// }
