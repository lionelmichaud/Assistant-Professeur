//
//  ActivityPicker.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct ActivityPicker: View {
    @Binding
    var selectedActivity: ActivityEntity

    let inActivities: [ActivityEntity]

    var body: some View {
        Picker(
            "Activité",
            selection: $selectedActivity
        ) {
            ForEach(inActivities) { activity in
                AssociatedActivityBrowerRow(
                    activity: activity,
                    verticallyStacked: false
                )
                .horizontallyAligned(.leading)
                .tag(activity)
            }
        }
        .pickerStyle(.wheel)
    }
}

// struct ActivityPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityPicker()
//    }
// }
