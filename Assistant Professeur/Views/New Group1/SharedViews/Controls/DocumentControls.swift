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

    @Environment(\.horizontalSizeClass)
    private var hClass

    var label: String {
        if hClass == .compact { "Supports imprimés" } else { "Supports de cours imprimés" }
    }

    var body: some View {
        // checkbox isPrinted
        Button {
            isPrinted.toggle()
            (save ?? {}) ()
        } label: {
            Label(
                title: {
                    HStack {
                        Text(label)
                        if let nbExemplaires {
                            Text("(\(nbExemplaires, format: .number))")
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

    @Environment(\.horizontalSizeClass)
    private var hClass

    var label: String {
        if hClass == .compact { "Supports distribués" } else { "Supports de cours distribués" }
    }

    var body: some View {
        // checkbox isDistributed
        Button {
            isDistributed.toggle()
            (save ?? {}) ()
        } label: {
            Label(
                title: {
                    Text(label)
                }, icon: {
                    Image(systemName: isDistributed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isDistributed ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }
}

/// Contrôle checkbox permettant de définir si les documents ont été stocké sur l'ENT
struct DocLoadedToggle: View {
    @Binding
    var isLoaded: Bool
    let save: (() -> Void)?

    @Environment(\.horizontalSizeClass)
    private var hClass

    var label: String {
        if hClass == .compact { "Ressources chargées" } else { "Ressources chargées sur ENT" }
    }

    var body: some View {
        // checkbox isDistributed
        Button {
            isLoaded.toggle()
            (save ?? {}) ()
        } label: {
            Label(
                title: {
                    Text(label)
                }, icon: {
                    Image(systemName: isLoaded ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isLoaded ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }
}
