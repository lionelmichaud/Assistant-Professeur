//
//  DCompCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct DCompCapsule: View {
    let competency: DCompEntity

    var body: some View {
        Text("\(competency.viewAcronym)")
            .font(.callout)
            .filledCapsuleStyling(
                withBackground: true,
                withBorder: true,
                fillColor: .blue3
            )
    }
}

// struct DCompCapsule_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompCapsule()
//    }
// }
