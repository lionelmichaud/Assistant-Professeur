//
//  ColleEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/10/2022.
//

import SwiftUI
import CoreData

struct ColleEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed properties

    private var selectedColleId: NSManagedObjectID? {
        navigationModel.selectedColleId
    }

    private var selectedColle: ColleEntity? {
        guard let selectedColleId else { return nil }
        return ColleEntity.byId(id: selectedColleId)
    }

    private var selectedColleExists: Bool {
        selectedColle != nil
    }

    var body: some View {
        if selectedColleExists {
            ColleDetail(colle: selectedColle!)
        } else {
            VStack(alignment: .center) {
                Text("Aucune colle sélectionnée.")
                Text("Sélectionner une colle.")
            }
            .foregroundStyle(.secondary)
            .font(.title)
        }
    }
}

//struct ColleEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ColleEditor()
//                    .environmentObject(NavigationModel())
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ColleEditor()
//                    .environmentObject(NavigationModel(selectedColleId: TestEnvir.colleStore.items.first!.id))
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
