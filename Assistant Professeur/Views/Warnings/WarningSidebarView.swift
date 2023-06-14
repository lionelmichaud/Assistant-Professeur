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
            WarningSelection.allCases,
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
            .badge(cardinal(warningType))
        }
        .navigationTitle("Avertissements")
    }

    private func cardinal(_ warningType: WarningSelection) -> Int {
        switch warningType {
            case .observation:
                return ObservEntity.cardinal()
            case .colle:
                return ColleEntity.cardinal()
        }
    }
}

struct WarningSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        WarningSidebarView()
    }
}
