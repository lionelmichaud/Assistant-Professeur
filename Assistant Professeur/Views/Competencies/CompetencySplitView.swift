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
                    EmptyListMessage(
                        symbolName: WCompChapterEntity.defaultImageName,
                        title: "Aucun type de compétences sélectionné.",
                        message: "Sélectionner un type de compétence.",
                        showAsGroupBox: true
                    )
                    .padding(.horizontal)

                case .workedCompetencies:
                    /// Compétences travaillées
                    WCompChapterListView()

                case let .disciplineCompetencies(discipline):
                    /// Compétences disciplinaires
                    NavigationStack(path: $nav.competencePath) {
                        // Thème de Compétences disciplinaires
                        DThemeListView(discipline: discipline)
                            .navigationDestination(for: DThemeEntity.self) { theme in
                                // Section de Compétences disciplinaires
                                DSectionListView(
                                    theme: theme,
                                    discipline: discipline
                                )
                            }
                            .navigationDestination(for: DSectionEntity.self) { section in
                                // Compétence disciplinaires
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
                    EmptyListMessage(
                        symbolName: WCompChapterEntity.defaultImageName,
                        title: "Aucun type de compétences sélectionné.",
                        message: "Sélectionner un type de compétence.",
                        showAsGroupBox: true
                    )

                case .workedCompetencies:
                    /// Compétences travaillées
                    NavigationStack {
                        WCompListView()
                            .navigationDestination(for: WCompEntity.self) { workedCompetency in
                                // Critère de maîtrise d'une compétences
                                WCompMasteryLevels(workedComp: workedCompetency)
                            }
                    }

                case .disciplineCompetencies:
                    /// Connaissance disciplinaires
                    DKnowListView()
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
