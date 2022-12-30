//
//  ColleNotifIcon.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI

struct ColleNotifIcon: View {
    @ObservedObject
    var colle: ColleEntity

    var body: some View {
        Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .foregroundColor(colle.isConsignee ? .green : .red)
    }
}

//struct ColleNotifIcon_Previews: PreviewProvider {
//    static var previews: some View {
//        ColleNotifIcon(colle: Colle.exemple)
//            .previewLayout(.sizeThatFits)
//    }
//}
