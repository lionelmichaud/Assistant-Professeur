//
//  EleveSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import HelpersView
import SwiftUI
import TipKit

/// Listes imriquées de tous les Etablissements / Classes / Elèves
struct EleveSidebarView: View {
    @Binding
    var preferredColumn: NavigationSplitViewColumn

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var searchString: String = ""
    // @Environment(\.isSearching) var isSearching
    // @Environment(\.dismissSearch) var dismissSearch

    /// Create an instance of your tip content.
    var flagListItem = FlagEleveItemTip()

    @FetchRequest<SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        animation: .default
    )
    private var schools: FetchedResults<SchoolEntity>

    var body: some View {
        TipView(flagListItem, arrowEdge: .bottom)
            .tint(.orange)
            .tipBackground(HierarchicalShapeStyle.tipBackgroundColor)
        List(selection: $navig.selectedEleveMngObjId) {
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
        // Afficher la colonne détail sur iPhone
        .onChange(of: navig.selectedEleveMngObjId) {
            if navig.selectedEleveMngObjId != nil {
                preferredColumn = .detail
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                Text("Filtrer")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                Toggle(
                    isOn: $navig.filterObservation.animation(),
                    label: {
                        Image(systemName: ObservEntity.defaultImageName)
                    }
                )
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(
                    isOn: $navig.filterColle.animation(),
                    label: {
                        Image(systemName: ColleEntity.defaultImageName)
                    }
                )
                .toggleStyle(.button)
                .padding(.trailing, 4)

                Toggle(
                    isOn: $navig.filterFlag.animation(),
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

/// Liste imbriquée des élèves dans un Etablissement / Classes / Elèves
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

/// Liste  des élèves dans une Classe
struct EleveSidebarClasseSubview: View {
    @ObservedObject
    var classe: ClasseEntity

    let searchString: String

    @EnvironmentObject
    private var navig: NavigationModel

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
            + navig.filterFlag.description
            + navig.filterColle.description
            + navig.filterObservation.description
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
                                        if navig.selectedEleveMngObjId == eleve.objectID {
                                            navig.selectedEleveMngObjId = nil
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
                withObservation: navig.filterObservation,
                withColle: navig.filterColle,
                withFlag: navig.filterFlag,
                nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
            )

            // Si un filtre est activé, déplier les classes qui contienent des résultats positifs
            if searchString.isNotEmpty || navig.filterObservation ||
                navig.filterColle || navig.filterFlag {
                isClasseExpanded = filteredEleveInClasse.count > 0
            } else if let selectedEleveMngObjId = navig.selectedEleveMngObjId,
               let selectedEleve = EleveEntity.byObjectId(MngObjID: selectedEleveMngObjId),
               // Déplier la classe si elle contient l'élève en cours de sélection
               selectedEleve.classe == classe {
                isClasseExpanded = true
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
            EleveSidebarView(preferredColumn: .constant(.detail))
                .previewDevice("iPad mini (6th generation)")

            EleveSidebarView(preferredColumn: .constant(.detail))
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
