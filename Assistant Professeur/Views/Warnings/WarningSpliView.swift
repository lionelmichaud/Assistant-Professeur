//
//  WarningSpliView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/03/2023.
//

import SwiftUI

struct WarningSpliView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            WarningSidebarView()
                .navigationSplitViewColumnWidth(min: 250,
                                                ideal: 350,
                                                max: 500)

        } content: {
            // 2nde colonne
            switch navig.selectedWarningType {
                case .colle:
                    ColleSidebarView()
                case .observation:
                    ObservSidebarView()
                case .none:
                    Text("Sélectionner un type d'avertissement")
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch navig.selectedWarningType {
                case .colle:
                    ColleEditor()
                case .observation:
                    ObservEditor()
                case .none:
                    Text("Sélectionner un type d'avertissement")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct WarningSpliView_Previews: PreviewProvider {
    static var previews: some View {
        WarningSpliView()
    }
}
