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

    @Binding
    var showSequenceSteps: Bool

    @EnvironmentObject
    private var navig: NavigationModel

//    @State
//    private var isAddingNewActivity = false

    @State
    private var isEditing = false

    // MARK: - Computed Properties

    private var selectedSequenceNumber: String {
        sequence.viewNumber.formatted()
    }

    var body: some View {
        VStack {
            if sequence.program != nil {
                Button {
                    showSequenceSteps = true
                } label: {
                    SequenceDetailGroupBox(sequence: sequence)
                }
                .buttonStyle(.plain)
            } else {
                Text("Programme associé introuvable")
            }
            ActivityList(sequence: sequence)
        }
        #if os(iOS)
        .navigationTitle("Séquence " + selectedSequenceNumber)
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de création d'une nouvelle activité
//        .sheet(
//            isPresented: $isAddingNewActivity,
//            onDismiss: SequenceEntity.rollback
//        ) {
//            if let sequenceId = navig.selectedSequenceId,
//               let sequence = SequenceEntity.byObjectId(id: sequenceId) {
//                NavigationStack {
//                    ActivityCreatorModal(sequence: sequence)
//                }
//                .presentationDetents([.medium])
//            }
//        }

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
                .presentationDetents([.large])
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
                    withAnimation {
                        _ = ActivityEntity.create(
                            name: "Nouvelle activité",
                            duration: 1.0,
                            dans: sequence
                        )
                    }
//                    isAddingNewActivity = true
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
