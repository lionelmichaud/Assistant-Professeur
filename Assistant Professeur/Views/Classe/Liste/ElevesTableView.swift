//
//  ElevesTableView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/10/2022.
//

import SwiftUI

struct ElevesTableView: View {
    @ObservedObject
    var classe: ClasseEntity

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var isAddingNewEleve = false

    @State
    private var selection: Set<EleveEntity.ID> = []

    @State
    private var sortOrder =
    [KeyPathComparator(\EleveEntity.sortName),
     KeyPathComparator(\EleveEntity.groupInt),
     KeyPathComparator(\EleveEntity.bonus),
     KeyPathComparator(\EleveEntity.additionalTimeInt),
     KeyPathComparator(\EleveEntity.nbOfObservs),
     KeyPathComparator(\EleveEntity.nbOfColles)
    ]

    @State
    private var isAddingNewObserv = false

    @State
    private var isAddingNewColle  = false

    @State
    private var searchString: String = ""

    // MARK: - Computed Properties

    @ViewBuilder
    private func nameView(_ eleve: EleveEntity) -> some View {
        EleveLabel(eleve: eleve)
    }

    @ViewBuilder
    private func bonusView(_ eleve: EleveEntity) -> some View {
        if eleve.viewBonus.isNotZero {
            Text("\(eleve.viewBonus.isPositive ? "+" : "")\(eleve.viewBonus.formatted(.number.precision(.fractionLength(0))))")
                .foregroundColor(eleve.viewBonus.isPositive ? .green : .red)
                .fontWeight(.semibold)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func tpsSupView(_ eleve: EleveEntity) -> some View {
        if eleve.hasAddTime {
            Text("1/3 tps en +")
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func groupeView(_ eleve: EleveEntity) -> some View {
        //        if let group = eleve.group {
        //            Text("\(group)")
        //        } else {
        EmptyView()
        //        }
    }

    var body: some View {
        VStack {
            Table(
                classe.filteredSortedEleves(searchString: searchString, sortOrder: sortOrder),
                selection: $selection,
                sortOrder: $sortOrder
            ) {
                // nom
                TableColumn("Nom", value: \EleveEntity.sortName) { eleve in
                    nameView(eleve)
                }

                // groupe
                TableColumn("Groupe", value: \EleveEntity.groupInt) { eleve in
                    groupeView(eleve)
                }
                .width(80)

                // temps additionel
                TableColumn("PAP", value: \EleveEntity.additionalTimeInt) { eleve in
                    tpsSupView(eleve)
                }
                .width(100)

                // bonus / malus
                TableColumn("Bonus", value: \EleveEntity.bonus) { eleve in
                    bonusView(eleve)
                }
                .width(70)

                // colles
                TableColumn("Colles", value: \EleveEntity.nbOfColles) { eleve in
                    EleveColleLabel(eleve: eleve, scale: .medium)
                }
                .width(70)

                // observations
                TableColumn("Obs.", value: \EleveEntity.nbOfObservs) { eleve in
                    EleveObservLabel(eleve: eleve, scale: .medium)
                }
                .width(70)
            }
            .searchable(text      : $searchString,
                        placement : .navigationBarDrawer(displayMode : .automatic),
                        prompt    : "Nom, Prénom ou n° de groupe")
            .onChange(of: sortOrder) { newValue in
                print("Sort order changed")
            }
            .autocorrectionDisabled()
            #if os(macOS)
            .tableStyle(.bordered(alternatesRowBackgrounds: true))
            #endif
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                /// aller à la fiche élève
                Button {
                    // Programatic Navigation
                    navigationModel.selectedTab     = .eleve
                    navigationModel.selectedEleveId =
                    EleveEntity
                        .byObjectIdentifier(objectID: selection.first!)!
                        .objectID
                } label: {
                    Label("Fiche élève", systemImage: "info.circle")
                }
                .disabled(selection.count != 1 || EleveEntity
                    .byObjectIdentifier(objectID: selection.first!) == nil)
            }

            ToolbarItem(placement: .primaryAction) {
                // pour rapprocher les icones
                ControlGroup {
                    /// supprimer des élèves
                    Button(role: .destructive) {
                        withAnimation {
                            EleveEntity.byObjectIdentifier(objectIDs: selection)
                                .forEach { eleve in
                                    // supprimer l'élève et tous ses descendants
                                    try? eleve.delete()
                                    if navigationModel.selectedEleveId == eleve.objectID {
                                        navigationModel.selectedEleveId = nil
                                    }
                                }
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                    .disabled(selection.isEmpty)

                    /// ajouter un élève
                    Button {
                        isAddingNewEleve = true
                    } label: {
                        Label("Ajouter", systemImage: "plus.circle.fill")
                    }
                }.controlGroupStyle(.navigation)
            }

            ToolbarItemGroup(placement: .secondaryAction) {
                /// flager les élèves
                if selection.count > 1 || (
                    selection.count == 1 && (
                        !(EleveEntity.byObjectIdentifier(objectID: selection.first!)?.isFlagged ?? false)
                    )
                ) {
                    Button {
                        withAnimation {
                            EleveEntity.byObjectIdentifier(objectIDs: selection)
                                .forEach { eleve in
                                    eleve.isFlagged = true
                                    try? EleveEntity.saveIfContextHasChanged()
                                }
                        }
                    } label: {
                        Label("Marquer", systemImage: "flag.fill")
                    }
                }

                /// supprimer le flage des élèves
                if selection.count > 1 || (
                    selection.count == 1 && (
                        (EleveEntity.byObjectIdentifier(objectID: selection.first!)?.isFlagged ?? false)
                    )
                ) {
                    Button {
                        withAnimation {
                            EleveEntity.byObjectIdentifier(objectIDs: selection)
                                .forEach { eleve in
                                    eleve.isFlagged = false
                                    try? EleveEntity.saveIfContextHasChanged()
                                }
                        }
                    } label: {
                        Label("Supprimer marque", systemImage: "flag.slash")
                    }
                }

                /// ajouter une observation
                Button {
                    isAddingNewObserv = true
                } label: {
                    Label("Nouvelle observation", systemImage: "rectangle.and.text.magnifyingglass")
                }
                .disabled(selection.count != 1)

                /// ajouter une colle
                Button {
                    isAddingNewColle = true
                } label: {
                    Label("Nouvelle colle", systemImage: "lock.fill")
                }
                .disabled(selection.count != 1)
            }
        }
        #if os(iOS)
        .navigationTitle("Élèves de " + classe.displayString + " (\(classe.nbOfEleves))")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isAddingNewEleve) {
            NavigationStack {
                EleveCreatorModal(inClasse: classe)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddingNewObserv) {
            NavigationStack {
                EmptyView()
                //                if let eleve = eleveStore.itemBinding(withID: selection.first!) {
                //                    ObservCreator(eleve: eleve)
                //                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddingNewColle) {
            NavigationStack {
                EmptyView()
                //                if let eleve = eleveStore.itemBinding(withID: selection.first!) {
                //                    ColleCreator(eleve: eleve)
                //                }
            }
            .presentationDetents([.medium])
        }
    }
}

//struct ElevesTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ElevesTableView(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ElevesTableView(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
