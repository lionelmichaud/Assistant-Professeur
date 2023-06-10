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
        HStack {
            Image(systemName: "\(activity.viewNumber).circle")
                .imageScale(.large)

            VStack(alignment: .leading) {
                Text(activity.viewName)
                    .textSelection(.enabled)

                HStack {
                    DurationSquareView(
                        duration: activity.duration,
                        withMargin: false
                    )
                    Spacer()
                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: false
                    )
                    .tint(.primary)
                    // WebsiteView(url: activity.url)
                }
            }
        }
        .font(hClass == .compact ? .callout : .body)
    }
}

// struct ActivityBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityBrowserRow()
//    }
// }
