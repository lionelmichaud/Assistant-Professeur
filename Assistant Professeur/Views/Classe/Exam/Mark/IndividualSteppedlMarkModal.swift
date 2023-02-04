//
//  SteppedlMarkModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/02/2023.
//

import SwiftUI

struct IndividualSteppedlMarkModal: View {
    // MARK: - Initializer

    init(mark: MarkEntity) {
        self.mark = mark

        // Initializer les notes échelonnées à partir des
        // notes actuelles de l'élève
        self._stepsMarks = State(
            initialValue: mark.viewStepsMarks
        )
    }

    // MARK: - Properties

    @ObservedObject
    var mark: MarkEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var stepsMarks: [Double]

    var body: some View {
        Group {
            if hClass == .regular {
                StepsNotationView(
                    exam: mark.exam!,
                    width: 250,
                    stepsMarks: $stepsMarks
                )
            } else {
                StepsNotationView(
                    exam: mark.exam!,
                    width: 125,
                    stepsMarks: $stepsMarks
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Note individuelle")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Attribuer") {
                    withAnimation {
                        attribuer(stepsMarks: stepsMarks)
                    }
                    dismiss()
                }
            }
        }
    }

    // MARK: - Methods

    /// Affecter les nouvelles notes échelonnées à l'élève
    private func attribuer(stepsMarks: [Double]) {
        mark.viewStepsMarks = stepsMarks
        try? MarkEntity.saveIfContextHasChanged()
    }
}

// struct SteppedlMarkModal_Previews: PreviewProvider {
//    static var previews: some View {
//        SteppedlMarkModal()
//    }
// }
