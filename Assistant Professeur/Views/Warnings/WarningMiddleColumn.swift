//
//  WarningMiddleColumn.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/12/2023.
//

import SwiftUI

/// Contenu de la 2ième colonne de la Tab des Avertissements
struct WarningMiddleColumn: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            switch navig.selectedWarningType {
                case .none:
                    ContentUnavailableView(
                        "Aucun type d'avertissement sélectionné...",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Sélectionner un type d'avertissement.")
                    )
                    
                case .colle:
                    ColleSidebarView()
                    
                case .observation:
                    ObservSidebarView()
            }
        }
    }
}

#Preview {
    WarningMiddleColumn()
}
