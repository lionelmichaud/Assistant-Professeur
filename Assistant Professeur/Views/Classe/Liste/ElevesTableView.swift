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

    // MARK: - Internal Type

    struct TransfertDetails {
        var eleves = [EleveEntity]()
        var oldClasse: ClasseEntity?
        var newClasse: ClasseEntity?
    }

    enum Sheet: String, Identifiable {
        case addingNewEleve
        case addingNewObserv
        case addingNewColle

        var id: String { rawValue }
    }

    // MARK: - Private

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @State
    private var presentedSheet: Sheet?

    @State
    private var selection: Set<EleveEntity.ID> = []

    @State
    private var sortOrder =
        [
            KeyPathComparator(\EleveEntity.sortName),
            KeyPathComparator(\EleveEntity.groupInt),
            KeyPathComparator(\EleveEntity.bonus),
            KeyPathComparator(\EleveEntity.additionalTimeInt),
            KeyPathComparator(\EleveEntity.nbOfObservs),
            KeyPathComparator(\EleveEntity.nbOfColles)
        ]

    @State
    private var searchString: String = ""

    @State
    private var isShowingChangeClasseConfirmDialog = false

    @State
    private var transfertDetails = TransfertDetails()

    /// Create an instance of your tip content.
    var addEleveTip = AddEleveTip()
    var actionsEleveTip = ActionsEleveTip()

    // MARK: - Computed Properties

    var body: some View {
        VStack {
            Table(
                classe.filteredSortedEleves(
                    searchString: searchString,
                    sortOrder: sortOrder
                ),
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
            .searchable(
                text: $searchString,
//                placement: .navigationBarDrawer(displayMode: .automatic),
                placement: .toolbar,
                prompt: "Nom,Prénom,groupe,commentaire"
            )
            .autocorrectionDisabled()
            #if os(macOS)
                .tableStyle(.bordered(alternatesRowBackgrounds: true))
            #endif
        }
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Élèves de " + classe.displayString + " (\(classe.nbOfEleves))")
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .sheet(item: $presentedSheet) { sheet in
                switch sheet {
                    case .addingNewEleve:
                        NavigationStack {
                            EleveCreatorModal(inClasse: classe)
                                .presentationDetents([.medium])
                        }
                    case .addingNewObserv:
                        if let eleve = selectedEleve {
                            NavigationStack {
                                ObservCreatorModal(eleve: eleve)
                                    .presentationDetents([.medium])
                            }
                        }
                    case .addingNewColle:
                        if let eleve = selectedEleve {
                            NavigationStack {
                                ColleCreatorModal(eleve: eleve)
                                    .presentationDetents([.medium])
                            }
                        }
                }
            }
    }
}

// MARK: Sub-Views

extension ElevesTableView {
    private var selectedEleve: EleveEntity? {
        if let first = selection.first {
            return EleveEntity.byObjectIdentifier(objectID: first)
        } else {
            return nil
        }
    }

    private var selectedEleves: [EleveEntity] {
        selection.compactMap { selection in
            EleveEntity.byObjectIdentifier(objectID: selection)
        }
    }

    private var selectedElevesSchool: SchoolEntity? {
        if let first = selection.first {
            return EleveEntity.byObjectIdentifier(objectID: first)?.classe?.school
        } else {
            return nil
        }
    }

    private var selectedElevesClasse: ClasseEntity? {
        if let first = selection.first {
            return EleveEntity.byObjectIdentifier(objectID: first)?.classe
        } else {
            return nil
        }
    }

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
        if let group = eleve.group {
            Text(group.number == 0 ? "" : "\(group.displayString)")
        } else {
            EmptyView()
        }
    }
}

// MARK: Toolbar Content

extension ElevesTableView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            // aller à la fiche élève
            Button {
                // Programatic Navigation
                DeepLinkManager.handleLink(
                    navigateTo: .eleve(
                        eleve: EleveEntity
                            .byObjectIdentifier(objectID: selection.first!)!),
                    using: navig
                )
            } label: {
                Label(
                    "Fiche élève",
                    systemImage: "info.circle"
                )
            }
            .disabled(selection.count != 1 ||
                EleveEntity.byObjectIdentifier(objectID: selection.first!) == nil)
            // Confirmation du changement de classe d'un élève
            .confirmationDialog(
                "Changement de classe",
                isPresented: $isShowingChangeClasseConfirmDialog,
                titleVisibility: .visible,
                presenting: transfertDetails
            ) { transfertDetails in
                Button("Transférer", role: .destructive) {
                    transfertDetails
                        .eleves
                        .forEach { eleve in
                            if let newClasse = transfertDetails.newClasse {
                                eleve.changerDeClasse(newClasse: newClasse)
                            }
                        }
                }
            } message: { transfertDetails in
                VStack {
                    Text("Transférer les élèves de la classe de \(transfertDetails.oldClasse!.displayString) vers la la classe de \(transfertDetails.newClasse!.displayString).")
                    Text("Cette action ne peut pas être annulée.")
                        .padding(.top)
                }
            }
        }

        ToolbarItem(placement: .primaryAction) {
            // pour rapprocher les icones
            ControlGroup {
                // supprimer des élèves
                Button(role: .destructive) {
                    withAnimation {
                        EleveEntity.byObjectIdentifier(objectIDs: selection)
                            .forEach { eleve in
                                // supprimer l'élève et tous ses descendants
                                if navig.selectedEleveMngObjId == eleve.objectID {
                                    navig.selectedEleveMngObjId = nil
                                }
                                try? eleve.delete()
                            }
                    }
                } label: {
                    Label(
                        "Supprimer",
                        systemImage: "trash"
                    )
                }
                .disabled(selection.isEmpty)

                // ajouter un élève
                Button {
                    addEleveTip.invalidate(reason: .actionPerformed)
                    presentedSheet = .addingNewEleve
                } label: {
                    Label(
                        "Ajouter",
                        systemImage: "plus.circle.fill"
                    )
                }
                .popoverTip(addEleveTip)
            }.controlGroupStyle(.navigation)
        }

        ToolbarItemGroup(placement: .secondaryAction) {
            // flager les élèves
            Button {
                withAnimation {
                    EleveEntity.byObjectIdentifier(objectIDs: selection)
                        .forEach { eleve in
                            eleve.isFlagged = true
                            try? EleveEntity.saveIfContextHasChanged()
                        }
                }
            } label: {
                Label(
                    "Marquer",
                    systemImage: "flag.fill"
                )
            }

            // supprimer le flage des élèves
            Button {
                withAnimation {
                    EleveEntity.byObjectIdentifier(objectIDs: selection)
                        .forEach { eleve in
                            eleve.isFlagged = false
                            try? EleveEntity.saveIfContextHasChanged()
                        }
                }
            } label: {
                Label(
                    "Supprimer marque",
                    systemImage: "flag.slash"
                )
            }

            // ajouter une observation
            Button {
                presentedSheet = .addingNewObserv
            } label: {
                Label(
                    "Nouvelle observation",
                    systemImage: ObservEntity.defaultImageName
                )
            }
            .disabled(selection.count != 1)

            // ajouter une colle
            Button {
                presentedSheet = .addingNewColle
            } label: {
                Label(
                    "Nouvelle colle",
                    systemImage: ColleEntity.defaultImageName
                )
            }
            .disabled(selection.count != 1)

            if selection.isNotEmpty && selectedElevesSchool != nil {
                Menu("Changer de classe") {
                    // Pour chaque classe de l'établissement
                    ForEach(selectedElevesSchool!.classesSortedByLevelNumber) { classe in
                        Button {
                            transfertDetails = .init(
                                eleves: selectedEleves,
                                oldClasse: selectedElevesClasse,
                                newClasse: classe
                            )
                            isShowingChangeClasseConfirmDialog.toggle()
                        } label: {
                            Label {
                                Text(classe.displayString)
                            } icon: {
                                Image(systemName: ClasseEntity.defaultImageName)
                                    .foregroundColor(classe.levelEnum.imageColor)
                            }
                        }
                    }
                }
            }
        }
    }
}

// struct ElevesTableView_Previews: PreviewProvider {
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
// }
