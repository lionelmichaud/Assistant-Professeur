//
//  CompCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct WCompCapsule: View {
    let competency: WCompEntity

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

// struct CompCapsule_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompCapsule()
//    }
// }
