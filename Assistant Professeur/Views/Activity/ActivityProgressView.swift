//
//  ActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/02/2023.
//

import SwiftUI
import HelpersView

struct ActivityProgressView: View {
    @ObservedObject
    var activity: ActivityEntity

    var progresses: [ActivityProgressEntity] {
        activity.allProgresses
    }

    var body: some View {
        ForEach(progresses) { progress in
            Text("**\(progress.classe!.school!.displayString)**: \(progress.progress)")
        }
        .emptyListPlaceHolder(progresses) {
            Text("Aucune classe")
        }
    }
}

// struct ActivityProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityProgressView()
//    }
// }
