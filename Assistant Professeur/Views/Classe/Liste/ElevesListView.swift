//
//  ElevesListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/10/2022.
//

import HelpersView
import SwiftUI

struct ElevesListView: View {
    @ObservedObject
    var classe: ClasseEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @EnvironmentObject
    private var userContext: UserContext

    @State
    private var isAddingNewEleve = false

    @State
    private var searchString: String = ""

    private var navbarTitle: String {
        "Liste " + classe.displayString + " (\(classe.nbOfEleves))"
    }

    var body: some View {
        let foundEleves = classe.filteredElevesSortedByName(
            searchString: searchString,
            nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
        )
        List {
            // ajouter un élève
            Button {
                isAddingNewEleve = true
            } label: {
                Label("Ajouter un élève", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // liste des élèves
            ForEach(foundEleves) { eleve in
                ClasseEleveRow(eleve: eleve)

                    .onTapGesture {
                        // Programatic Navigation
                        DeepLinkManager.handle(
                            navigateTo: .eleve(eleve: eleve),
                            using: navig
                        )
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer un élève
                        Button(role: .destructive) {
                            withAnimation {
                                // supprimer l'élève et tous ses descendants
                                if navig.selectedEleveMngObjId == eleve.objectID {
                                    navig.selectedEleveMngObjId = nil
                                }
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
            .emptyListPlaceHolder(foundEleves) {
                if searchString.isNotEmpty {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "Aucun élève actuellement...",
                        systemImage: EleveEntity.defaultImageName,
                        description: Text("Les élèves ajoutés apparaîtront ici.")
                    )
                }
            }
        }
        .searchable(
            text: $searchString,
//            placement: .navigationBarDrawer(displayMode: .automatic),
            placement: .toolbar,
            prompt: "Nom,Prénom,groupe,commentaire"
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
