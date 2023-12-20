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
    private var navig: NavigationModel

    @Environment(Store.self)
    private var store

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        ZStack {
            if store.isPurchased(service: .competency) {
                NavigationSplitView(
                    columnVisibility: $navig.columnVisibility
                ) {
                    // 1ère colonne
                    CompetencySidebarView()

                } content: {
                    // 2nde colonne
                    CompetencyMiddleColumn()
                        // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                        .id(navig.selectedCompetenceType)

                } detail: {
                    // Détail dans la 3ième colonne
                    CompetencyDetailedColumn()
                        // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                        .id(navig.selectedCompetenceType)
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                VStack {
                    Image(.ecranIPadCompetency)
                        .resizable()
                        .scaledToFit()
                    Text("Pour avoir accès à la **gestion des compétences** et les associer à vos activités pédagogiques, rendez-vous en magazin.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .frame(maxWidth: hClass == .regular ? 600 : 300)
                    Button("Magazin") {
                        store.isShowingStore = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }
        }
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
