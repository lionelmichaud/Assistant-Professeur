//
//  WarningSpliView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/03/2023.
//

import SwiftUI

enum WarningSelection: String, Hashable, Codable, CaseIterable {
    case observation = "Observations"
    case colle = "Colles"

    var imageName: String {
        switch self {
            case .observation:
                return ObservEntity.defaultImageName
            case .colle:
                return ColleEntity.defaultImageName
        }
    }
}

struct WarningSplitView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            WarningSidebarView()
                .navigationSplitViewColumnWidth(
                    min: 250,
                    ideal: 350,
                    max: 500
                )

        } content: {
            // 2nde colonne
            switch navig.selectedWarningType {
                case .none:
                    ContentUnavailableView(
                        "Aucun type d'avertissement sélectionné...",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Sélectionner un type d'avertissement.")
                    )

                case .colle:
                    ColleSidebarView()

                case .observation:
                    ObservSidebarView()
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch navig.selectedWarningType {
                case .none:
                    ContentUnavailableView(
                        "Aucun type d'avertissement sélectionné...",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Sélectionner un type d'avertissement.")
                    )

                case .colle:
                    ColleEditor()

                case .observation:
                    ObservEditor()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct WarningSpliView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()

        return Group {
            WarningSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedWarningType: .colle))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            WarningSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedWarningType: .colle))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
