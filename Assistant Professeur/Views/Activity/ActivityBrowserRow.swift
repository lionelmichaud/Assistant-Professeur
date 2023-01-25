//
//  ActivityBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI
import HelpersView

struct ActivityBrowserRow: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        VStack(alignment: .leading) {
            Label(activity.viewName,
                  systemImage: "\(activity.viewNumber).circle")
            HStack {
                DurationView(duration: activity.duration, withMargin: false)
                Spacer()
                WebsiteView(url: activity.url)
            }
        }
        .font(hClass == .compact ? .subheadline : .callout)
    }
}

//struct ActivityBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityBrowserRow()
//    }
//}
