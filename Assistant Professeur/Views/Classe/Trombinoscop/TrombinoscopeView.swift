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
    private var searchString: String = ""

    @State
    private var pictureSize = "Small picture"

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(
                columns: pictureSize == "Small picture" ? smallColumns : largeColumns,
                spacing: 4
            ) {
                ForEach(classe.filteredElevesSortedByName(searchString: searchString)) { eleve in
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
            ToolbarItemGroup(placement: .destructiveAction) {
                Button(role: .destructive) {
                    isShowingResetBonuConfirmDialog.toggle()
                } label: {
                    Image(systemName: "eraser.fill")
                        .tint(.red)
                }
                // Confirmation de Reset des Bonus / Malus de tous les élèves
                .confirmationDialog(
                    "Effacement des Bonus / Malus",
                    isPresented: $isShowingResetBonuConfirmDialog,
                    titleVisibility: .visible
                ) {
                    Button("Effacer", role: .destructive) {
                        withAnimation {
                            resetBonusMalus()
                        }
                    }
                } message: {
                    Text("Cette action remettra à zéro le bonus / malus de tous les élèves de la classe.")
                }
            }
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

    private func resetBonusMalus() {
        classe.allEleves.forEach { eleve in
            eleve.bonus = 0
        }
        try? ClasseEntity.saveIfContextHasChanged()
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
