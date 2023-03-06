//
//  LabeledSequenceView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct LabeledSequenceView: View {
    @ObservedObject
    var sequence: SequenceEntity

    var body: some View {
        Label {
            Text(sequence.viewName)
                .textSelection(.enabled)
        } icon: {
            Image(systemName: "\(sequence.viewNumber).circle")
        }
    }
}

// struct LabeledSequenceView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabeledSequenceView()
//    }
// }
