//
//  DocumentControls.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/09/2023.
//

import SwiftUI

/// Contrôle checkbox permettant de définir si les documents ont été imprimés
struct DocPrintedToggle: View {
    @Binding
    var isPrinted: Bool
    let nbExemplaires: Int?
    let save: (() -> Void)?

    var body: some View {
        // checkbox isPrinted
        Button {
            isPrinted.toggle()
            (save ?? {}) ()
        } label: {
            Label(
                title: {
                    HStack {
                        Text("Supports de cours imprimés")
                        if let nbExemplaires {
                            Text("(\(nbExemplaires, format: .number))")
                                .font(.footnote)
                        }
                    }
                }, icon: {
                    Image(systemName: isPrinted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isPrinted ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }
}

/// Contrôle checkbox permettant de définir si les documents ont été distribués aux élèves
struct DocDistributedToggle: View {
    @Binding
    var isDistributed: Bool
    let save: (() -> Void)?

    var body: some View {
        // checkbox isDistributed
        Button {
            isDistributed.toggle()
            (save ?? {}) ()
        } label: {
            Label(
                title: {
                    Text("Supports de cours distribués")
                }, icon: {
                    Image(systemName: isDistributed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isDistributed ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }
}
