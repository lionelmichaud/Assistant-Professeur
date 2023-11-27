//
//  ColleBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import HelpersView
import SwiftUI

struct ColleSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var filterTodoColle = true

    @FetchRequest<SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        animation: .default
    )
    private var schools: FetchedResults<SchoolEntity>

    var body: some View {
        List(selection: $navigationModel.selectedColleMngObjId) {
            if ColleEntity.all().isEmpty {
                ContentUnavailableView(
                    "Aucune colle actuellement...",
                    systemImage: ColleEntity.defaultImageName,
                    description: Text("Les colles ajoutées apparaîtront ici.")
                )
            } else {
                // pour chaque Etablissement
                ForEach(schools) { school in
                    Section {
                        // pour chaque Classe
                        ColleSidebarSchoolSubview(
                            school: school,
                            filterColle: filterTodoColle
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
                    isOn: $filterTodoColle.animation(),
                    label: {
                        Text("A faire")
                    }
                )
                .toggleStyle(.button)
            }
        }
        .navigationTitle("Les Colles")
    }
}

struct ColleSidebarSchoolSubview: View {
    @ObservedObject
    var school: SchoolEntity

    var filterColle: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        // pour chaque Classe
        ForEach(school.classesSortedByLevelNumber) { classe in
            if someFilteredColles(dans: classe) {
                DisclosureGroup {
                    // pour chaque Colle
                    ForEach(filteredSortedColles(dans: classe), id: \.objectID) { colle in
                        ColleBrowserRow(colle: colle)
                            .customizedListItemStyle(
                                isSelected: colle.objectID == navig.selectedColleMngObjId
                            )
                            .swipeActions {
                                // supprimer la Colle
                                Button(role: .destructive) {
                                    withAnimation {
                                        if navig.selectedColleMngObjId == colle.objectID {
                                            navig.selectedColleMngObjId = nil
                                        }
                                        try? colle.delete()
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

    private func someFilteredColles(dans classe: ClasseEntity) -> Bool {
        classe.nbOfColles(isConsignee: filterColle ? false : nil) > 0
    }

    private func filteredSortedColles(dans classe: ClasseEntity) -> [ColleEntity] {
        classe.filteredSortedColles(
            isConsignee: filterColle ? false : nil,
            nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
        )
    }
}

// struct ColleBrowserView_Previews: PreviewProvider {
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
// }
