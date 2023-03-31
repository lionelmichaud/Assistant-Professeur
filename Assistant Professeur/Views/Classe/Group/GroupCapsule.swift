//
//  GroupCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/03/2023.
//

import HelpersView
import SwiftUI

struct GroupCapsule: View {
    let group: GroupEntity

    var body: some View {
        Text("\(group.displayString)")
            .filledCapsuleStyling(
                withBackground: true,
                withBorder: true,
                fillColor: .blue1
            )
    }
}

// struct GroupCapsule_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupCapsule()
//    }
// }
