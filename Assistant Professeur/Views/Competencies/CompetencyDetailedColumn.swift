//
//  CompetencyDetailedColumn.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/11/2023.
//

import SwiftUI

/// Détail dans la 3ième colonne de la Tab des Compétences
struct CompetencyDetailedColumn: View {
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
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return CompetencyDetailedColumn()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
