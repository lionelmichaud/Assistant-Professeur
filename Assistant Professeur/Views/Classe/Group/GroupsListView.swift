//
//  GroupsView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 24/09/2022.
//

import AppFoundation
import SwiftUI

/// Liste des groupes d'une classe présentant la liste des élèves de chaque groupe
struct GroupsListView: View {
    @ObservedObject
    var classe: ClasseEntity

    enum ViewMode: Int {
        case list
        case picture
    }

    @State
    private var isShowingDeleteGroupsDialog = false

    @State
    private var isExportingGroups = false

    @State
    private var expanded = true

    @State
    private var searchString: String = ""

    @State
    private var presentation: ViewMode = .list

    private var unGroupedEleve: [EleveEntity] {
        classe.groupOfUngroupedEleves.elevesSortedByName
    }

    private var csvURLsToShare: [URL] {
        ImportExportManager.cachesURLsToShare(
            fileNames: [
                CsvImportExportMng.csvFileName(classe: classe)
            ]
        )
    }

    var body: some View {
        Group {
            if classe.nbOfEleves == 0 {
                VStack(alignment: .center, spacing: 10) {
                    Text("Aucun élèves dans cette classe.")
                }

            } else {
                List {
                    // Ajout d'un nouveau groupe
                    Button {
                        GroupManager.addGroup(dans: classe)
                    } label: {
                        Label("Ajouter un groupe", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderless)

                    // Pour chaque Groupe
                    ForEach(classe.allGroupsSortedByNumber) { groupe in
                        if show(groupe: groupe) {
                            DisclosureGroup(isExpanded: $expanded) {
                                switch presentation {
                                    case .list:
                                        GroupView(
                                            groupe: groupe,
                                            classe: classe,
                                            searchString: searchString
                                        )
                                    case .picture:
                                        GroupPicturesView(
                                            groupe: groupe,
                                            searchString: searchString
                                        )
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
                        } else {
                            EmptyView()
                        }
                    }
                }
                .searchable(
                    text: $searchString,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    // placement: .toolbar,
                    prompt: "Nom ou Prénom de l'élève"
                )
                .autocorrectionDisabled()
            }
        }
        #if os(iOS)
        .navigationTitle("Groupes " + classe.displayString + " (\(classe.nbOfEleves))")
        #endif
        // Exporter des fichiers JSON pour le modèle
        .fileMover(
            isPresented: $isExportingGroups,
            files: isExportingGroups ?
                csvURLsToShare :
                []
        ) { _ in
        }
        .toolbar {
            myToolBarContent()
        }
    }

    private func show(groupe _: GroupEntity) -> Bool {
        true
        // FIXME: - ne fonctionne pas
        // groupe.number != 0 || (groupe.number == 0 && !groupe.isEmpty)
    }
}

// MARK: Toolbar Content

extension GroupsListView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Picker("Présentation", selection: $presentation) {
                Image(systemName: "list.bullet").tag(ViewMode.list)
                Image(systemName: "person.crop.square.fill").tag(ViewMode.picture)
            }
            .pickerStyle(.segmented)
        }

        ToolbarItemGroup(placement: .destructiveAction) {
            Menu {
                // Exporter les groupes au format CSV
                if classe.nbOfGroups > 1 {
                    Button {
                        CsvImportExportMng.exportGroups(de: classe)
                        isExportingGroups.toggle()
                    } label: {
                        Label("Exporter au format CSV", systemImage: "square.and.arrow.up")
                    }
                }

                // Générer les groupes
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
                                    nbEleveParGroupe: 4,
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

                // Supprimer tous les groupes
                if classe.nbOfGroups > 1 {
                    Button(role: .destructive) {
                        isShowingDeleteGroupsDialog.toggle()
                    } label: {
                        Label("Suprimer les groupes", systemImage: "trash")
                    }
                }

            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .padding(4)
            }
            // Confirmation de suppresssion de tous les groupes
            .confirmationDialog(
                "Supression de tous les groupes",
                isPresented: $isShowingDeleteGroupsDialog,
                titleVisibility: .visible
            ) {
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

// struct GroupsView_Previews: PreviewProvider {
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
// }
