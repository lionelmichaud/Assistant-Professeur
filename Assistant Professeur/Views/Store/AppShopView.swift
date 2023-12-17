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
                    baseText
                    ProductView(baseProduct) {
                        store.icone(for: baseProduct)
                    }
                    .productStyle(
                        isPurchasable: true
                    )
                }

                if store.optionProducts.isNotEmpty {
                    optionsText
                    ForEach(store.optionProducts) { product in
                        let isPurchasable = store.isPurchasable(product)
                        if !isPurchasable {
                            unavailableOptionText
                        }
                        ProductView(product) {
                            store.icone(for: product)
                        }
                        .productStyle(
                            isPurchasable: isPurchasable
                        )
                    }
                }

                if let fullProduct = store.fullProduct {
                    fullText
                    let isPurchasable = store.isPurchasable(fullProduct)
                    if !isPurchasable {
                        unavailableOptionText
                    }
                    ProductView(fullProduct) {
                        store.icone(for: fullProduct)
                    }
                    .productStyle(
                        isPurchasable: isPurchasable
                    )
                }
            }
            // .productViewStyle(.compact)
            .scrollClipDisabled()
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    var baseText: some View {
        Text("Version débloquée")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
    }

    var optionsText: some View {
        Text("Options disponibles")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }

    var fullText: some View {
        Text("Version complète")
            .font(.title3.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }

    var unavailableOptionText: some View {
        Text("Disponible après achat des options précédentes")
            .multilineTextAlignment(.leading)
            .font(.callout)
            .foregroundStyle(.secondary)
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
