//
//  StepsList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/01/2023.
//

import HelpersView
import SwiftUI

struct StepsListView: View {
    @ObservedObject
    var exam: ExamEntity

    @State
    private var isAddingNewStep = false

    private var nbOfSteps: Int? {
        return exam.nbOfSteps
    }

    var body: some View {
        // Barême calculé à partir des étapes de l'évaluation
        HStack {
            IntegerView(
                label: "Barême",
                integer: exam.viewMaxMark,
                comment: "calculé"
            )
            Text("points")
        }

        // étapes de l'évaluation
        if let nbOfSteps {
            Section {
                // ajouter une étape
                Button {
                    isAddingNewStep = true
                } label: {
                    Label("Ajouter une étape", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)

                ForEach(exam.viewSteps, id: \.self) { step in
                    Text(step.name)
                    Text(step.points.formatted(.number))
                }
                .sheet(isPresented: $isAddingNewStep) {
                    Text("Add")
                        .presentationDetents([.medium])
                }
            } header: {
                Text("Étapes de l'évaluation (\(nbOfSteps))")
            }
            .headerProminence(.increased)
        }
    }
}

// struct StepsList_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsList()
//    }
// }
