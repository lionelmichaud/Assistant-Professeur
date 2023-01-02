//
//  GroupListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import SwiftUI

struct GroupListView : View {
    /// Liste des élèves d'un groupe donné
    var groupSection : SectionedFetchResults<Int16, EleveEntity>.Element
    var classe       : ClasseEntity
    //let isEditing    : Bool

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    @State
    private var isMovingEleve = false

    private var groupIsEditable: Bool {
        groupSection.id != 0
    }

    private var groupeIsEmpty: Bool {
        classe.groupe(number: Int(groupSection.id)).isEmpty
    }

    private var allElevesAssigned: Bool {
        classe.groupOfUngroupedEleves.isEmpty
    }

    private var showAddEleveMenu: Bool {
        (groupIsEditable && !allElevesAssigned)
    }

    private var unSortedEleve: [EleveEntity] {
        classe.groupOfUngroupedEleves.elevesSortedByName
    }

    // MARK: - Compute Properties

    var body: some View {
        Group {
            if showAddEleveMenu {
                /// ajouter au groupe un élève parmis ceux qui ne sont  affectés à aucun groupe
                Menu {
                    ForEach(unSortedEleve) { eleve in
                        Button {
                            GroupManager.assign(
                                eleve: eleve,
                                toGroupNumber: Int(groupSection.id)
                            )
                        } label: {
                            Label(eleve.displayName,
                                  systemImage: "graduationcap")
                        }
                    }
                } label: {
                    Label("Ajouter un élève",
                          systemImage: "plus.circle.fill")
                }
                //.buttonStyle(.borderless)
            }

            /// pour chaque Elève
            ForEach(groupSection, id: \.objectID) { eleve in
                EleveLabel(eleve: eleve)
                    .onTapGesture {
                        /// Programatic Navigation
                        navigationModel.selectedTab     = .eleve
                        navigationModel.selectedEleveId = eleve.objectID
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if groupIsEditable {
                            /// retirer l'élève du groupe
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

                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        /// changer l'élève de groupe
                        if true {
                            Button {
                                isMovingEleve = true
                            } label: {
                                Text("Déplacer")
                            }
                        }
                    }
                    .sheet(isPresented: $isMovingEleve) {
                        NavigationStack {
                            MoveEleveDialog(eleve: eleve)
                        }
                        .presentationDetents([.large])
                    }
            }
        }
    }
}

// FIXME: Ne fonctionne pas
struct MoveEleveDialog: View {
    @ObservedObject
    var eleve: EleveEntity

    var nbGroupInClasse: Int {
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
        1 ..< (nbGroupInClasse+1)
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
                        print("\(eleve.displayName) déplacé de \(String(describing : eleve.group?.displayString)) vers \(groupeNb)")
                        GroupManager.assign(eleve: eleve,
                                            toGroupNumber: groupeNb)
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

//struct GroupListView_Previews: PreviewProvider {
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
//}
