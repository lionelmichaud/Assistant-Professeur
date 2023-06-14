//
//  ObservationNotifIcon.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI

struct ObservNotifIcon: View {
    @ObservedObject
    var observ: ObservEntity

    var body: some View {
        Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .foregroundColor(observ.isConsignee ? .green : .red)
    }
}

//struct ObservationNotifIcon_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservNotifIcon(observ: Observation.exemple)
//            .previewLayout(.sizeThatFits)
//    }
//}
