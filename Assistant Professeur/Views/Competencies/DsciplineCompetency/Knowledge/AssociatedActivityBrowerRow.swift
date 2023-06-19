//
//  CompActivityBrowerRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct AssociatedActivityBrowerRow: View {
    let activity: ActivityEntity
    let verticallyStacked: Bool

    var body: some View {
        let layout = verticallyStacked ?
            AnyLayout(VStackLayout()) :
            AnyLayout(HStackLayout())
        return HStack {
            layout {
                if let level = activity.sequence?.program?.viewLevelEnum {
                    Text(level.displayString)
                        .foregroundColor(.primary)
                        .font(.callout)
                        .filledCapsuleStyling(
                            withBackground: true,
                            withBorder: true,
                            fillColor: level.imageColor
                        )
                }
                HStack(spacing: 0) {
                    if let sequence = activity.sequence {
                        Image(systemName: "\(sequence.viewNumber).circle")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                    Image(systemName: "\(activity.viewNumber).circle")
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                }
            }
            Text(activity.viewName)
        }
    }
}

// struct CompActivityBrowerRow_Previews: PreviewProvider {
//    static var previews: some View {
//        CompActivityBrowerRow()
//    }
// }
