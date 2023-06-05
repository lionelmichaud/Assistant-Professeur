//
//  WorkedCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import SwiftUI
import HelpersView

struct WorkedCompChapterBrowserRow: View {
    @ObservedObject
    var chapter: WorkedCompChapterEntity

    var body: some View {
        HStack {
            LabeledContent {
                VStack(alignment: .leading) {
                    Text(chapter.viewAcronym)
                        .fontWeight(.bold)
                    Text(chapter.viewDescription)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            } label: {
                Image(systemName: WorkedCompChapterEntity.defaultImageName)
                    .sfSymbolStyling()
            }
        }
    }
}

//struct WorkedCompBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompBrowserRow()
//    }
//}
