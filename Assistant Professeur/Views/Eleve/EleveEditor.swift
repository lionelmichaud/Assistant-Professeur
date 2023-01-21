//
//  EleveEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/04/2022.
//

import SwiftUI
import HelpersView
import CoreData

struct EleveEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed Properties

    private var selectedEleveId: NSManagedObjectID? {
        navigationModel.selectedEleveId
    }

    private var selectedEleve: EleveEntity? {
        guard let selectedEleveId else { return nil }
        return EleveEntity.byObjectId(id: selectedEleveId)
    }

    private var selectedEleveExists: Bool {
        selectedEleve != nil
    }

    var body: some View {
        if selectedEleveExists {
            EleveDetail(eleve: selectedEleve!)
        } else {
            VStack(alignment: .center) {
                Text("Aucun élève sélectionné.")
                Text("Sélectionner un élève.")
            }
            .foregroundStyle(.secondary)
            .font(.title)
        }
    }
}

//struct EleveEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                EleveEditor()
//                    .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                EleveEditor()
//                    .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
