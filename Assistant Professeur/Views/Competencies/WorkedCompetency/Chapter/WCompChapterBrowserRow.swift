//
//  WorkedCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import HelpersView
import SwiftUI

struct WCompChapterBrowserRow: View {
    @ObservedObject
    var chapter: WCompChapterEntity

    var body: some View {
        Label(
            title: {
                Group {
                    Text(chapter.viewAcronym)
                        .fontWeight(.bold) +
                    Text(". ") +
                        Text(chapter.viewDescription)
                        .foregroundColor(.secondary)
                }
                .lineLimit(5)
            },
            icon: {
                Image(systemName: WCompChapterEntity.defaultImageName)
            }
        )
    }
}

// struct WorkedCompBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompBrowserRow()
//    }
// }
