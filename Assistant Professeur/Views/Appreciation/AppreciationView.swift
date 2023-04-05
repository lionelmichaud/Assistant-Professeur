//
//  AppreciationView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 17/06/2022.
//

import SwiftUI

struct AppreciationView: View {
    @Binding var appreciation: String

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            TextField(
                "Appréciation",
                text: $appreciation,
                axis: .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)
            .onChange(of: appreciation) { newValue in
                isExpanded = newValue.isNotEmpty
            }
        } label: {
            HStack {
                Label("Appréciation", systemImage: "note.text")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(hClass == .compact ? "..." : appreciation.truncate(to: 20, addEllipsis: true))
                    .foregroundColor(.secondary)
            }
        }
        .listRowSeparator(.hidden)
        .onAppear {
            isExpanded = appreciation.isNotEmpty
        }
    }
}

struct AppreciationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                AppreciationView(appreciation: .constant("Ceci est une appréciation"))
            }
            .previewDevice("iPad mini (6th generation)")

            List {
                AppreciationView(appreciation: .constant("Ceci est une appréciation"))
            }
            .previewDevice("iPhone 13")
        }
    }
}
