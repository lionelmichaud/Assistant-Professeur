//
//  DCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI

struct DCompTagRow: View {
    let disciplineComps: [DCompEntity]
    var font: Font = .callout

    var body: some View {
        HStack {
            ForEach(disciplineComps) { dComp in
                DCompCapsule(
                    competency: dComp,
                    font: font
                )
            }
        }
    }
}

// struct DCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompTagRow()
//    }
// }
