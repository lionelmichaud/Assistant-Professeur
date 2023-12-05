//
//  TrombineView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/10/2022.
//

import SwiftUI

/// Vignette de la trombine d'un élèves avec des boutons interactifs et un menu
struct TrombineInteractivView: View {
    @ObservedObject
    var eleve: EleveEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isAddingNewObserv = false

    @State
    private var isAddingNewColle = false

    var body: some View {
        // si le dossier Document existe
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottom) {
                    TrombineView(eleve: eleve)

                    // Légende basse: Points +/-
                    TrombinoscopeFooterView(eleve: eleve)
                }
                // Coin supérieur droit: Menu
                menu
                    .sheet(isPresented: $isAddingNewObserv) {
                        NavigationStack {
                            ObservCreatorModal(eleve: eleve)
                                .presentationDetents([.medium])
                        }
                    }
                    .sheet(isPresented: $isAddingNewColle) {
                        NavigationStack {
                            ColleCreatorModal(eleve: eleve)
                                .presentationDetents([.medium])
                        }
                    }
            }

            // Coin supérieur gauche: Flag
            Button {
                eleve.isFlagged.toggle()
                try? EleveEntity.saveIfContextHasChanged()
            } label: {
                Image(systemName: eleve.isFlagged ? "flag.fill" : "flag")
                        .foregroundColor(.orange)
            }
            .buttonStyle(.bordered)
        }
    }

    private var menu: some View {
        Menu {
            // aller à la fiche élève
            Button {
                // Programatic Navigation
                DeepLinkManager.handle(
                    navigateTo: .eleve(eleve: eleve),
                    using: navig
                )
            } label: {
                Label(
                    "Fiche élève",
                    systemImage: "info.circle"
                )
            }

            // ajouter une observation
            Button {
                isAddingNewObserv = true
            } label: {
                Label(
                    "Nouvelle observation",
                    systemImage: ObservEntity.defaultImageName
                )
            }

            // ajouter une colle
            Button {
                isAddingNewColle = true
            } label: {
                Label(
                    "Nouvelle colle",
                    systemImage: ColleEntity.defaultImageName
                )
            }

            // supprimer la photo
            if eleve.hasImageTrombine {
                Button(role: .destructive) {
                    eleve.trombine = nil
                    try? EleveEntity.saveIfContextHasChanged()
                } label: {
                    Label(
                        "Supprimer la photo",
                        systemImage: "trash"
                    )
                }
            }

        } label: {
            Image(systemName: "ellipsis.circle")
                .imageScale(.large)
                .padding(4)
        }
    }
}

struct TrombinoscopeFooterView: View {
    @ObservedObject
    var eleve: EleveEntity

    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        HStack(spacing: 0) {
            Button(iconName: "hand.thumbsdown.fill") {
                eleve.viewBonus -= userContext.prefs.viewElevePref.maxBonusIncrement
            }
            .buttonStyle(.bordered)

            Spacer()
            if eleve.viewBonus != 0 {
                Text("\(eleve.bonus.formatted(.number.precision(.fractionLength(0))))")
                    .fontWeight(.bold)
                    .foregroundColor(eleve.viewBonus > 0 ? .green : .red)
                Spacer()
            }

            Button(iconName: "hand.thumbsup.fill") {
                eleve.viewBonus += userContext.prefs.viewElevePref.maxBonusIncrement
            }
            .buttonStyle(.bordered)
        }
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 15))
    }
}

// struct TrombinoscopeFooterView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrombinoscopeFooterView(eleve: .constant(Eleve.exemple))
//            .previewLayout(.sizeThatFits)
//            .previewDisplayName("Footer")
//        //.previewDevice("iPhone 13")
//    }
// }
