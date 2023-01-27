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
        VStack(alignment: .leading) {
            Label(sequence.viewName,
                  systemImage: "\(sequence.viewNumber).circle")
            HStack {
                DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                Spacer()
                DurationView(duration: sequence.durationWithMargin, withMargin: true)
                Spacer()
                WebsiteView(url: sequence.url)
            }
        }
        .font(hClass == .compact ? .subheadline : .callout)
    }
}

//struct SequenceBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceBrowserRow()
//    }
//}
