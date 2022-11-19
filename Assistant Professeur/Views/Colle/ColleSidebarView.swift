//
//  ColleBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI

struct ColleSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel
    @State private var filterColle = true

    var body: some View {
        Text("ColleSidebarView")
//        List(selection: $navigationModel.selectedColleId) {
//            if colleStore.items.isEmpty {
//                Text("Aucune colle actuellement")
//            } else {
//                /// pour chaque Etablissement
//                ForEach(schoolStore.sortedSchools()) { school in
//                    if school.nbOfClasses != 0 {
//                        Section {
//                            /// pour chaque Classe
//                            ColleBrowserSchoolSubiew(school      : school,
//                                                     filterColle : filterColle)
//                        } header: {
//                            Text(school.displayString)
//                                .font(.callout)
//                                .foregroundColor(.secondary)
//                                .fontWeight(.bold)
//                        }
//                    } else {
//                        Text("Aucune classe dans cet établissement")
//                    }
//                }
//            }
//        }
//        .toolbar {
//            ToolbarItemGroup(placement: .status) {
//                Toggle(isOn: $filterColle.animation(),
//                       label: {
//                    Text("A faire")
//                })
//                .toggleStyle(.button)
//            }
//        }
        .navigationTitle("Les Colles")
    }
}
//struct ColleBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ColleSidebarView()
//                .environmentObject(NavigationModel(selectedColleId: TestEnvir.eleveStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//        }
//    }
//}
