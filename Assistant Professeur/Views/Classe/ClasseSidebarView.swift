//
//  ClasseBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI

struct ClasseSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel

    var body: some View {
        Text("EleveSidebarView")
//        List(selection: $navigationModel.selectedClasseId) {
//            if classeStore.items.isEmpty {
//                Text("Aucune classe actuellement")
//            } else {
//                /// pour chaque Etablissement
//                ForEach(schoolStore.sortedSchools()) { $school in
//                    if school.nbOfClasses != 0 {
//                        Section {
//                            /// pour chaque Classe
//                            ClasseSidebarSchoolSubview(school: $school)
//                        } header: {
//                            Text(school.displayString)
//                                .font(.callout)
//                                .foregroundColor(.secondary)
//                                .fontWeight(.bold)
//                        }
//                    }
//                }
//            }
//        }
        .navigationTitle("Les Classes")
    }
}

//struct ClasseSidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
