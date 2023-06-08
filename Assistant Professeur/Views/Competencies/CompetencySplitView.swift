//
//  CompetenciesSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import SwiftUI

enum CompetencySelection: Hashable, Codable {
    case workedCompetencies
    case disciplineCompetencies(discipline: Discipline)

    var label: String {
        switch self {
            case .workedCompetencies:
                return "Compétences du socle"
                
            case .disciplineCompetencies(discipline: let discipline):
                return discipline.displayString
        }
    }
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
