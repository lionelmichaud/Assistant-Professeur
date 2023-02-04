//
//  StepEditor.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/01/2023.
//

import SwiftUI

struct StepEditor: View {
    @Binding
    var step: ExamStep

    @Environment(\.horizontalSizeClass)
    var hClass

    var nameView: some View {
        HStack {
            Image(systemName: "figure.stair.stepper")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            TextField("Nom de l'étape", text: $step.name)
                .textFieldStyle(.roundedBorder)
        }
    }

    var pointsView: some View {
        Stepper(
            value: $step.points,
            in: 0 ... 10,
            step: 1
        ) {
            HStack {
                Text(hClass == .regular ? "Nombre de points" : "Points")
                Spacer()
                Text("\(step.points)")
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        if hClass == .regular {
            HStack {
                nameView
                    .padding(.trailing)
                pointsView
                    .frame(maxWidth: 280)
            }
        } else {
            GroupBox {
                nameView
                pointsView
            }
        }
    }
}

// struct StepEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        StepEditor()
//    }
// }
