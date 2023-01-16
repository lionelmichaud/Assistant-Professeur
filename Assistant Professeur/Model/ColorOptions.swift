//
//  ColorOptions.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import SwiftUI

struct ColorOptions {
    static var all: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .cyan,
        .indigo,
        .purple,
        .gray,
        .primary
    ]

    static var `default` : Color = Color.primary

    static func random() -> Color {
        if let element = ColorOptions.all.randomElement() {
            return element
        } else {
            return .primary
        }

    }
}
