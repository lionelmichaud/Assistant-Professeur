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
    private var navig: NavigationModel

    // MARK: - Computed Properties

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            if let selectedEleveMngObjId = navig.selectedEleveMngObjId,
               let selectedEleve = EleveEntity.byObjectId(MngObjID: selectedEleveMngObjId) {
                EleveDetail(eleve: selectedEleve)
            } else {
                ContentUnavailableView(
                    "Aucun élève sélectionné...",
                    systemImage: EleveEntity.defaultImageName,
                    description: Text("Sélectionner un élève pour en visualiser les détails ici.")
                )
            }
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
