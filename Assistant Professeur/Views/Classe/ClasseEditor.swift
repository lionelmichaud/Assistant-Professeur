//
//  ClasseEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import SwiftUI
import HelpersView
import CoreData

struct ClasseEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed Properties

    private var selectedClasseId: NSManagedObjectID? {
        navigationModel.selectedClasseMngObjId
    }

    private var selectedClasse: ClasseEntity? {
        guard let selectedClasseId else { return nil }
        return ClasseEntity.byObjectId(MngObjID: selectedClasseId)
    }

    private var selectedClasseExists: Bool {
        selectedClasse != nil
    }

    var body: some View {
        if selectedClasseExists {
            ClasseDetail(classe: selectedClasse!)
        } else {
            VStack(alignment: .center) {
                Text("Aucune classe sélectionnée.")
                Text("Sélectionner une classe.")
            }
            .foregroundStyle(.secondary)
            .font(.title)
        }
    }
}

//struct ClasseEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ClasseEditor()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ClasseEditor()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
