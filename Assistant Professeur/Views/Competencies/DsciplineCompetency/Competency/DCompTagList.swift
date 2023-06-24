//
//  DCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct DCompTagList: View {
    let disciplineComps: [DCompEntity]
    var font: Font = .callout

    @State
    private var tappedTag: DCompEntity?

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
                .onTapGesture {
                    self.tappedTag = DCompEntity.disciplineCompetency(withAcronym: tag)
                }
            }
        )
        .popover(item: $tappedTag) { detail in
            Text("\(Text(detail.viewAcronym).bold().foregroundColor(.secondary)): \(detail.viewDescription)")
                .font(.body)
                .frame(maxWidth: 500)
        }
    }
}

// struct DCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompTagRow()
//    }
// }
