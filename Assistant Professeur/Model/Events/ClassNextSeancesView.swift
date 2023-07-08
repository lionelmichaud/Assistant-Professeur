//
//  ClassNextSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import HelpersView
import SwiftUI

struct ClassNextSeancesView: View {
    @ObservedObject
    var classe: ClasseEntity

    private let horizon = 3 // mois

    @State
    private var classeSeances: DateIntervalSeances = .init()

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(classeSeances.seances, id: \.self) { seance in
                NextSeanceRow(seance: seance.event)
            }
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .task {
            // Liste des Progressions de la classe triée par numéro de Séquence / Activité
            let sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber

            // Liste des Séances à venir pour cette classe
            if let schoolName = classe.school?.viewName {
                await $classeSeances.loadSeances(
                    forDiscipline: classe.disciplineEnum,
                    forClasse: classe.displayString,
                    schoolName: schoolName,
                    during: DateInterval(
                        start: Date.now,
                        end: horizon.months.fromNow!
                    )
                )

                // Synchroniser les Progressions avec les Séances
                SequenceSeanceCoordinator.synchronize(
                    classeProgresses: sortedClasseProgresses,
                    withSeances: classeSeances
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Cours à venir")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

struct ClassNextSeances_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first { classe in
            classe.levelEnum == .n5ieme
        }!
        print(classe)
        return Group {
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPad mini (6th generation)")
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPhone 13")
        }
    }
}
