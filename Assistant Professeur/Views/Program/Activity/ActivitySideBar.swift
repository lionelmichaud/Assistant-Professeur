//
//  ActivitySideBar.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct ActivitySideBar: View {
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

    private var selectedSequenceId: NSManagedObjectID? {
        navig.selectedSequenceMngObjId
    }

    private var selectedSequence: SequenceEntity? {
        guard let selectedSequenceId else {
            return nil
        }
        return SequenceEntity.byObjectId(MngObjID: selectedSequenceId)
    }

    private var selectedSequenceExists: Bool {
        selectedSequence != nil
    }

    private var selectedSequenceNumber: String {
        selectedSequence?.viewNumber.formatted() ?? ""
    }

    var body: some View {
        ZStack {
            if selectedSequenceExists {
                List(selection: $navig.selectedActivityMngObjId) {
                    if selectedSequence!.program != nil {
                        SequenceDetailGroupBox(
                            sequence: selectedSequence!,
                            withDetails: true
                        )
                    } else {
                        Text("Progression associée introuvable")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }

                    ActivityList(
                        sequence: selectedSequence!,
                        searchString: searchString
                    )
                }
                .searchable(
                    text: $searchString,
                    placement: .toolbar,
                    prompt: "Nom de l'activité"
                )
            } else {
                ContentUnavailableView(
                    "Aucune séquence sélectionnée...",
                    systemImage: ClasseEntity.defaultImageName,
                    description: Text("Sélectionner une séquence pour en visualiser les activités ici.")
                )
            }
        }
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
                SequenceEditorModal(sequence: selectedSequence!)
            }
            .presentationDetents([.large])
        }

        // Modal Sheet de sélection de la séquence associée
        .sheet(
            isPresented: $isDuplicating
        ) {
            NavigationStack {
                DuplicateSequenceModal(sequence: selectedSequence!)
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
            // Afficher la vue Stepper de la séquence
            if let selectedSequence {
                Button {
                    sequenceInfoTip.invalidate(reason: .actionPerformed)
                    navig.showSequenceTimeLine(for: selectedSequence)

                    // FIXME: Fait planter l'app sur iPhone
                    // preferredColumn = .detail
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
                        systemImage: "doc.on.doc"
                    )
                }
                .popoverTip(sequenceInfoTip2)
            }
        }

        // Ajouter une Activité
        ToolbarItemGroup(placement: .status) {
            if selectedSequenceExists {
                Button {
                    withAnimation {
                        _ = ActivityEntity.create(
                            name: "Nouvelle activité",
                            duration: 1.0,
                            dans: selectedSequence!
                        )
                    }
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
