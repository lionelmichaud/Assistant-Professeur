//
//  SchoolEditor.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import CoreData
import SwiftUI

struct SchoolEditor: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            if let selectedSchoolId = navig.selectedSchoolMngObjId,
               let selectedSchool = SchoolEntity.byObjectId(MngObjID: selectedSchoolId) {
                SchoolDetail(school: selectedSchool)
            } else {
                ContentUnavailableView(
                    "Aucun établissement sélectionné...",
                    systemImage: SchoolEntity.defaultImageName,
                    description: Text("Sélectionner un établissement pour en visualiser les détails ici.")
                )
            }
        }
    }
}

struct SchoolEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SchoolEditor()
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            SchoolEditor()
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
