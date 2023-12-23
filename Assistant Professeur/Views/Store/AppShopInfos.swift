//
//  AppShopInfos.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2023.
//

import HelpersView
import SwiftUI

struct AppShopInfos: View {
    @Environment(Store.self)
    private var store

    let titleColor: Color = .blue3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Version de base
                baseTitle
                Text("""
                Permet la céation d'un nombre illimité d'établissements scolaires et de classes d'élèves.
                Le nombre d'élèves n'est pas limité.
                Il est possible d'enseigner plusieurs disciplines différentes dans le même établissement mais pas pour une même classe.
                """)

                // Options
                optionsTitle
                ForEach(store.optionProducts) { product in
                    VStack(alignment: .leading) {
                        Text(product.displayName)
                            .foregroundStyle(.blue2)
                            .font(.headline.weight(.medium))
                        if product.displayName == "Progressions pédagogiques" {
                            Text("• Permet des créer, pour chaque discipline et pour chaque niveau de classe, une **progression pédagogique** annuelle.")
                                .padding(.bottom, 2)
                            Text("• Chaque progression peut être constituée de **séquences pédagogiques**, elle-mêmes constituées d'**activité pédagogiques**.")
                                .padding(.bottom, 2)
                            Text("• A chaque activité pédagogique peuvent être associés des **documents** ressources à imprimer, à partager ou réservés à l'enseignant.")
                                .padding(.bottom, 2)
                            Text("• Un lien URL internet à l'enseignant d'accéder aisément à ses ressources stockées sur le **Cloud** ou localement.")
                                .padding(.bottom, 2)
                            Text("• Il est possible de visualiser le **planning annuel** de sa progression pédagogique, tel que prévu, et simultanément, pour information, la progression réelle de chacune de ses classes.")
                                .padding(.bottom, 2)
                            Text("• Dans la vue de chaque classe; il est possible de visualiser le contenu pédagogique de chacun des cours à venir et de mettre à jour la progression réelle en fin de cours.")
                            Text("Ceci permet de savoir à tout moment ce qui est fait et reste à faire en termes de progresion pédagogique pour chaque classe.")
                                .padding(.bottom, 2)
                            Text("• Il est possible de visualiser les actions à réaliser en prévision des cours à venir, telles que: les documents à imprimer (et en quelle quantité) ou à partager avec les élèves.")

                        } else if product.displayName == "Compétences" {
                            Text("• Permet de gérer deux types de compétences: communes à toutes les disciplines (socle commun) ou spécifiques à une discipline.")
                                .padding(.bottom, 2)
                            Text("• Permet des créer, pour chaque cycle, des compétences communes multi-disciplianires.")
                                .padding(.bottom, 2)
                            Text("• Permet des créer, pour chaque discipline et pour chaque niveau de classe, des compétence et connaissances disciplinaires qui peuvent être reliées aux compétences commune et aux activités pédagogiques.")
                                .padding(.bottom, 2)
                            Text("• Permet de visualiser, dans la vue 'Progressions' la couverture de chaque Séquence ou Activité en termes de compétences communes et disciplinaires.")
                                .padding(.bottom, 2)
                            Text("• Permet de générer automatiquement, pour chaque séquences, un document PDF de présentation de la séquence.")
                        }
                    }
                    .padding(.leading)
                }
                
                // Version complète
                fullTitle
                Text("""
                Donne accès à toutes les fonctionnalités du produit, sans limite *.
                """)
                fullDescription

                // Limitations
                limitations
                Text("""
                Lorsqu'elle est exécutée sur MacOS, cette application ne peut pas se synchroniser avec les applications Calendriers et Contacts de l'utilisateur.
                Ceci est dû à une limitation imposée par Apple aux applications iOS exécutées sur MacOS.
                Cette limitation n'existe pas sur iOS ou iPadOS.
                """)
                .foregroundStyle(.secondary)
            }
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        #if os(iOS)
            .navigationTitle("Fonctionnalités")
        #endif
            .navigationBarTitleDisplayModeInline()
    }

    var baseTitle: some View {
        Text("Version débloquée")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .foregroundStyle(titleColor)
    }

    var optionsTitle: some View {
        Text("Options disponibles")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .foregroundStyle(titleColor)
    }

    var fullTitle: some View {
        Text("Version complète")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .foregroundStyle(titleColor)
    }

    var fullDescription: some View {
        Text("Cette version donnera accès aux futurs fonctionnalités du produit.")
            .multilineTextAlignment(.leading)
            .font(.callout)
    }

    var limitations: some View {
        Text("*Limitations")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .foregroundStyle(.blue2)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            AppShopInfos()
                .environment(Store())
        }
    }
}
