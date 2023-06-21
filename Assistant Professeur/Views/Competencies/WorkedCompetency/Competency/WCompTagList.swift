//
//  WCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct WCompTagList: View {
    let workedComps: [WCompEntity]
    var font: Font = .callout

    var body: some View {
        TagList(
            tags: workedComps.map { $0.viewAcronym },
            container: .scrollView,
            horizontalSpacing: 4,
            verticalSpacing: 4,
            tagView: { tag in
                TagCapsule(
                    tag: tag,
                    style: .workedCompTagStyle
                )
                .font(font)
            }
        )
    }
}

//struct WCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompTagRow()
//    }
//}
