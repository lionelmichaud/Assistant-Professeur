//
//  DuplicateSequenceModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/09/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DuplicateSequenceModal: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.dismiss)
    private var dismiss

    let programs: [ProgramEntity] = ProgramEntity.allSortedbyDisciplineLevelSegpa()

    @State
    private var selectedProgsObjId = Set<NSManagedObjectID>()

    @State
    private var isExpanded: Bool = true

    var body: some View {
        List(selection: $selectedProgsObjId) {
            ForEach(programs, id: \.objectID) { program in
                ProgramDisciplineLevel(program: program)
                    .bold()
                    .horizontallyAligned(.leading)
            }
        }
        .listStyle(.sidebar)
        .interactiveDismissDisabled()
        #if os(iOS)
            .navigationTitle("Dupliquer vers les progressions")
        #endif
            .navigationBarTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        SequenceEntity.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dupliquer") {
                        let destinationPrograms = selectedProgsObjId.compactMap { programId in
                            ProgramEntity.byObjectId(MngObjID: programId)
                        }

                        destinationPrograms.forEach { program in
                            sequence.clone(dans: program)
                        }
                        dismiss()
                    }
                    .disabled(selectedProgsObjId.isEmpty)
                }
            }
    }
}

// struct DuplicateSequenceModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DuplicateSequenceModal()
//    }
// }
