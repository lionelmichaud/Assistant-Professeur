//
//  DKnowledgeBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/06/2023.
//

import SwiftUI

struct DKnowBrowserRow: View {
    @ObservedObject
    var knowledge: DKnowledgeEntity

    var showIcon: Bool

    var description: some View {
        Group {
            Text(knowledge.viewAcronym)
                .fontWeight(.bold) +
                Text(". ") +
                Text(knowledge.viewDescription)
                .foregroundColor(.secondary)
        }
        .lineLimit(5)
        .textSelection(.enabled)
    }

    var body: some View {
        if showIcon {
            Label(
                title: {
                    description
                },
                icon: {
                    Image(systemName: DKnowledgeEntity.defaultImageName)
                }
            )
        } else {
            description
        }
    }
}

// struct DKnowledgeBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DKnowledgeBrowserView()
//    }
// }
