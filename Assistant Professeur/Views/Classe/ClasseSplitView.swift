//
//  ClasseSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI

struct ClasseSplitView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @EnvironmentObject
    private var navig : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            ClasseSidebarView()
                .navigationSplitViewColumnWidth(min: 250,
                                                ideal: 350,
                                                max: 500)

        } detail: {
            // Détail dans la 2ième colonne
            NavigationStack(path: $navig.classPath) {
                ClasseEditor()
                    .navigationDestination(for: ClasseNavigationRoute.self) { route in
                        route.destination(horizontalSizeClass: horizontalSizeClass)
                    }
            }
        }
    }
}

struct ClasseSplitView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
