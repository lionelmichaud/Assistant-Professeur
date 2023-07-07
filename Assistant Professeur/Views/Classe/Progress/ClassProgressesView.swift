//
//  ClassGlobalProgress.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import HelpersView
import SwiftUI

/// Situation de la progression d'une classe par Séquence / Activité
struct ClassProgressesView: View {
    @ObservedObject
    var classe: ClasseEntity

    private let horizon = 3 // mois

    @State
    private var classeSequences = [SequenceEntity]()

    @State
    private var classeSeances: DateIntervalSeances = .init()

    var body: some View {
        List {
            ProgressView(value: classe.progressInProgram())
                .tint(.teal)

            ForEach(classeSequences) { sequence in
                ClassSequenceProgressEditView(
                    sequence: sequence,
                    classe: classe
                )
            }
            .emptyListPlaceHolder(classeSequences) {
                Text("Aucune séquence suivie par cette classe")
            }
        }
        .task {
            // Liste des Séquences suivies par une classe triée par numéro de Séquence
            classeSequences = classe.allFollowedSequencesSortedBySequenceNumber

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
        .navigationTitle("Progression en \(classe.discipline!)")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

struct ClassProgressesView_Previews: PreviewProvider {
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
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
