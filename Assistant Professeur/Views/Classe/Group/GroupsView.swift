//
//  GroupsView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 24/09/2022.
//

import SwiftUI
import AppFoundation

struct GroupsView: View {
    @ObservedObject
    var classe: ClasseEntity

    enum ViewMode: Int {
        case list
        case picture
    }

    @State
    private var isShowingDeleteGroupsDialog = false

    @State
    private var expanded = true

    @State
    private var searchString: String = ""

    @State
    private var presentation: ViewMode = .list

    private var unSortedEleve: [EleveEntity] {
        classe.groupOfUngroupedEleves.elevesSortedByName
    }

    private var toolbarMenu: some View {
        Menu {
            /// Générer les groupes
            Menu {
                Menu {
                    Button("2 élèves") {
                        withAnimation {
                            GroupManager.formOrderedGroups(
                                nbEleveParGroupe: 2,
                                dans: classe
                            )

                        }
                    }
                    Button("3 élèves") {
                        withAnimation {
                            GroupManager.formOrderedGroups(
                                nbEleveParGroupe: 3,
                                dans: classe
                            )
                        }
                    }
                    Button("4 élèves") {
                        withAnimation {
                            GroupManager.formOrderedGroups(
                                nbEleveParGroupe:4,
                                dans: classe
                            )
                        }
                    }
                    Button("5 élèves") {
                        withAnimation {
                            GroupManager.formOrderedGroups(
                                nbEleveParGroupe: 5,
                                dans: classe
                            )
                        }
                    }
                } label: {
                    Label("Par ordre alphabétique", systemImage: "textformat.size.larger")
                }

                Menu {
                    Button("2 élèves") {
                        withAnimation {
                            GroupManager.formRandomGroups(
                                nbEleveParGroupe: 2,
                                dans: classe
                            )
                        }
                    }
                    Button("3 élèves") {
                        withAnimation {
                            GroupManager.formRandomGroups(
                                nbEleveParGroupe: 3,
                                dans: classe
                            )
                        }
                    }
                    Button("4 élèves") {
                        withAnimation {
                            GroupManager.formRandomGroups(
                                nbEleveParGroupe: 4,
                                dans: classe
                            )
                        }
                    }
                    Button("5 élèves") {
                        withAnimation {
                            GroupManager.formRandomGroups(
                                nbEleveParGroupe: 5,
                                dans: classe
                            )
                        }
                    }
                } label: {
                    Label("Aléatoirement", systemImage: "die.face.5")
                }

            } label: {
                Label("Générer les groupes", systemImage: "person.line.dotted.person.fill")
            }

            /// Supprimer tous les groupes
            Button(role: .destructive) {
                isShowingDeleteGroupsDialog.toggle()
            } label: {
                Label("Suprimer les groupes", systemImage: "trash")
            }

        } label: {
            Image(systemName: "ellipsis.circle")
                .imageScale(.large)
                .padding(4)
        }
    }

    var body: some View {
        return Group {
            if classe.nbOfEleves == 0 {
                VStack(alignment: .center, spacing: 10) {
                    Text("Aucun élèves dans cette classe.")
                }

            } else {
                List {
                    /// pour chaque Groupe
                    ForEach(classe.allGroupsSortedByNumber) { groupe in
                        DisclosureGroup(isExpanded: $expanded) {
                            switch presentation {
                                case .list:
                                    GroupListView(groupe: groupe)
                                case .picture:
                                    EmptyView()
                                    //GroupPicturesView(group: group)
                            }
                        } label: {
                            if groupe.number == 0 {
                                Text("Sans groupe")
                                    .foregroundColor(.red)
                            } else {
                                Text(groupe.displayString)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .searchable(text      : $searchString,
                            placement : .navigationBarDrawer(displayMode : .automatic),
                            prompt    : "Nom ou Prénom de l'élève")
                .autocorrectionDisabled()
            }
        }
        #if os(iOS)
        .navigationTitle("Groupes " + classe.displayString + " (\(classe.nbOfEleves))")
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("Présentation", selection: $presentation) {
                    Image(systemName: "list.bullet").tag(ViewMode.list)
                    Image(systemName: "person.crop.square.fill").tag(ViewMode.picture)
                }
                .pickerStyle(.segmented)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbarMenu
                /// Confirmation de suppresssion de tous les groupes
                    .confirmationDialog(
                        "Supression de tous les groupes",
                        isPresented     : $isShowingDeleteGroupsDialog,
                        titleVisibility : .visible) {
                            Button("Supprimer", role: .destructive) {
                                withAnimation {
                                    GroupManager.disolveGroups(dans: classe)
                                }
                            }
                            Button("Annuler", role: .cancel) {
                                isShowingDeleteGroupsDialog = false
                            }
                        } message: {
                            Text("Cette opération est irréversible")
                        }.keyboardShortcut(.defaultAction)
            }
        }
    }
}

//struct GroupsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            GroupsView(classe: .constant(TestEnvir.classeStore.items.first!))
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            GroupsView(classe: .constant(TestEnvir.classeStore.items.first!))
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
