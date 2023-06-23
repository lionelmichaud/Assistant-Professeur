//
//  SequenceTagList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/06/2023.
//

import SwiftUI
import TagKit

struct SequenceTagList: View {
    let sequences: [SequenceEntity]
    var font: Font = .callout

    var body: some View {
        TagList(
            tags: sequences.map { "S\($0.viewNumber)" },
            container: .scrollView,
            horizontalSpacing: 4,
            verticalSpacing: 4,
            tagView: { tag in
                TagCapsule(
                    tag: tag,
                    style: .sequenceTagStyle
                )
                .font(font)
            }
        )
    }
}

// struct SequenceTagList_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceTagList()
//    }
// }
