//
//  GroupListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import SwiftUI

/// Liste des élèves d'un groupe donné
struct GroupView: View {
    @ObservedObject
    var groupe: GroupEntity

    @ObservedObject
    var classe: ClasseEntity

    @Binding
    var isEditing: Bool

    let searchString: String

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    // MARK: - Computed Properties

    private var groupIsEditable: Bool {
        groupe.number != 0
    }

    // MARK: - Compute Properties

    var body: some View {
        Group {
            if groupIsEditable && isEditing {
                // ajouter au groupe un élève parmis ceux qui ne sont affectés à aucun groupe
                Menu {
                    ForEach(classe.elevesSortedByName) { eleve in
                        Button {
                            withAnimation {
                                GroupManager.assign(
                                    eleve: eleve,
                                    toGroupNumber: groupe.viewNumber
                                )
                            }
                        } label: {
                            Label(
                                eleve.displayName,
                                systemImage: "graduationcap"
                            )
                        }
                    }
                } label: {
                    Label(
                        "Ajouter un élève",
                        systemImage: "plus.circle.fill"
                    )
                }
            }

            // pour chaque Elève du groupe
            ForEach(groupe.filteredElevesSortedByName(searchString: searchString), id: \.objectID) { eleve in
                EleveLabel(eleve: eleve)
//                    .onDrag {
//                        NSItemProvider(object: eleve)
//                    }

                    // afficher la fiche de l'élève du groupe
                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .eleve
                        navigationModel.selectedEleveMngObjId = eleve.objectID
                    }

                    // retirer l'élève du groupe
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if groupIsEditable && isEditing {
                            Button(role: .destructive) {
                                withAnimation {
                                    GroupManager
                                        .unassignFromItsGroup(eleve: eleve)
                                }
                            } label: {
                                Text("Retirer")
                            }
                        }
                    }
            }
        }
    }
}

struct MoveEleveDialog: View {
    @ObservedObject
    var eleve: EleveEntity

    private var nbGroupInClasse: Int {
        eleve.classe!.nbOfGroups - 1
    }

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var groupeNb: Int = 0

    @State
    private var grpTable = [Int]()

    // MARK: - Computed Properties

    private var grpRange: Range<Int> {
        1 ..< (nbGroupInClasse + 1)
    }

    var body: some View {
        Form {
            Picker("Groupe", selection: $groupeNb) {
                ForEach(grpTable, id: \.self) { grp in
                    Label(String(grp), systemImage: "person.line.dotted.person.fill")
                }
            }
            .pickerStyle(.inline)
        }
        #if os(iOS)
        .navigationTitle("Déplacer vers")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }

            ToolbarItem {
                Button("Déplacer") {
                    withAnimation {
                        print("\(eleve.displayName) déplacé de \(String(describing: eleve.group?.displayString)) vers \(groupeNb)")
                        GroupManager.assign(
                            eleve: eleve,
                            toGroupNumber: groupeNb
                        )
                    }
                    dismiss()
                }
            }
        }
        .task {
            grpRange.forEach {
                grpTable.append($0)
            }
        }
    }
}

// struct GroupListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                GroupListView(group      : TestEnvir.group,
//                              classe     : TestEnvir.classeStore.items.first!,
//                              isEditing : true)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                GroupListView(group     : TestEnvir.group,
//                              classe    : TestEnvir.classeStore.items.first!,
//                              isEditing : true)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
