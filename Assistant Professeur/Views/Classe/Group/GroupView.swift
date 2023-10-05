//
//  GroupListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import CoreData
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

    @State
    private var permutationEleve: EleveEntity?

    // MARK: - Computed Properties

    private var groupIsEditable: Bool {
        groupe.number != 0
    }

    // MARK: - Compute Properties

    var body: some View {
        Group {
            if groupIsEditable && isEditing {
                // Ajouter au groupe un élève parmis ceux qui ne font pas partis du groupe
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
                                (eleve.isUngrouped ? "◦ " : "") + eleve.displayName,
                                systemImage: EleveEntity.defaultImageName
                            )
                        }
                        .disabled(eleve.group == groupe)
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
                ClasseEleveRow(eleve: eleve)
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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

                    // permuter l'élève avec un élève d'un autre groupe
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        if groupIsEditable && isEditing {
                            Button {
                                permutationEleve = eleve
                            } label: {
                                Text("Permuter avec...")
                            }
                        }
                    }
            }

            if groupIsEditable && isEditing {
                // dissoudre le groupe et supprimer le groupe
                Button(role: .destructive) {
                    withAnimation {
                        GroupManager.disolveAndRemove(group: groupe)
                    }
                } label: {
                    Label(
                        "Supprimer le groupe",
                        systemImage: "trash"
                    ).tint(.red)
                }
            }
        }

        .sheet(item: $permutationEleve) { eleve in
            NavigationStack {
                SelectElevePermuterDialog(eleve: eleve)
                    .presentationDetents([.medium])
            }
        }
    }
}

/// Dialogue de sélection de l'élève avec qui permuter et exécution de la pertutation
struct SelectElevePermuterDialog: View {
    let eleve: EleveEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var selectedEleve: EleveEntity? // EleveEntity.ID?

    var body: some View {
        List {
            Picker(selection: $selectedEleve) {
                ForEach(eleve.classe!.elevesSortedByName) { eleve2 in
                    Text("\(eleve2.displayName) (groupe \(eleve2.group?.number ?? 0))").tag(Optional(eleve2))
                        .disabled(eleve2.group == eleve.group)
                }
            } label: {
                Label("Cet élève", systemImage: EleveEntity.defaultImageName)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem {
                Button("Ok") {
                    if let selectedEleve {
                        withAnimation {
                            GroupManager.permuter(thisEleve: eleve,
                                                  withThisEleve: selectedEleve)
                        }
                    }
                    dismiss()
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Permuter \(eleve.displayName) avec...")
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
