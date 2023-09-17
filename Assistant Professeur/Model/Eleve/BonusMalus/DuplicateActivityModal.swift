//
//  DuplicateActivityModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/09/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DuplicateActivityModal: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.dismiss)
    private var dismiss

    let programs: [ProgramEntity] = ProgramEntity.allSortedbyDisciplineLevelSegpa()

    @State
    private var selectedSeqsObjId = Set<NSManagedObjectID>()

    @State
    private var isExpanded: Bool = true

    var body: some View {
        List(selection: $selectedSeqsObjId) {
            ForEach(programs) { program in
                ProgramDisclosure(program: program)
            }
        }
        .listStyle(.sidebar)
        .interactiveDismissDisabled()
        #if os(iOS)
            .navigationTitle("Dupliquer vers les séquences")
        #endif
            .navigationBarTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        ActivityEntity.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dupliquer") {
                        let sequences = selectedSeqsObjId.compactMap { sequenceId in
                            SequenceEntity.byObjectId(MngObjID: sequenceId)
                        }

                        sequences.forEach { sequence in
                            activity.clone(dans: sequence)
                        }
                        dismiss()
                    }
                    .disabled(selectedSeqsObjId.isEmpty)
                }
            }
    }
}

struct ProgramDisclosure: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded.animation()) {
            ForEach(program.sequencesSortedByNumber, id: \.objectID) { sequence in
                HStack {
                    SequenceTag(
                        sequence: sequence,
                        font: hClass == .compact ? .body : .headline
                    )
                    Text(sequence.viewName)
                        .textSelection(.enabled)
                        .font(hClass == .compact ? .body : .title3)
                }
                .horizontallyAligned(.leading)
            }
        } label: {
            ProgramDisciplineLevel(program: program)
                .bold()
                .horizontallyAligned(.leading)
        }
    }
}

// struct DuplicateActivityModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DuplicateActivityModal()
//    }
// }
