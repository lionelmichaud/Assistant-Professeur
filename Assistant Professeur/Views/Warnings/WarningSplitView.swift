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

    @State
    private var preferredColumn = NavigationSplitViewColumn.detail

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility,
            preferredCompactColumn: $preferredColumn
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
            WarningMiddleColumn()

        } detail: {
            // Détail dans la 3ième colonne
            WarningDetailColumn()
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return WarningSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
