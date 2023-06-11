//
//  DCompBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/06/2023.
//

import SwiftUI

struct DCompBrowserView: View {
    @ObservedObject
    var competency: DCompEntity

    var showIcon: Bool

    var body: some View {
        if showIcon {
            Label(
                title: {
                    Group {
                        Text(competency.viewAcronym)
                            .fontWeight(.bold) +
                            Text(". ") +
                            Text(competency.viewDescription)
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(5)
                },
                icon: {
                    Image(systemName: DCompEntity.defaultImageName)
                }
            )
        } else {
            Group {
                Text(competency.viewAcronym)
                    .fontWeight(.bold) +
                    Text(". ") +
                    Text(competency.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
        }
    }
}

// struct DCompBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompBrowserView()
//    }
// }
