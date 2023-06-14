//
//  ObservSignIcon.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI

struct ObservSignIcon: View {
    @ObservedObject
    var observ: ObservEntity

    var body: some View {
        Image(systemName: "signature")
            .foregroundColor(observ.isVerified ? .green : .red)
    }
}

//struct ObservSignIcon_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservSignIcon(observ: Observation.exemple)
//            .previewLayout(.sizeThatFits)
//    }
//}
