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
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                } else {
                    EmptyView()
                }
            }
            .emptyListPlaceHolder(schools) {
                EmptyListMessage(
                    symbolName: SchoolEntity.defaultImageName,
                    title: "Aucun établissement actuellement."
                )
            }
        }
        .searchable(
            text: $searchString,
//            placement : .navigationBarDrawer(displayMode : .automatic),
            placement: .toolbar,
            prompt: "Nom ou Prénom de l'élève"
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
        .navigationTitle("Les Élèves")
    }
}

struct EleveSidebarSchoolSubview: View {
    @ObservedObject
    var school: SchoolEntity

    let searchString: String

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var isClasseExpanded = true

    private func eleveInClasse(_ classe: ClasseEntity) -> [EleveEntity] {
        classe.filteredElevesSortedByName(
            searchString: searchString,
            filterObservation: navigationModel.filterObservation,
            filterColle: navigationModel.filterColle,
            filterFlag: navigationModel.filterFlag
        )
    }

    var body: some View {
        // pour chaque Classe
        ForEach(school.classesSortedByLevelNumber) { classe in
            if classe.nbOfEleves != 0 {
                DisclosureGroup {
                    // pour chaque Elève
                    ForEach(eleveInClasse(classe), id: \.objectID) { eleve in
                        EleveBrowserRow(eleve: eleve)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // supprimer un élève
                                Button(role: .destructive) {
                                    withAnimation {
                                        // supprimer l'élève et tous ses descendants
                                        try? eleve.delete()
                                        if navigationModel.selectedEleveMngObjId == eleve.objectID {
                                            navigationModel.selectedEleveMngObjId = nil
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
                    HStack {
                        Text(classe.displayString)
                        Spacer()
                        Text("\(classe.nbOfEleves) élèves")
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                }
                .padding(.leading, 4)
            } else {
                EmptyListMessage(
                    symbolName: EleveEntity.defaultImageName,
                    title: "Aucun élève actuellement.",
                    message: "Les élèves ajoutés apparaîtront ici."
                )
            }
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
