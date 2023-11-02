//
//  WCompMasteryLevels.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/06/2023.
//

import HelpersView
import SwiftUI

struct WCompMasteryLevels: View {
    @ObservedObject
    var workedComp: WCompEntity

    @State
    private var selectedLevel: MasteryLevel?

    @State
    private var editedLevel: MasteryLevel?

    var body: some View {
        let masteryDefinitions =
            workedComp
                .viewMasteryDefinitions
                .keys
                .sorted { $0.rawValue < $1.rawValue }

        return List(selection: $selectedLevel) {
            Group {
                Text(workedComp.viewAcronym)
                    .fontWeight(.bold) +
                Text(". ") +
                Text(workedComp.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
            .textSelection(.enabled)

            ForEach(masteryDefinitions) { masteryLevel in
                HStack {
                    VStack(alignment: .leading) {
                        Text(masteryLevel.displayString)
                            .foregroundColor(masteryLevel.imageColor)
                        Text(workedComp.viewMasteryDefinitions[masteryLevel]!)
                    }
                    Spacer()
                    Button {
                        editedLevel = masteryLevel
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // modifier le critère de maîtrise de compétence
                    Button {
                        editedLevel = masteryLevel
                    } label: {
                        Label("Modifier", systemImage: "square.and.pencil")
                    }
                }
            }
            .emptyListPlaceHolder(masteryDefinitions) {
                ContentUnavailableView(
                    "Aucun critère de maîtrise...",
                    systemImage: "ruler",
                    description: Text("Les critère de maîtrise ajoutés apparaîtront ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Critère de maîtrise")
        #endif
        .navigationBarTitleDisplayModeInline()

        // Modal Sheet de modification d'un critère de maîtrise de compétence
        .sheet(
            item: $editedLevel,
            onDismiss: didDismiss
        ) { definition in
            NavigationStack {
                WCompMasteryEdit(
                    workedComp: workedComp,
                    editedLevel: definition
                )
            }
            .presentationDetents([.medium])
        }
    }

    private func didDismiss() {
        editedLevel = nil
    }
}

// struct WCompMasteryLevels_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompMasteryLevels()
//    }
// }
