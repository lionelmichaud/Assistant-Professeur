//
//  ObservBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 26/04/2022.
//

import HelpersView
import SwiftUI

/// Listes imriquées de toutes les Observations de tous les Etablissements / Classes
struct ObservSidebarView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var filterTodoObservation = true

    @FetchRequest<SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        animation: .default
    )
    private var schools: FetchedResults<SchoolEntity>

    var body: some View {
        List(selection: $navig.selectedObservMngObjId) {
            if ObservEntity.all().isEmpty {
                ContentUnavailableView(
                    "Aucune observation actuellement...",
                    systemImage: ObservEntity.defaultImageName,
                    description: Text("Les observations ajoutées apparaîtront ici.")
                )
            } else {
                // pour chaque Etablissement
                ForEach(schools) { school in
                    Section {
                        // pour chaque Classe
                        ObservSidebarSchoolSubview(
                            school: school,
                            filterObservation: filterTodoObservation
                        )
                    } header: {
                        Text(school.displayString)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                    }
                }
                .emptyListPlaceHolder(schools) {
                    ContentUnavailableView(
                        "Aucun établissement actuellement...",
                        systemImage: SchoolEntity.defaultImageName
                    )
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                Toggle(
                    isOn: $filterTodoObservation.animation(),
                    label: {
                        Text("A faire")
                    }
                )
                .toggleStyle(.button)
            }
        }
        .navigationTitle("Les Observations")
    }
}

/// Listes imriquées de toutes les Observations de toutes les Classes d'un établissement
struct ObservSidebarSchoolSubview: View {
    @ObservedObject
    var school: SchoolEntity

    var filterObservation: Bool

    var body: some View {
        // pour chaque Classe
        ForEach(school.classesSortedByLevelNumber) { classe in
            if someFilteredObservations(dans: classe) {
                ObservSidebarClasseSubview(
                    classe: classe,
                    filterObservation: filterObservation
                )
            } else {
                EmptyView()
            }
        }
        .emptyListPlaceHolder(school.classesSortedByLevelNumber) {
            ContentUnavailableView(
                "Aucune classe dans cet établissement actuellement...",
                systemImage: ClasseEntity.defaultImageName,
                description: Text("Les classes ajoutées apparaîtront ici.")
            )
        }
    }

    // MARK: - Methods

    private func someFilteredObservations(dans classe: ClasseEntity) -> Bool {
        classe.nbOfObservations(
            isConsignee: filterObservation ? false : nil,
            isVerified: filterObservation ? false : nil
        ) > 0
    }
}

/// Listes imriquées de toutes les Observations d'une Classe d'un établissement
struct ObservSidebarClasseSubview: View {
    @ObservedObject
    var classe: ClasseEntity

    var filterObservation: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @State
    private var isClasseExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isClasseExpanded) {
            // pour chaque Observation
            ForEach(filteredSortedObservs(dans: classe), id: \.objectID) { observ in
                ObservBrowserRow(observ: observ)
                    .customizedListItemStyle(
                        isSelected: observ.objectID == navig.selectedObservMngObjId
                    )
                    .swipeActions {
                        // supprimer l'observation
                        Button(role: .destructive) {
                            withAnimation {
                                if navig.selectedObservMngObjId == observ.objectID {
                                    navig.selectedObservMngObjId = nil
                                }
                                try? observ.delete()
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        } label: {
            Text(classe.displayString)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
        .padding(.leading, 4)
        // Gérer le dépliement des classes
        .onAppear {
            if let selectedObservMngObjId = navig.selectedObservMngObjId,
               let selectedObserv = ObservEntity.byObjectId(MngObjID: selectedObservMngObjId),
               let slelectedClasse = selectedObserv.eleve?.classe,
               slelectedClasse == classe {
                // Déplier la classe si elle contient l'élève en cours de sélection
                isClasseExpanded = true
            }
        }
    }

    // MARK: - Methods

    private func filteredSortedObservs(dans classe: ClasseEntity) -> [ObservEntity] {
        classe.filteredSortedObservations(
            isConsignee: filterObservation ? false : nil,
            isVerified: filterObservation ? false : nil,
            nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
        )
    }
}

// struct ObservBrowserView_Previews: PreviewProvider {
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
// }
