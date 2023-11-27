//
//  EleveSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import HelpersView
import SwiftUI

struct EleveSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var searchString: String = ""
    // @Environment(\.isSearching) var isSearching
    // @Environment(\.dismissSearch) var dismissSearch

    @FetchRequest<SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        animation: .default
    )
    private var schools: FetchedResults<SchoolEntity>

    var body: some View {
        List(selection: $navigationModel.selectedEleveMngObjId) {
            // pour chaque Etablissement
            ForEach(schools) { school in
                if school.nbOfClasses != 0 {
                    Section {
                        // pour chaque Classe
                        EleveSidebarSchoolSubview(
                            school: school,
                            searchString: searchString
                        )
                    } header: {
                        Text(school.displayString)
                            .style(.sectionHeader)
                    }
                } else {
                    EmptyView()
                }
            }
            .emptyListPlaceHolder(schools) {
                ContentUnavailableView(
                    "Aucun établissement actuellement...",
                    systemImage: SchoolEntity.defaultImageName
                )
            }
        }
        .searchable(
            text: $searchString,
//            placement : .navigationBarDrawer(displayMode : .automatic),
            placement: .toolbar,
            prompt: "Nom,prénom,groupe,commentaire"
        )
        .autocorrectionDisabled()
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                Text("Filtrer")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                Toggle(
                    isOn: $navigationModel.filterObservation.animation(),
                    label: {
                        Image(systemName: ObservEntity.defaultImageName)
                    }
                )
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(
                    isOn: $navigationModel.filterColle.animation(),
                    label: {
                        Image(systemName: ColleEntity.defaultImageName)
                    }
                )
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(
                    isOn: $navigationModel.filterFlag.animation(),
                    label: {
                        Image(systemName: "flag")
                    }
                )
                .toggleStyle(.button)
            }
        }
        .navigationTitle("Mes Élèves")
    }
}

struct EleveSidebarSchoolSubview: View {
    @ObservedObject
    var school: SchoolEntity

    let searchString: String

    var body: some View {
        // pour chaque Classe
        ForEach(school.classesSortedByLevelNumber) { classe in
            EleveSidebarClasseSubview(
                classe: classe,
                searchString: searchString
            )
        }
    }
}

struct EleveSidebarClasseSubview: View {
    @ObservedObject
    var classe: ClasseEntity

    let searchString: String

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @Environment(\.isSearching)
    private var isSearching

    @State
    private var isClasseExpanded = false

    @State
    private var filteredEleveInClasse = [EleveEntity]()

    @State
    private var numberOfHit = 0

    var taskId: String {
        searchString
            + navigationModel.filterFlag.description
            + navigationModel.filterColle.description
            + navigationModel.filterObservation.description
            + (classe.id?.uuidString ?? "nil")
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isClasseExpanded) {
            if classe.nbOfEleves != 0 {
                // pour chaque Elève
                if filteredEleveInClasse.isNotEmpty {
                    ForEach(filteredEleveInClasse, id: \.objectID) { eleve in
                        EleveBrowserRow(eleve: eleve)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // supprimer un élève
                                Button(role: .destructive) {
                                    withAnimation {
                                        // supprimer l'élève et tous ses descendants
                                        if navigationModel.selectedEleveMngObjId == eleve.objectID {
                                            navigationModel.selectedEleveMngObjId = nil
                                        }
                                        // ATTENTION: à mettre en dernier
                                        try? eleve.delete()
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
                } else {
                    ContentUnavailableView.search
                }
            } else {
                ContentUnavailableView(
                    "Aucun élève actuellement...",
                    systemImage: EleveEntity.defaultImageName,
                    description: Text("Les élèves ajoutés apparaîtront ici.")
                )
            }

        } label: {
            HStack {
                Text(classe.displayString)
                Spacer()
                Text("\(isSearching ? numberOfHit : classe.nbOfEleves) élèves")
            }
            .font(.callout)
            .foregroundColor(.secondary)
            .fontWeight(.bold)
        }
        .padding(.leading, 4)

        // Filtrer les élèves
        .task(id: taskId) {
            filteredEleveInClasse = classe.filteredElevesSortedByName(
                searchString: searchString,
                withObservation: navigationModel.filterObservation,
                withColle: navigationModel.filterColle,
                withFlag: navigationModel.filterFlag,
                nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
            )
            numberOfHit = filteredEleveInClasse.count
            isClasseExpanded = (searchString.isNotEmpty && numberOfHit > 0) ||
                (navigationModel.filterObservation && numberOfHit > 0) ||
                (navigationModel.filterColle && numberOfHit > 0) ||
                (navigationModel.filterFlag && numberOfHit > 0)
        }
    }
}

struct EleveBrowserView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveSidebarView()
                .previewDevice("iPad mini (6th generation)")

            EleveSidebarView()
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
