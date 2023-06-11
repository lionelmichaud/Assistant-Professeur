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

    var showProgressivity: Bool

    @State
    private var isExpanded: Bool = false

    var description: some View {
        Group {
            Text(theme.viewAcronym)
                .fontWeight(.bold) +
                Text(". ") +
                Text(theme.viewDescription)
                .foregroundColor(.secondary)
        }
        .lineLimit(5)
        .textSelection(.enabled)
    }

    var progressivity: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(theme.viewProgressivity)
                .foregroundColor(.secondary)
                // .lineLimit(5)
                .textSelection(.enabled)
        } label: {
            Text("Repères de progressivité: ")
                .fontWeight(.bold)
                .font(.callout)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showIcon {
                Label(
                    title: {
                        description
                    },
                    icon: {
                        Image(systemName: DThemeEntity.defaultImageName)
                    }
                )
            } else {
                description
            }
            if showProgressivity && theme.viewProgressivity.isNotEmpty {
                progressivity
                    .padding(.top, 4)
            }
        }
    }
}

// struct DThemeBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DThemeBrowserView()
//    }
// }
