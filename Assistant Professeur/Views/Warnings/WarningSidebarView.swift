//
//  WarningSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/03/2023.
//

import SwiftUI

struct WarningSidebarView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        List(
            NavigationModel.WarningSelection.allCases,
            id: \.self,
            selection: $navig.selectedWarningType
        ) { warningType in
            Label(
                title: {
                    Text(warningType.rawValue)
                        .fontWeight(.bold)
                },
                icon: {
                    Image(systemName: warningType.imageName)
                }
            )
        }
        .navigationTitle("Avertissements")
    }
}

struct WarningSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        WarningSidebarView()
    }
}
