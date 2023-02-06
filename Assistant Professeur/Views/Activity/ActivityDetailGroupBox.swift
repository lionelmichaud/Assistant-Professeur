//
//  ActivityDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/01/2023.
//

import HelpersView
import SwiftUI

struct ActivityDetailGroupBox: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    var body: some View {
        GroupBox {
            Group {
                Label {
                    Text(activity.viewName)
                } icon: {
                    Image(systemName: "\(activity.viewNumber).circle")
                        .font(.body)
                }

                // note sur le programme
                if annotationEnabled && activity.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation: activity.viewAnnotation,
                        scrollable: true,
                        scrollHeight: 40
                    )
                }

                DurationView(duration: activity.duration, withMargin: false)

                WebsiteView(url: activity.url, showURL: true)
                    .padding(.top, 4)

                ActivityAllSymbols(
                    activity: activity,
                    showTitle: true
                )
                .padding(.top, 4)
            }
            .horizontallyAligned(.leading)
        }
        .font(hClass == .compact ? .subheadline : .callout)
        .padding(.horizontal)
    }
}

// struct ActivityDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDetailGroupBox()
//    }
// }
