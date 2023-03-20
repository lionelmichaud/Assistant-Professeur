//
//  SequenceBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI
import HelpersView

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
                    DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                    Spacer()
                    DurationView(duration: sequence.durationWithMargin, withMargin: true)
                    Spacer()
                    WebsiteView(url: sequence.url)
                }
            }
        }
        .font(hClass == .compact ? .callout : .body)
    }
}

//struct SequenceBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceBrowserRow()
//    }
//}
