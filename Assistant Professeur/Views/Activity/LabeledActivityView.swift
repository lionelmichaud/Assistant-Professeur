//
//  LabeledActivityView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct LabeledActivityView: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        Label {
            Text(activity.viewName)
                .textSelection(.enabled)
        } icon: {
            Image(systemName: "\(activity.viewNumber).circle")
                .imageScale(.large)
        }
    }
}

// struct LabeledActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabeledActivityView()
//    }
// }
