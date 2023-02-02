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

        // Étapes de l'évaluation
        if let nbOfSteps {
            DisclosureGroup {
                // Ajouter une étape
                Button {
                    addItem()
                } label: {
                    Label("Ajouter une étape", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)

                // Liste des étapes
                ForEach($exam.viewSteps) { $step in
                    StepEditor(step: $step)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            } label: {
                Text("Étapes de l'évaluation (\(nbOfSteps))")
            }
            .headerProminence(.increased)
        }
    }

    private func addItem() {
        withAnimation {
            // Ajouter une étape supplémentaire à l'évaluation
            exam.viewSteps.append(ExamStep(name: "Etape", points: 0))
            
            // Ajouter une note d'étape supplémentaire pour cette étape à chaque note d'élève de la classe
            exam.allMarks.forEach { mark in
                mark.viewSteps.append(0.0)
            }
        }
    }

    private func moveItems(fromOffsets: IndexSet, toOffset: Int) {
        withAnimation {
            // Déplacer une étape de l'évaluation
            exam.viewSteps.move(fromOffsets: fromOffsets, toOffset: toOffset)

            // Déplacer une note d'étape de chaque note d'élève de la classe
            exam.allMarks.forEach { mark in
                mark.viewSteps.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // Supprimer une étape de l'évaluation
            exam.viewSteps.remove(atOffsets: offsets)

            // Supprimer une note d'étape de chaque note d'élève de la classe
            exam.allMarks.forEach { mark in
                mark.viewSteps.remove(atOffsets: offsets)
            }
        }
    }
}

// struct StepsList_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsList()
//    }
// }
