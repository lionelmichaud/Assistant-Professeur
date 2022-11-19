//
//  ObservBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 26/04/2022.
//

import SwiftUI

struct ObservSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel

    @State
    private var filterObservation = true

    var body: some View {
        Text("ObservationSidebarView")
//        List(selection: $navigationModel.selectedObservId) {
//            if observStore.items.isEmpty {
//                Text("Aucune observation actuellement")
//            } else {
//                /// pour chaque Etablissement
//                ForEach(schoolStore.sortedSchools()) { school in
//                    if school.nbOfClasses != 0 {
//                        Section {
//                            /// pour chaque Classe
//                            ObservBrowserSchoolSubiew(school            : school,
//                                                      filterObservation : filterObservation)
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
//                Toggle(isOn: $filterObservation.animation(),
//                       label: {
//                    Text("A faire")
//                })
//                .toggleStyle(.button)
//            }
//        }
        .navigationTitle("Les Observations")
    }
}

//struct ObservBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ObservSidebarView()
//                .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//        }
//    }
//}
