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
    private var navigationModel: NavigationModel

    // MARK: - Computed Properties

    private var selectedSchoolId: NSManagedObjectID? {
        navigationModel.selectedSchoolMngObjId
    }

    private var selectedSchool: SchoolEntity? {
        guard let selectedSchoolId else {
            return nil
        }
        return SchoolEntity.byObjectId(MngObjID: selectedSchoolId)
    }

    private var selectedSchoolExists: Bool {
        selectedSchool != nil
    }

    var body: some View {
        if selectedSchoolExists {
            SchoolDetail(school: selectedSchool!)
        } else {
            EmptyListMessage(
                symbolName: SchoolEntity.defaultImageName,
                title: "Aucun établissement sélectionné.",
                message: "Sélectionner un établissement pour en visualiser les détails ici.",
                showAsGroupBox: true
            )
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
