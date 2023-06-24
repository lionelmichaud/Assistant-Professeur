//
//  DCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct DCompPopOverContent: View {
    let disciplineComp: DCompEntity

    var body: some View {
        Text("\(Text(disciplineComp.viewAcronym).bold().foregroundColor(.secondary)): \(disciplineComp.viewDescription)")
            .font(.body)
            .padding()
            .frame(maxWidth: 500)
    }
}

struct DCompTag: View {
    let disciplineComp: DCompEntity
    var font: Font = .callout

    @State
    private var tappedTag: DCompEntity?

    var body: some View {
        TagCapsule(
            tag: disciplineComp.viewAcronym,
            style: .disciplineCompTagStyle
        )
        .font(font)
        .onTapGesture {
            self.tappedTag = disciplineComp
        }
        .popover(item: $tappedTag) { detail in
            DCompPopOverContent(disciplineComp: detail)
        }
    }
}

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
            DCompPopOverContent(disciplineComp: detail)
        }
    }
}

// struct DCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompTagRow()
//    }
// }
