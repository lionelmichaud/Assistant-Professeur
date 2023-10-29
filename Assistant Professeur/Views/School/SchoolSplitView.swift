//
//  SchoolSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI

struct SchoolSplitView: View {
    @EnvironmentObject
    private var navig : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            SchoolSidebarView()

        } detail: {
            // Détail dans la 2ième colonne
            NavigationStack(path: $navig.schoolPath) {
                SchoolEditor()
                    .navigationDestination(for: SchoolNavigationRoute.self) { route in
                        route.destination()
                    }
            }
        }
    }
}

//struct SchoolSplitView_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            SchoolSplitView()
//                .padding()
//                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//
//            SchoolSplitView()
//                .padding()
//                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
//}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return SchoolSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: SchoolEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
