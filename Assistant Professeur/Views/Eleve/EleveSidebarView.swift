//
//  EleveSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct EleveSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel

    // filtrage par nom/prénom
//    @State
//    private var selectedEleve: Eleve?

    @State
    private var searchString: String = ""
    //@Environment(\.isSearching) var isSearching
    //@Environment(\.dismissSearch) var dismissSearch

    var body: some View {
        Text("EleveSidebarView")
//        List(selection: $navigationModel.selectedEleveId) {
//            if eleveStore.items.isEmpty {
//                Text("Aucun élève actuellement")
//            } else {
//                /// pour chaque Etablissement
//                ForEach(schoolStore.sortedSchools()) { school in
//                    if school.nbOfClasses != 0 {
//                        Section {
//                            /// pour chaque Classe
//                            EleveSidebarSchoolSubview(school       : school,
//                                                      searchString : searchString)
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
//        .searchable(text      : $searchString,
//                    placement : .navigationBarDrawer(displayMode : .automatic),
//                    prompt    : "Nom ou Prénom de l'élève")
//        .autocorrectionDisabled()
//        .toolbar {
//            ToolbarItemGroup(placement: .status) {
//                Text("Filtrer")
//                    .foregroundColor(.secondary)
//                    .padding(.trailing, 4)
//                Toggle(isOn: $navigationModel.filterObservation.animation(),
//                       label: {
//                    Image(systemName: "magnifyingglass")
//                })
//                .toggleStyle(.button)
//                .padding(.trailing, 4)
//
//                Toggle(isOn: $navigationModel.filterColle.animation(),
//                       label: {
//                    Image(systemName: "lock")
//                })
//                .toggleStyle(.button)
//                .padding(.trailing, 4)
//
//                Toggle(isOn: $navigationModel.filterFlag.animation(),
//                       label: {
//                    Image(systemName: "flag")
//                })
//                .toggleStyle(.button)
//            }
//        }
        .navigationTitle("Les Élèves")
    }
}

//struct EleveBrowserView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            EleveSidebarView()
//                .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            EleveSidebarView()
//                .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPiPhone 13")
//        }
//    }
//}
