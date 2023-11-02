//
//  SequencePickerRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct SequencePickerRow: View {
    let sequence: SequenceEntity

    var body: some View {
        HStack {
            if let level = sequence.program?.viewLevelEnum {
                LevelTag(level: level)
            }

            SequenceTag(sequenceNumber: sequence.viewNumber)
            
            Text(sequence.viewName)
        }
    }
}

// struct SequencePickerRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SequencePickerRow()
//    }
// }
