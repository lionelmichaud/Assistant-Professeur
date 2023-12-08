//
//  CompetencyMiddleColumn.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/11/2023.
//

import SwiftUI

/// Contenu de la 2ième colonne de la Tab des Compétences
struct CompetencyMiddleColumn: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            switch navig.selectedCompetenceType {
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
                    NavigationStack(path: $navig.competencePath) {
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
        }
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return CompetencyMiddleColumn()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
