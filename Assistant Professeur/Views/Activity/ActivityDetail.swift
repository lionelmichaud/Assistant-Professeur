//
//  ActivityDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct ActivityDetail: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        Text("Durée: \(activity.viewDuration)")
    }
}

//struct ActivityDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDetail()
//    }
//}
