//
//  SchoolEditor.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import SwiftUI
import CoreData

struct SchoolEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed Properties

    private var selectedSchoolId: NSManagedObjectID? {
        navigationModel.selectedSchoolId
    }

    private var selectedSchool: SchoolEntity? {
        guard let selectedSchoolId else { return nil }
        return SchoolEntity.byObjectId(id: selectedSchoolId)
    }

    private var selectedSchoolExists: Bool {
        selectedSchool != nil
    }

    var body: some View {
        if selectedSchoolExists {
            SchoolDetail(school: selectedSchool!)
        } else {
            VStack(alignment: .center) {
                Text("Aucun établissement sélectionné.")
                Text("Sélectionner un établissement.")
            }
            .foregroundStyle(.secondary)
            .font(.title)
        }
    }
}

//struct SchoolEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                SchoolEditor()
//                    .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                SchoolEditor()
//                    .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
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
