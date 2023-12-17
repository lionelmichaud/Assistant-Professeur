//
//  StoreViewModifiers.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/12/2023.
//

import SwiftUI

struct ProductViewModifier: ViewModifier {
    let isPurchasable: Bool

    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: 20))
            .overlay {
                if !isPurchasable {
                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(.gray)
                        .opacity(0.51)
                }
            }
    }
}

extension View {
    func productStyle(isPurchasable: Bool) -> some View {
        modifier(ProductViewModifier(isPurchasable: isPurchasable))
    }
}
