//
//  SequenceBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceBrowserRow: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        HStack {
            Image(systemName: "\(sequence.viewNumber).circle")
                .imageScale(.large)

            VStack(alignment: .leading) {
                Text(sequence.viewName)
                    .textSelection(.enabled)

                HStack {
                    DurationSquareView(
                        duration: sequence.durationWithoutMargin,
                        withMargin: true
                    )
                    Spacer()
                    WebsiteView(url: sequence.url)
                }
            }
        }
        .font(hClass == .compact ? .callout : .body)
    }
}

// struct SequenceBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceBrowserRow()
//    }
// }
