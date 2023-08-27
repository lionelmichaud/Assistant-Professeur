//
//  ActivitySideBar.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct ActivitySideBar: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Binding
    var showSequenceSteps: Bool

    @EnvironmentObject
    private var nav: NavigationModel

    @State
    private var isEditing = false

    @State
    private var searchString: String = ""

    // MARK: - Computed Properties

    private var selectedSequenceNumber: String {
        sequence.viewNumber.formatted()
    }

    var body: some View {
        List(selection: $nav.selectedActivityMngObjId) {
            if sequence.program != nil {
                SequenceDetailGroupBox(sequence: sequence)
            } else {
                Text("Programme associé introuvable")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }

            ActivityList(
                sequence: sequence,
                searchString: searchString
            )
        }
        .searchable(
            text: $searchString,
            placement: .toolbar,
            prompt: "Nom de l'activité"
        )
        #if os(iOS)
        .navigationTitle("Séquence " + selectedSequenceNumber)
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de modification de la séquence
        .sheet(
            isPresented: $isEditing,
            onDismiss: SequenceEntity.rollback
        ) {
            NavigationStack {
                SequenceEditorModal(sequence: sequence)
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: Toolbar Content

extension ActivitySideBar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Editer la Séquence
        ToolbarItemGroup(placement: .automatic) {
            Button {
                showSequenceSteps.toggle()
            } label: {
                Image(systemName: "info.circle")
            }
            Button {
                isEditing.toggle()
            } label: {
                Image(systemName: "pencil")
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

// struct ActivitySideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySideBar()
//    }
// }
