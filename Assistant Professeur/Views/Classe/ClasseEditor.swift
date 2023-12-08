//
//  ClasseEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import CoreData
import HelpersView
import SwiftUI

struct ClasseEditor: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            if let selectedClasseId = navig.selectedClasseMngObjId,
               let selectedClasse = ClasseEntity.byObjectId(MngObjID: selectedClasseId) {
                ClasseDetail(classe: selectedClasse)
            } else {
                ContentUnavailableView(
                    "Aucune classe sélectionnée...",
                    systemImage: ClasseEntity.defaultImageName,
                    description: Text("Sélectionner une classe pour en visualiser les détails ici.")
                )
            }
        }
    }
}

struct ClasseEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                ClasseEditor()
                    .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                ClasseEditor()
                    .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPhone 13")
        }
    }
}
