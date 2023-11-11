//
//  TrombinoscopeView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/09/2022.
//

import SwiftUI

/// Vue de tous les élèves de la classe en trombinoscope
struct TrombinoscopeView: View {
    @ObservedObject
    var classe: ClasseEntity

    @EnvironmentObject
    private var userContext: UserContext

    private let smallColumns = [
        GridItem(
            .adaptive(minimum: 120, maximum: 200),
            alignment: .top
        )
    ]
    private let largeColumns = [
        GridItem(
            .adaptive(minimum: 180, maximum: 300),
            alignment: .top
        )
    ]

    let font: Font = .title3
    let fontWeight: Font.Weight = .semibold

    @State
    private var isShowingResetBonuConfirmDialog: Bool = false

    @State
    private var isShowingDeleteTrombinesConfirmDialog: Bool = false

    @State
    private var searchString: String = ""

    @State
    private var pictureSize = "Small picture"

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(
                columns: pictureSize == "Small picture" ? smallColumns : largeColumns,
                spacing: 4
            ) {
                ForEach(
                    classe.filteredElevesSortedByName(
                        searchString: searchString,
                        nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
                    )
                ) { eleve in
                    VStack(alignment: .center) {
                        TrombineInteractivView(eleve: eleve)

                        // Nom de l'élève
                        EleveTextName(
                            eleve: eleve,
                            fontWeight: fontWeight
                        )
                        .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(2)
        .toolbar {
            // Effacements
            ToolbarItemGroup(placement: .destructiveAction) {
                Menu {
                    Button(role: .destructive) {
                        isShowingResetBonuConfirmDialog.toggle()
                    } label: {
                        Label(
                            "Remise à zéro des Bonus / Malus",
                            systemImage: "eraser.fill"
                        ).tint(.red)
                    }

                    Button(role: .destructive) {
                        isShowingDeleteTrombinesConfirmDialog.toggle()
                    } label: {
                        Label(
                            "Supprimer les photos",
                            systemImage: "eraser.fill"
                        ).tint(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        // Confirmation de suppression des photos de tous les élèves
                        .confirmationDialog(
                            "Suppression des photos",
                            isPresented: $isShowingDeleteTrombinesConfirmDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Effacer", role: .destructive) {
                                withAnimation {
                                    deleteAllTrombines()
                                }
                            }
                        } message: {
                            Text("Cette action supprimera les photos de tous les élèves de la classe.")
                        }
                        // Confirmation de Reset des Bonus / Malus de tous les élèves
                        .confirmationDialog(
                            "Effacement des Bonus/Malus",
                            isPresented: $isShowingResetBonuConfirmDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Effacer", role: .destructive) {
                                withAnimation {
                                    resetAllBonusMalus()
                                }
                            }
                        } message: {
                            Text("Cette action remettra à zéro le bonus / malus de tous les élèves de la classe.")
                        }
                }
                .disabled(classe.nbOfEleves == 0)
            }

            // Choix du mode d'affichage
            ToolbarItemGroup(placement: .automatic) {
                Picker("Présentation", selection: $pictureSize.animation()) {
                    Image(systemName: "minus.magnifyingglass")
                        .tag("Small picture")
                    Image(systemName: "plus.magnifyingglass")
                        .tag("Large picture")
                }
                .pickerStyle(.segmented)
            }
        }
        #if os(iOS)
        .navigationTitle("Trombines \(classe.displayString) (\(classe.nbOfEleves))")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(
            text: $searchString,
//                    placement : .navigationBarDrawer(displayMode : .automatic),
            placement: .toolbar,
            prompt: "Nom,Prénom,groupe,commentaire"
        )
        .autocorrectionDisabled()
    }

    // MARK: - Methods

    private func resetAllBonusMalus() {
        classe.allEleves.forEach { eleve in
            eleve.bonus = 0
        }
        try? ClasseEntity.saveIfContextHasChanged()
    }

    private func deleteAllTrombines() {
        classe.allEleves.forEach { eleve in
            eleve.deleteTrombine()
        }
    }
}

struct TrombinoscopeView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                TrombinoscopeView(classe: ClasseEntity.all().first!)
                    .environmentObject(NavigationModel())
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                TrombinoscopeView(classe: ClasseEntity.all().first!)
                    .environmentObject(NavigationModel())
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPhone 13")
        }
    }
}
