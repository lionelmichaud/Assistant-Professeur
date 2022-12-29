//
//  EleveSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct EleveSidebarView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var searchString: String = ""
    //@Environment(\.isSearching) var isSearching
    //@Environment(\.dismissSearch) var dismissSearch

    @FetchRequest<SchoolEntity>(
        fetchRequest : SchoolEntity.requestAllSortedByLevelName,
        animation    : .default
    )
    private var schools: FetchedResults<SchoolEntity>

    var body: some View {
        List(selection: $navigationModel.selectedEleveId) {
            if EleveEntity.all().isEmpty {
                Text("Aucun élève actuellement")
            } else {
                /// pour chaque Etablissement
                ForEach(schools) { school in
                    if school.nbOfClasses != 0 {
                        Section {
                            /// pour chaque Classe
                            EleveSidebarSchoolSubview(school       : school,
                                                      searchString : searchString)
                        } header: {
                            Text(school.displayString)
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        .searchable(
            text      : $searchString,
            placement : .navigationBarDrawer(displayMode : .automatic),
            prompt    : "Nom ou Prénom de l'élève"
        )
        .autocorrectionDisabled()
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                Text("Filtrer")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                Toggle(isOn: $navigationModel.filterObservation.animation(),
                       label: {
                    Image(systemName: "magnifyingglass")
                })
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(isOn: $navigationModel.filterColle.animation(),
                       label: {
                    Image(systemName: "lock")
                })
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(isOn: $navigationModel.filterFlag.animation(),
                       label: {
                    Image(systemName: "flag")
                })
                .toggleStyle(.button)
            }
        }
        .navigationTitle("Les Élèves")
    }
}

struct EleveSidebarSchoolSubview : View {
    @ObservedObject
    var school: SchoolEntity

    let searchString : String

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var isClasseExpanded = true

    var body: some View {
        /// pour chaque Classe
        ForEach(school.classesSortedByLevelNumber) { classe in
            if classe.nbOfEleves != 0 {
                DisclosureGroup {
                    /// pour chaque Elève
                    ForEach(
                        classe
                            .filteredElevesSortedByName(
                                searchString      : searchString,
                                filterObservation : navigationModel.filterObservation,
                                filterColle       : navigationModel.filterColle,
                                filterFlag        : navigationModel.filterFlag
                            ),
                        id: \.objectID
                    ) { eleve in
                        EleveBrowserRow(eleve: eleve)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // supprimer un élève
                                Button(role: .destructive) {
                                    withAnimation {
                                        // supprimer l'élève et tous ses descendants
                                        try? eleve.delete()
                                        if navigationModel.selectedEleveId == eleve.objectID {
                                            navigationModel.selectedEleveId = nil
                                        }
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }

                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                // flager un élève
                                Button {
                                    withAnimation {
                                        eleve.toggleFlag()
                                    }
                                } label: {
                                    if eleve.isFlagged {
                                        Label("Sans drapeau", systemImage: "flag.slash")
                                    } else {
                                        Label("Avec drapeau", systemImage: "flag.fill")
                                    }
                                }.tint(.orange)
                            }
                    }
                } label: {
                    Text(classe.displayString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
                .padding(.leading, 4)
            } else {
                EmptyView()
            }
        }
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
