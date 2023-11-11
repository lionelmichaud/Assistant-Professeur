//
//  CompetenciesSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import SwiftUI

/// Natures des compétences: Socle commun / Disciplinaires
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

/// Contenu de la Tab des Compétences
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
            CompetencyMiddleColumn()

        } detail: {
            // Détail dans la 3ième colonne
            CompetencyDetailedColumn()
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return CompetencySplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
