//
//  WCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI

struct WCompTagRow: View {
    let workedComps: [WCompEntity]

    var body: some View {
        HStack {
            ForEach(workedComps) { wComp in
                WCompCapsule(competency: wComp)
            }
        }
    }
}

//struct WCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompTagRow()
//    }
//}
