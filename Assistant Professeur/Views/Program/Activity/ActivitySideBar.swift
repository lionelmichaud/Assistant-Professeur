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
    var preferredColumn: NavigationSplitViewColumn

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isEditing = false

    @State
    private var isDuplicating = false

    @State
    private var searchString: String = ""

    /// Create an instance of your tip content.
    var sequenceInfoTip = SequenceInfoTip()
    var sequenceInfoTip2 = SequencePresentationTip()

    // MARK: - Computed Properties

    private var selectedSequenceNumber: String {
        sequence.viewNumber.formatted()
    }

    var body: some View {
        List(selection: $navig.selectedActivityMngObjId) {
            if sequence.program != nil {
                SequenceDetailGroupBox(
                    sequence: sequence,
                    withDetails: true
                )
            } else {
                Text("Progression associée introuvable")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }

            ActivityList(
                sequence: sequence, 
                preferredColumn: $preferredColumn,
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

        // Modal Sheet de sélection de la séquence associée
        .sheet(
            isPresented: $isDuplicating
        ) {
            NavigationStack {
                DuplicateSequenceModal(sequence: sequence)
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: Toolbar Content

extension ActivitySideBar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Editer la Séquence
        ToolbarItemGroup(placement: .automatic) {
            // Afficher la vue Stepper de la séquence
            Button {
                sequenceInfoTip.invalidate(reason: .actionPerformed)
                navig.showSequenceTimeLine()
                // FIXME: Fait planter l'app sur iPhone
                //preferredColumn = .detail
            } label: {
                Label(
                    "Infos", systemImage: "info.circle"
                )
            }
            .popoverTip(sequenceInfoTip)

            // Modifier la séquence
            Button {
                isEditing.toggle()
            } label: {
                Label(
                    "Modifier", systemImage: "square.and.pencil"
                )
            }

            // Dupliquer la séquence
            Button {
                isDuplicating.toggle()
            } label: {
                Label(
                    "Dupliquer la séquence dans un autre programme",
                    systemImage: "doc.on.doc.fill"
                )
            }
            .popoverTip(sequenceInfoTip2)
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
