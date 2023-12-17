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
                    .productStyle()
                }

                if store.optionProducts.isNotEmpty {
                    optionsText
                    ForEach(store.optionProducts) { product in
                        ProductView(product) {
                            store.icone(for: product)
                        }
                        .productStyle()
                        .overlay {
                            if !store.isPurchasable(product) {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(.gray)
                                    .opacity(0.51)
                                Text("Disponible après achat des options précédentes")
                                    .multilineTextAlignment(.center)
                                    .font(.title3)
                                    .background(
                                        .ultraThinMaterial,
                                        in: .rect(cornerRadius: 5.0)
                                    )
                            }
                        }
                    }
                }

                if let fullProduct = store.fullProduct {
                    fullText
                    ProductView(fullProduct) {
                        store.icone(for: fullProduct)
                    }
                    .productStyle()
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
}

struct ProductViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: 20))
    }
}

private extension View {
    func productStyle() -> some View {
        modifier(ProductViewModifier())
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
