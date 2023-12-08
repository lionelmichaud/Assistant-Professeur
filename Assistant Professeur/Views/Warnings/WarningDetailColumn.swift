//
//  WarningDetailColumn.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/12/2023.
//

import SwiftUI

/// Détail dans la 3ième colonne de la Tab des Avertissements
struct WarningDetailColumn: View {
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
                    ColleEditor()
                        // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                        .id(navig.selectedColleMngObjId)

                case .observation:
                    ObservEditor()
                        // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                        .id(navig.selectedObservMngObjId)
            }
        }
        }
}

#Preview {
    WarningDetailColumn()
}
