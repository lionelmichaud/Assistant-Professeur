//
//  SequenceDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI
import HelpersView

struct SequenceDetailGroupBox: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label {
                    Text(sequence.viewName)
                } icon: {
                    Image(systemName: "\(sequence.viewNumber).circle")
                        .font(.body)
                }

                // note sur le programme
                if annotationEnabled && sequence.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation   : sequence.viewAnnotation,
                        scrollable   : true,
                        scrollHeight : 40
                    )
                }

                HStack {
                    DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                    Spacer()
                    DurationView(duration: sequence.durationWithMargin, withMargin: true)
                    Spacer()
                    WebsiteView(url: sequence.url)
                }
            }
        }
        .font(hClass == .compact ? .subheadline : .callout)
        .padding(.horizontal)
    }
}

//struct SequenceDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceDetailGroupBox()
//    }
//}
