//
//  ClasseTimerModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/04/2023.
//

import SwiftUI

struct ClasseTimerModal: View {
    var test: Bool = false

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        SeanceTimerView(test: test)
        #if os(iOS)
        .navigationTitle("Chronomètre")
            // .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour") {
                        dismiss()
                    }
                }
            }
    }
}

struct ClasseTimerModal_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                ClasseTimerModal(test: true)
            }
            .previewDevice("iPad mini (6th generation)")
            NavigationStack {
                ClasseTimerModal(test: true)
            }
            .previewDevice("iPhone 13")
        }
    }
}
