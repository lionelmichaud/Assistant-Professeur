//
//  ElevesListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/10/2022.
//

import SwiftUI

struct ElevesListView: View {
    @ObservedObject
    var classe: ClasseEntity

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var isAddingNewEleve = false

    @State
    private var searchString: String = ""

    private var navbarTitle: String {
        "Liste " + classe.displayString + " (\(classe.nbOfEleves))"
    }

    var body: some View {
        List {
            // ajouter un élève
            Button {
                isAddingNewEleve = true
            } label: {
                Label("Ajouter un élève", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // liste des élèves
            ForEach(classe.filteredElevesSortedByName(searchString: searchString)) { eleve in
                ClasseEleveRow(eleve: eleve)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .eleve
                        navigationModel.selectedEleveMngObjId = eleve.objectID
                    }

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
        }
        .searchable(
            text: $searchString,
//            placement: .navigationBarDrawer(displayMode: .automatic),
            placement: .toolbar,
            prompt: "Nom, Prénom ou n° de groupe"
        )
        .autocorrectionDisabled()
        #if os(iOS)
            .navigationTitle(navbarTitle)
        #endif
            .sheet(isPresented: $isAddingNewEleve) {
                NavigationStack {
                    EleveCreatorModal(inClasse: classe)
                        .presentationDetents([.medium])
                }
            }
    }
}

// struct ElevesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ElevesListView(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//                .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ElevesListView(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//                .previewDevice("iPhone 13")
//        }
//    }
// }
