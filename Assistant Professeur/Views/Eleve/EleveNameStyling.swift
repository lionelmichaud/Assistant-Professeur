//
//  EleveNameStyling.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/01/2023.
//

import SwiftUI

struct EleveNameStyling: ViewModifier {
    let hasTrouble: Bool
    let hasAddTime: Bool

    func body(content: Content) -> some View {
        content
            .padding(2)
            .background {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.primary, lineWidth: hasAddTime ? 2 : 0)
                        .foregroundColor(.gray)
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .opacity(hasTrouble ? 1.0 : 0.0)
                }
            }
    }
}

extension View {
    public func elevNameStyling(
        hasTrouble: Bool,
        hasAddTime: Bool
    ) -> some View {
        modifier(EleveNameStyling(hasTrouble: hasTrouble,
                                  hasAddTime: hasAddTime))
    }
}
