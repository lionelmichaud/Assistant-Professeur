//
//  DThemeBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import SwiftUI

struct DThemeBrowserView: View {
    @ObservedObject
    var theme: DThemeEntity

    var showIcon: Bool

    var body: some View {
        if showIcon {
            Label(
                title: {
                    Group {
                        Text(theme.viewAcronym)
                            .fontWeight(.bold) +
                        Text(". ") +
                        Text(theme.viewDescription)
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(5)
                },
                icon: {
                    Image(systemName: DThemeEntity.defaultImageName)
                }
            )
        } else {
            Group {
                Text(theme.viewAcronym)
                    .fontWeight(.bold) +
                Text(". ") +
                Text(theme.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
        }
    }
}

//struct DThemeBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DThemeBrowserView()
//    }
//}
