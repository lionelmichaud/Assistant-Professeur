//
//  WCompChapterPicker.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct WCompChapterPicker: View {
    @Binding
    var selectedChapter: WCompChapterEntity

    let inChapters: [WCompChapterEntity]

    var body: some View {
        Picker(
            "Élément travaillé",
            selection: $selectedChapter
        ) {
            ForEach(inChapters) { chapter in
                HStack {
                    Text(chapter.viewAcronym)
                        .fontWeight(.bold) +
                        Text(". ") +
                        Text(chapter.viewDescription)
                        .foregroundColor(.secondary)
                }
                .lineLimit(5)
                .horizontallyAligned(.leading)
                .tag(chapter)
            }
        }
        .pickerStyle(.wheel)
    }
}

//struct WCompChapterPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompChapterPicker()
//    }
//}
