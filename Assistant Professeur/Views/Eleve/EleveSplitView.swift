//
//  EleveSplitView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/10/2022.
//

import SwiftUI

struct EleveSplitView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var preferredColumn = NavigationSplitViewColumn.sidebar

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility,
            preferredCompactColumn: $preferredColumn
        ) {
            // 1ère colonne
            EleveSidebarView()
                .navigationSplitViewColumnWidth(
                    min: 250,
                    ideal: 350,
                    max: 500
                )
                // Afficher la colonne détail sur iPhone
                .onChange(of: navig.selectedEleveMngObjId) {
                    if navig.selectedEleveMngObjId != nil {
                        preferredColumn = .detail
                    }
                }

        } detail: {
            // Détail dans la 2ième colonne
            EleveEditor()
        }
    }
}

// struct EleveSplitView_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            EleveSplitView()
//                .padding()
//                .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//
//            EleveSplitView()
//                .padding()
//                .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
// }

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return EleveSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
