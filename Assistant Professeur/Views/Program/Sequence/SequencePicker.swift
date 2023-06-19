//
//  SequencePicker.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct SequencePicker: View {
    @Binding
    var selectedSequence: SequenceEntity

    let inSequences: [SequenceEntity]

    var body: some View {
        Picker(
            "Séquence",
            selection: $selectedSequence
        ) {
            ForEach(inSequences) { sequence in
                SequencePickerRow(sequence: sequence)
                    .horizontallyAligned(.leading)
                    .tag(sequence)
            }
        }
        .pickerStyle(.wheel)
    }
}

// struct SequencePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        SequencePicker()
//    }
// }
