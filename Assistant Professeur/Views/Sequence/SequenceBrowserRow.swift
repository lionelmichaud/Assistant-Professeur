//
//  SequenceBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SequenceBrowserRow: View {
    @ObservedObject
    var sequence: SequenceEntity

    var body: some View {
        HStack {
            Label(sequence.viewName,
                  systemImage: "\(sequence.viewNumber).circle")
        }
    }
}

//struct SequenceBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceBrowserRow()
//    }
//}
