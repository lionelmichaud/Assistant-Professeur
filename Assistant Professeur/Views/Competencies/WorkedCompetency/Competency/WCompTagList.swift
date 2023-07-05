//
//  WCompTagRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import SwiftUI
import TagKit

struct WCompPopOverContent: View {
    let workedComp: WCompEntity

    var body: some View {
        ZStack {
            // Scaled-up background
            Color.blue7
                .scaleEffect(1.5)
            
            Text("\(Text(workedComp.viewAcronym).bold().foregroundColor(.secondary)): \(workedComp.viewDescription)")
                .font(.body)
                .padding(.horizontal)
                .frame(maxWidth: 500)
        }
    }
}

struct WCompTag: View {
    let workedComp: WCompEntity
    var font: Font = .callout

    @State
    private var tappedTag: WCompEntity?

    var body: some View {
        TagCapsule(
            tag: workedComp.viewAcronym,
            style: .workedCompTagStyle
        )
        .font(font)
        .onTapGesture {
            self.tappedTag = workedComp
        }
        .popover(item: $tappedTag) { detail in
            WCompPopOverContent(workedComp: detail)
        }
    }
}

struct WCompTagList: View {
    let workedComps: [WCompEntity]
    var font: Font = .callout

    @State
    private var tappedTag: WCompEntity?

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
                .onTapGesture {
                    self.tappedTag = WCompEntity.workedCompetency(withAcronym: tag)
                }
            }
        )
        .popover(item: $tappedTag) { detail in
            WCompPopOverContent(workedComp: detail)
        }
    }
}

// struct WCompTagRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompTagRow()
//    }
// }
