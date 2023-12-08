//
//  ClasseSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI

/// Vues des Classes
struct ClasseSplitView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            ClasseSidebarView()
                .navigationSplitViewColumnWidth(
                    min: 250,
                    ideal: 350,
                    max: 500
                )

        } detail: {
            // Détail dans la 2ième colonne
            NavigationStack(path: $navig.classPath) {
                ClasseEditor()
                    // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                    .id(navig.selectedClasseMngObjId)
                    .navigationDestination(for: ClasseNavigationRoute.self) { route in
                        route.destination(horizontalSizeClass: horizontalSizeClass)
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
    return ClasseSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
