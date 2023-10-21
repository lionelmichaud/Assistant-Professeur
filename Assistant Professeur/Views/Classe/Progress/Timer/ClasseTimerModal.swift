//
//  ClasseTimerModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/04/2023.
//

import SwiftUI

/// Fenêtre modale de présentation d'un chronomètre de séance
struct ClasseTimerModal: View {
    var discipline: Discipline
    var classeName: String
    var schoolName: String
    var test: Bool = false

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        SeanceTimerView(
            discipline: discipline,
            classeName: classeName,
            schoolName: schoolName
        )
        #if os(iOS)
        .navigationTitle("Chronomètre")
        //.navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour", systemImage: "xmark.circle.fill") {
                        dismiss()
                    }
                }
            }
    }
}

struct ClasseTimerModal_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        return Group {
            NavigationStack {
                ClasseTimerModal(
                    discipline: classe.disciplineEnum,
                    classeName: classe.displayString,
                    schoolName: classe.school!.viewName,
                    test: true
                )
            }
            .previewDevice("iPad mini (6th generation)")
            NavigationStack {
                ClasseTimerModal(
                    discipline: classe.disciplineEnum,
                    classeName: classe.displayString,
                    schoolName: classe.school!.viewName,
                    test: true
                )
            }
            .previewDevice("iPhone 13")
        }
    }
}
