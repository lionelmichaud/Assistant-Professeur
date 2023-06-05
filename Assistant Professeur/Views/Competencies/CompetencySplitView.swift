//
//  CompetenciesSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import SwiftUI

struct CompetencySplitView: View {
    @EnvironmentObject
    private var navig : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            CompetencySidebarView()

        } content: {
            // 2nde colonne
            Text("colonne")

        } detail: {
            // Détail dans la 3ième colonne
            Text("détail")
        }
    }
}

struct CompetencySplitView_Previews: PreviewProvider {
    static var previews: some View {
        CompetencySplitView()
    }
}
