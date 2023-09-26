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

            case let .disciplineCompetencies(discipline: discipline):
                return discipline.displayString
        }
    }
}

struct CompetencySplitView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $nav.columnVisibility
        ) {
            // 1ère colonne
            CompetencySidebarView()

        } content: {
            // 2nde colonne
            switch nav.selectedCompetenceType {
                case .none:
                    ContentUnavailableView(
                        "Aucun type de compétences sélectionné...",
                        systemImage: WCompChapterEntity.defaultImageName,
                        description: Text("Sélectionner un type de compétence.")
                    )

                case .workedCompetencies:
                    // Compétences travaillées
                    WCompChapterListView()

                case let .disciplineCompetencies(discipline):
                    // Compétences disciplinaires
                    NavigationStack(path: $nav.competencePath) {
                        // Thème de Compétences disciplinaires
                        DThemeListView(discipline: discipline)
                            // Section de Compétences disciplinaires
                            .navigationDestination(for: DThemeEntity.self) { theme in
                                DSectionListView(
                                    theme: theme,
                                    discipline: discipline
                                )
                            }
                            // Compétence disciplinaires
                            .navigationDestination(for: DSectionEntity.self) { section in
                                DCompListView(
                                    section: section,
                                    discipline: discipline
                                )
                            }
                    }
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch nav.selectedCompetenceType {
                case .none:
                    ContentUnavailableView(
                        "Aucun type de compétences sélectionné...",
                        systemImage: WCompChapterEntity.defaultImageName,
                        description: Text("Sélectionner un type de compétence.")
                    )

                case .workedCompetencies:
                    // Compétences travaillées
                    NavigationStack {
                        WCompListView()
                            // Critère de maîtrise d'une compétences travaillées
                            .navigationDestination(for: WCompEntity.self) { workedCompetency in
                                WCompMasteryLevels(workedComp: workedCompetency)
                            }
                    }

                case .disciplineCompetencies:
                    // Connaissance disciplinaires
                    NavigationStack {
                        DKnowListView()
                            // Critère de maîtrise d'une compétences travaillées
                            .navigationDestination(for: WCompEntity.self) { workedCompetency in
                                WCompMasteryLevels(workedComp: workedCompetency)
                            }
                    }
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
