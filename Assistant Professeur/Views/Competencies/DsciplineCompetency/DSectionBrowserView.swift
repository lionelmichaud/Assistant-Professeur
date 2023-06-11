//
//  DSectionBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import AppFoundation
import SwiftUI

struct DSectionBrowserView: View {
    @ObservedObject
    var section: DSectionEntity

    var showIcon: Bool

    var showProgressivity: Bool

    @State
    private var isExpanded: Bool = false

    var description: some View {
        Group {
            Text(section.viewAcronym)
                .fontWeight(.bold) +
                Text(". ") +
                Text(section.viewDescription)
                .foregroundColor(.secondary)
        }
        .lineLimit(5)
        .textSelection(.enabled)
    }

    var progressivity: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(section.viewProgressivity)
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
        if showIcon {
            Label(
                title: {
                    description
                },
                icon: {
                    Image(systemName: DSectionEntity.defaultImageName)
                }
            )
        } else {
            description
        }
        if showProgressivity && section.viewProgressivity.isNotEmpty {
            progressivity
                //.padding(.top, 4)
        }
    }
}

// struct DSectionBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DSectionBrowserView()
//    }
// }
