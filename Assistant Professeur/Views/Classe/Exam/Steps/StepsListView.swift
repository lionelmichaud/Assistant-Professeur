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
                    insertItem()
                } label: {
                    Label("Ajouter une étape", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)

                ForEach($exam.viewSteps) { $step in
                    StepEditor(step: $step)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
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

    private func insertItem() {
        withAnimation {
            exam.viewSteps.append(ExamStep(name: "Etape", points: 0))
        }
    }

    private func moveItems(fromOffsets: IndexSet, toOffset: Int) {
        withAnimation {
            exam.viewSteps.move(fromOffsets: fromOffsets, toOffset: toOffset)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            exam.viewSteps.remove(atOffsets: offsets)
        }
    }
}

// struct StepsList_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsList()
//    }
// }
