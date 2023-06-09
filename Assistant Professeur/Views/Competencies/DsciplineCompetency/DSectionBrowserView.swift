//
//  DSectionBrowserView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import SwiftUI

struct DSectionBrowserView: View {
    @ObservedObject
    var disciplineSection: DSectionEntity

    var body: some View {
        Label(
            title: {
                Text(disciplineSection.viewAcronym)
                    .fontWeight(.bold)
                Text(disciplineSection.viewDescription)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            },
            icon: {
                Image(systemName: DSectionEntity.defaultImageName)
            }
        )
    }
}

//struct DSectionBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        DSectionBrowserView()
//    }
//}
