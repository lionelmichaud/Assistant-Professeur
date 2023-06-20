//
//  DCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct DCompTagRow: View {
    let disciplineComps: [DCompEntity]
    var font: Font = .callout

    var body: some View {
        TagList(
            tags: disciplineComps.map { $0.viewAcronym },
            container: .scrollView,
            horizontalSpacing: 4,
            verticalSpacing: 4,
            tagView: { tag in
                TagCapsule(
                    tag: tag,
                    style: .disciplineCompTagStyle
                )
                .font(font)
            }
        )
    }
}

// struct DCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompTagRow()
//    }
// }
