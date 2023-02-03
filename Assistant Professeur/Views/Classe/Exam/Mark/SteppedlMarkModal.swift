//
//  SteppedlMarkModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/02/2023.
//

import SwiftUI

struct SteppedlMarkModal: View {
    @ObservedObject
    var mark: MarkEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        Group {
            if hClass == .regular {
                StepsNotationView(
                    exam: mark.exam!,
                    width: 250,
                    stepsMarks: $mark.viewStepsMarks
                )
            } else {
                StepsNotationView(
                    exam: mark.exam!,
                    width: 125,
                    stepsMarks: $mark.viewStepsMarks
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
                        try? MarkEntity.saveIfContextHasChanged()
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct SteppedlMarkModal_Previews: PreviewProvider {
//    static var previews: some View {
//        SteppedlMarkModal()
//    }
// }
