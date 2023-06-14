//
//  SequenceCreatorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI

/// A Bridge to SequenceEditorModal that creates the object to be edited
struct SequenceCreatorModal: View {
    @ObservedObject
    var program: ProgramEntity

    /// This will not show changes to the variables in this View
    @State
    var newSequence: SequenceEntity?

    var body: some View {
        Group {
            if let newSequence {
                SequenceEditorModal(sequence: newSequence)
            } else {
                // Likely wont ever be visible but there has to be a fallback
                ProgressView()
                    .onAppear {
                        newSequence = SequenceEntity.createWithoutSaving(dans: program)
                    }
            }
        }
    }
}

// struct SequenceCreatorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceCreatorModal()
//    }
// }
