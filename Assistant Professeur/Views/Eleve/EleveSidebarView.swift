//
//  EleveSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct EleveSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var schoolStore     : SchoolStore
    @EnvironmentObject private var eleveStore      : EleveStore

    // filtrage par nom/prénom
    @State
    private var selectedEleve: Eleve?

    @State
    private var searchString: String = ""
    //@Environment(\.isSearching) var isSearching
    //@Environment(\.dismissSearch) var dismissSearch

    var body: some View {
        List(selection: $navigationModel.selectedEleveId) {
            if eleveStore.items.isEmpty {
                Text("Aucun élève actuellement")
            } else {
                /// pour chaque Etablissement
                ForEach(schoolStore.sortedSchools()) { school in
                    if school.nbOfClasses != 0 {
                        Section {
                            /// pour chaque Classe
                            EleveSidebarSchoolSubview(school       : school,
                                                      searchString : searchString)
                        } header: {
                            Text(school.displayString)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                        }
                    } else {
                        Text("Aucune classe dans cet établissement")
                    }
                }
            }
        }
        .searchable(text      : $searchString,
                    placement : .navigationBarDrawer(displayMode : .automatic),
                    prompt    : "Nom ou Prénom de l'élève")
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
    let school       : School
    let searchString : String

    @State
    private var isClasseExpanded = true

    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var classeStore     : ClasseStore
    @EnvironmentObject private var eleveStore      : EleveStore
    @EnvironmentObject private var colleStore      : ColleStore
    @EnvironmentObject private var observStore     : ObservationStore

    var body: some View {
        /// pour chaque Classe
        ForEach(classeStore.sortedClasses(dans: school)) { $classe in
            if filteredSortedEleves(dans: classe).isNotEmpty {
                DisclosureGroup {
                    /// pour chaque Elève
                    ForEach(filteredSortedEleves(dans: classe)) { $eleve in
                        EleveBrowserRow(eleve: eleve)
                            .swipeActions {
                                // supprimer un élève
                                Button(role: .destructive) {
                                    withAnimation {
                                        // supprimer l'élève et tous ses descendants
                                        // puis retirer l'élève de la classe auquelle il appartient
                                        if eleve.id == navigationModel.selectedEleveId {
                                            navigationModel.selectedEleveId = nil
                                        }
                                        ClasseManager().retirer(eleve       : eleve,
                                                                deClasse    : &classe,
                                                                eleveStore  : eleveStore,
                                                                observStore : observStore,
                                                                colleStore  : colleStore)
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }

                                // flager un élève
                                Button {
                                    withAnimation {
                                        eleve.isFlagged.toggle()
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
            }
        }
    }

    // MARK: - Methods

    func filteredSortedEleves(dans classe: Classe) -> Binding<[Eleve]> {
        EleveManager().filteredEleves(dans              : classe,
                                      eleveStore        : eleveStore,
                                      observStore       : observStore,
                                      colleStore        : colleStore,
                                      filterObservation : navigationModel.filterObservation,
                                      filterColle       : navigationModel.filterColle,
                                      filterFlag        : navigationModel.filterFlag,
                                      searchString      : searchString)
    }
}

struct EleveBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvir.createFakes()
        return Group {
            EleveSidebarView()
                .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPad mini (6th generation)")

            EleveSidebarView()
                .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPiPhone 13")
        }
    }
}
