//
//  SequenceDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceDetailGroupBox: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    var body: some View {
        GroupBox {
            LabeledSequenceView(sequence: sequence)
                .font(hClass == .compact ? .callout : .headline)
                .bold()
                .horizontallyAligned(.leading)

            // note sur le programme
            if annotationEnabled && sequence.viewAnnotation.isNotEmpty {
                AnnotationView(
                    annotation: sequence.viewAnnotation,
                    scrollable: true,
                    scrollHeight: 40
                )
                .horizontallyAligned(.leading)
            }

            HStack {
                DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                padding(.trailing)
                DurationView(duration: sequence.durationWithMargin, withMargin: true)
                padding(.trailing)
                WebsiteView(url: sequence.url)
            }
        }
        .font(hClass == .compact ? .callout : .body)
        .padding(.horizontal)
    }
}

// struct SequenceDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceDetailGroupBox()
//    }
// }
