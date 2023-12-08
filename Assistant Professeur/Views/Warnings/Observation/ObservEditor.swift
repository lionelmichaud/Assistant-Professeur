//
//  ObservEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/10/2022.
//

import CoreData
import SwiftUI

struct ObservEditor: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        ZStack { // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
            if let selectedObservId = navig.selectedObservMngObjId,
               let selectedObserv = ObservEntity.byObjectId(MngObjID: selectedObservId) {
                ObservDetail(observ: selectedObserv)
            } else {
                ContentUnavailableView(
                    "Aucune observation sélectionnée...",
                    systemImage: ObservEntity.defaultImageName,
                    description: Text("Sélectionner une observation pour en visualiser les détails ici.")
                )
            }
        }
    }
}

// struct ObservEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ObservEditor()
//                    .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ObservEditor()
//                    .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
