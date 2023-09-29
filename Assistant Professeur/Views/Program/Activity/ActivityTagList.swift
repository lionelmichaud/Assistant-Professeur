//
//  ActivityTagList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/06/2023.
//

import SwiftUI
import TagKit

struct ActivityTag: View {
    let activity: ActivityEntity
    var font: Font = .callout

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TagCapsule(
            tag: "A\(activity.viewNumber)",
            style: .activityTagStyle
        )
        .font(font)
        .bold()
    }
}

struct ActivityTagList: View {
    let activities: [ActivityEntity]
    var font: Font = .callout

    var body: some View {
        TagList(
            tags: activities.map { "A\($0.viewNumber)" },
            container: .scrollView,
            horizontalSpacing: 4,
            verticalSpacing: 4,
            tagView: { tag in
                TagCapsule(
                    tag: tag,
                    style: .activityTagStyle
                )
                .font(font)
                .bold()
            }
        )
    }
}

//struct ActivityTagList_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityTagList()
//    }
//}
