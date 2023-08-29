//
//  ActivityBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct ActivityBrowserRow: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        Label(
            title: {
                VStack(alignment: .leading, spacing: 0) {
                    Text(activity.viewName)
                    Text(activity.viewAnnotation)
                        .foregroundColor(.secondary)

                    HStack {
                        DurationSquareView(
                            duration: activity.duration,
                            withMargin: false,
                            margin: 0
                        )
                        Spacer()
                        ActivityAllSymbols(
                            activity: activity,
                            showTitle: false
                        )
                        .tint(.primary)
                        WebsiteView(url: activity.url)
                    }
                }
                .font(hClass == .compact ? .callout : .body)
            },
            icon: {
                ActivityTag(
                    activity: activity,
                    font: hClass == .compact ? .callout : .body
                ).frame(minWidth: 50)
            }
        )
    }
}

// struct ActivityBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityBrowserRow()
//    }
// }
