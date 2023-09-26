//
//  EleveEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/04/2022.
//

import CoreData
import HelpersView
import SwiftUI

struct EleveEditor: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    // MARK: - Computed Properties

    private var selectedEleveId: NSManagedObjectID? {
        navigationModel.selectedEleveMngObjId
    }

    private var selectedEleve: EleveEntity? {
        guard let selectedEleveId else {
            return nil
        }
        return EleveEntity.byObjectId(MngObjID: selectedEleveId)
    }

    private var selectedEleveExists: Bool {
        selectedEleve != nil
    }

    var body: some View {
        if selectedEleveExists {
            EleveDetail(eleve: selectedEleve!)
        } else {
            ContentUnavailableView(
                "Aucun élève sélectionné...",
                systemImage: EleveEntity.defaultImageName,
                description: Text("Sélectionner un élève pour en visualiser les détails ici.")
            )
        }
    }
}

struct EleveEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveEditor()
                .previewDevice("iPad mini (6th generation)")

            EleveEditor()
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
