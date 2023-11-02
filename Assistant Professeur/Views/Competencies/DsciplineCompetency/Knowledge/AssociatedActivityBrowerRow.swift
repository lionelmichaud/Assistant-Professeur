//
//  CompActivityBrowerRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct AssociatedActivityBrowerRow: View {
    let activity: ActivityEntity
    let verticallyStacked: Bool

    var body: some View {
        let layout = verticallyStacked ?
            AnyLayout(VStackLayout(alignment: .leading)) :
            AnyLayout(HStackLayout(alignment: .center))
        return layout {
            HStack(alignment: .center) {
                if let level = activity.sequence?.program?.viewLevelEnum {
                    LevelTag(level: level)
                }
                if let sequence = activity.sequence {
                    SequenceTagWithPopOver(sequence: sequence)
                }
                ActivityTag(activityNumber: activity.viewNumber)
            }

            if let sequence = activity.sequence,
               verticallyStacked {
                Text(sequence.viewName)
                    .lineLimit(1)
            }
            Text(activity.viewName)
                .lineLimit(1)
                .foregroundColor(.secondary)
        }
    }
}

// struct CompActivityBrowerRow_Previews: PreviewProvider {
//    static var previews: some View {
//        CompActivityBrowerRow()
//    }
// }
