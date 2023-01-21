//
//  ObservEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 06/10/2022.
//

import SwiftUI
import CoreData

struct ObservEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed properties

    private var selectedObservId: NSManagedObjectID? {
        navigationModel.selectedObservId
    }

    private var selectedObserv: ObservEntity? {
        guard let selectedObservId else { return nil }
        return ObservEntity.byObjectId(id: selectedObservId)
    }

    private var selectedObservExists: Bool {
        selectedObserv != nil
    }

    var body: some View {
        if selectedObservExists {
            ObservDetail(observ: selectedObserv!)
        } else {
            VStack(alignment: .center) {
                Text("Aucune observation sélectionnée.")
                Text("Sélectionner une observation.")
            }
            .foregroundStyle(.secondary)
            .font(.title)
        }
    }
}

//struct ObservEditor_Previews: PreviewProvider {
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
//}
