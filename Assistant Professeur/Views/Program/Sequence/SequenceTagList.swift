//
//  SequenceTagList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/06/2023.
//

import SwiftUI
import TagKit

struct SequencePopOverContent: View {
    let sequence: SequenceEntity

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TagCapsule(
                    tag: "S\(sequence.viewNumber)",
                    style: .sequenceTagStyle
                )
                .font(.callout)
                .bold()
                Text(sequence.viewName)
                    .bold()
            }
            Text(sequence.viewAnnotation)
                .foregroundColor(.secondary)
        }
        .font(.body)
        .padding(.horizontal)
        .frame(maxWidth: 500)
    }
}

struct SequenceTag: View {
    let sequence: SequenceEntity
    var font: Font = .callout

    var body: some View {
        TagCapsule(
            tag: "S\(sequence.viewNumber)",
            style: .sequenceTagStyle
        )
        .font(font)
        .bold()
    }
}

struct SequenceTagList: View {
    let sequences: [SequenceEntity]
    var font: Font = .callout

    @State
    private var tappedTag: SequenceEntity?

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
                .bold()
                .onTapGesture {
                    self.tappedTag =
                        sequences
                            .filter { sequence in
                                String(sequence.viewNumber) == tag[1 ... tag.count - 1]
                            }
                            .first
                }
            }
        )
        .popover(item: $tappedTag) { detail in
            SequencePopOverContent(sequence: detail)
        }
    }
}

// struct SequenceTagList_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceTagList()
//    }
// }
