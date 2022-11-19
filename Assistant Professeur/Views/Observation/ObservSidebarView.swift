//
//  ObservBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 26/04/2022.
//

import SwiftUI

struct ObservSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var schoolStore     : SchoolStore
    @EnvironmentObject private var observStore     : ObservationStore

    @State
    private var filterObservation = true

    var body: some View {
        List(selection: $navigationModel.selectedObservId) {
            if observStore.items.isEmpty {
                Text("Aucune observation actuellement")
            } else {
                /// pour chaque Etablissement
                ForEach(schoolStore.sortedSchools()) { school in
                    if school.nbOfClasses != 0 {
                        Section {
                            /// pour chaque Classe
                            ObservBrowserSchoolSubiew(school            : school,
                                                      filterObservation : filterObservation)
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
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                Toggle(isOn: $filterObservation.animation(),
                       label: {
                    Text("A faire")
                })
                .toggleStyle(.button)
            }
        }
        .navigationTitle("Les Observations")
    }
}

struct ObservBrowserSchoolSubiew : View {
    let school            : School
    var filterObservation : Bool

    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var classeStore     : ClasseStore
    @EnvironmentObject private var eleveStore      : EleveStore
    @EnvironmentObject private var observStore     : ObservationStore

    var body: some View {
        /// pour chaque Classe
        ForEach(classeStore.sortedClasses(dans: school)) { classe in
            if someObservations(dans: classe) {
                DisclosureGroup {
                    /// pour chaque Observation
                    ForEach(filteredSortedObservs(dans: classe)) { observ in
                        if let eleveId = observ.eleveId,
                           let eleve = eleveStore.item(withID: eleveId) {
                            ObservBrowserRow(eleve  : eleve,
                                             observ : observ)
                            .swipeActions {
                                // supprimer l'observation
                                Button(role: .destructive) {
                                    withAnimation {
                                        if let eleveId = observ.eleveId {
                                            if observ.id == navigationModel.selectedObservId {
                                                navigationModel.selectedObservId = nil
                                            }
                                            EleveManager().retirer(observId   : observ.id,
                                                                   deEleveId  : eleveId,
                                                                   eleveStore : eleveStore,
                                                                   observStore: observStore)
                                        }
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
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

    private func someObservations(dans classe : Classe) -> Bool {
        eleveStore.someObservations(dans        : classe,
                                    observStore : observStore,
                                    isConsignee : filterObservation ? false : nil,
                                    isVerified  : filterObservation ? false : nil)
    }

    private func filteredSortedObservs(dans classe: Classe) -> [Observation] {
        eleveStore.filteredSortedObservations(dans        : classe,
                                              observStore : observStore,
                                              isConsignee : filterObservation ? false : nil,
                                              isVerified  : filterObservation ? false : nil)
    }
}

struct ObservBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvir.createFakes()
        return Group {
            ObservSidebarView()
                .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
        }
    }
}
