//
//  DCompBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/06/2023.
//

import SwiftUI

struct DCompBrowserRow: View {
    @ObservedObject
    var competency: DCompEntity

    var showIcon: Bool

    var description: some View {
        Group {
            Text(competency.viewAcronym)
                .fontWeight(.bold) +
            Text(". ") +
            Text(competency.viewDescription)
                .foregroundColor(.secondary)
        }
        .lineLimit(5)
        .textSelection(.enabled)
    }

    var body: some View {
        if showIcon {
            Label(
                title: {
                    VStack {
                        description
                    }
                },
                icon: {
                    Image(systemName: DCompEntity.defaultImageName)
                }
            )
        } else {
            description
        }
    }
}

// struct DCompBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompBrowserView()
//    }
// }
