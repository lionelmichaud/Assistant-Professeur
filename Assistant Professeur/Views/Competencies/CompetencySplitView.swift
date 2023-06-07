//
//  CompetenciesSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import SwiftUI

enum CompetencyTypeSelection: String, Hashable, CaseIterable, Codable {
    case workedCompetencies = "Compétences du socle"
    case disciplineCompetencies = "Compétences disciplinaires"
}

struct CompetencySplitView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            CompetencySidebarView()

        } content: {
            // 2nde colonne
            switch navig.selectedCompetenceType {
                case .none:
                    EmptyListMessage(
                        symbolName: WCompChapterEntity.defaultImageName,
                        title: "Aucun type de compétences sélectionné.",
                        message: "Sélectionner un type de compétence.",
                        showAsGroupBox: true
                    )
                    .padding(.horizontal)

                case .workedCompetencies:
                    WCompChapterListView()

                case .disciplineCompetencies:
                    Text("disciplineCompetencies")
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch navig.selectedCompetenceType {
                case .none:
                    EmptyListMessage(
                        symbolName: WCompChapterEntity.defaultImageName,
                        title: "Aucun type de compétences sélectionné.",
                        message: "Sélectionner un type de compétence.",
                        showAsGroupBox: true
                    )

                case .workedCompetencies:
                    WCompListView()

                case .disciplineCompetencies:
                    Text("disciplineCompetencies")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct CompetencySplitView_Previews: PreviewProvider {
    static var previews: some View {
        CompetencySplitView()
    }
}
