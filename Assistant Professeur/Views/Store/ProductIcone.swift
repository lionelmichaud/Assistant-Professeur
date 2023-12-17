//
//  ProductIcone.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/12/2023.
//

import SwiftUI

struct ProductIcone: View {
    let systemName: String
    let isPurchased: Bool

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 80, maxHeight: 80)
            .padding()
            .background(.fill.tertiary, in: .circle)
            .foregroundStyle(
                isPurchased ?
                    Color.purchasedProductColor :
                    Color.notPurchedProductColor)
    }
}

#Preview {
    ProductIcone(
        systemName: "star",
        isPurchased: false
    )
}

#Preview {
    ProductIcone(
        systemName: "star",
        isPurchased: true
    )
}
