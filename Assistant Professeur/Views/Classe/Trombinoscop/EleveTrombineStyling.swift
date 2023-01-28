//
//  EleveTrombineStyling.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/01/2023.
//

import SwiftUI

struct EleveTrombineStyling: ViewModifier {
    let cornerRadius: Int
    let shadowRadius: Int

    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .cornerRadius(CGFloat(cornerRadius))
            .shadow(radius: CGFloat(shadowRadius))
            .accessibility(hidden: false)
    }
}

public extension View {
    func elevTrombineStyling(
        cornerRadius: Int = 15,
        shadowRadius: Int = 5
    ) -> some View {
        modifier(EleveTrombineStyling(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        )
        )
    }
}

/// Affiche la trombine d'un élève
struct Trombine: View {
    @ObservedObject
    var eleve: EleveEntity

    var body: some View {
        eleve.viewImageTrombine
            .resizable()
            .elevTrombineStyling()
    }
}
