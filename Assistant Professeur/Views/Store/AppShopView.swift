//
//  StoreView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/12/2023.
//

import HelpersView
import StoreKit
import SwiftUI

struct AppShopView: View {
    @Environment(Store.self)
    private var store

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        shopContent
            // .background(.background.secondary)
            .navigationTitle("Achats")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    doneButton
                }
            }
    }

    var doneButton: some View {
        Button(
            action: dismiss.callAsFunction,
            label: { Label("Terminé", systemImage: "xmark.circle.fill") }
        )
    }

    var shopContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let baseProduct = store.baseProduct {
                    let isPurchasable = store.isPurchasable(baseProduct)
                    baseTitle
                    MyProductView(
                        product: baseProduct,
                        isPurchasable: isPurchasable
                    )
                    baseDescription
                }

                if store.optionProducts.isNotEmpty {
                    optionsTitle
                    ForEach(store.optionProducts) { product in
                        let isPurchasable = store.isPurchasable(product)
                        if !isPurchasable && !store.isPurchasedFullProduct {
                            unavailableOptionText
                        }
                        MyProductView(
                            product: product,
                            isPurchasable: isPurchasable
                        )
                    }
                }

                if let fullProduct = store.fullProduct {
                    fullTitle
                    fullDescription
                    let isPurchasable = store.isPurchasable(fullProduct)
                    if !isPurchasable {
                        unavailableOptionText
                    }
                    MyProductView(
                        product: fullProduct,
                        isPurchasable: isPurchasable
                    )
                }
            }
            .scrollClipDisabled()
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    var baseTitle: some View {
        Text("Version débloquée")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }

    var optionsTitle: some View {
        Text("Options disponibles")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }

    var fullTitle: some View {
        Text("Version complète")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }

    var baseDescription: some View {
        Text("Options ci-dessous disponibles après achat.")
            .multilineTextAlignment(.leading)
            .font(.callout)
            .foregroundStyle(.secondary)
    }

    var fullDescription: some View {
        Text("Cette version donnera accès aux futurs fonctionnalités du produit.")
            .multilineTextAlignment(.leading)
            .font(.callout)
    }

    var unavailableOptionText: some View {
        Text("Disponible après achat des options précédentes")
            .multilineTextAlignment(.leading)
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}

struct MyProductView: View {
    let product: Product
    let isPurchasable: Bool

    @Environment(Store.self)
    private var store

    var body: some View {
        ProductView(product) {
            store.icone(for: product)
        }
        .productStyle(
            isPurchasable: isPurchasable
        )
    }
}

#Preview {
    NavigationStack {
        ZStack {
            AppShopView()
                .environment(Store())
        }
    }
}
