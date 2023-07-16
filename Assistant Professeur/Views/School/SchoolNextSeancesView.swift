//
//  SchoolNextSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import HelpersView
import SwiftUI

struct SchoolNextSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

    private let horizon = 3 // mois

    @State
    private var schoolSeances: SeancesInDateInterval = .init()

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(schoolSeances.seances) { seance in
                SeanceRow(seance: seance)
            }
            .emptyListPlaceHolder(schoolSeances.seances) {
                EmptyListMessage(
                    symbolName: "clock",
                    title: "Aucun cours trouvé dans votre agenda.",
                    message: "Les cours plannifiés dans votre agenda pour les classes de cet établissement apparaîtront ici.",
                    showAsGroupBox: true
                )
            }
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .task {
            var foundSeances = [Seance]()
            let schoolClasses = school.classesSortedByLevelNumber
            let schoolName = school.viewName

            await withTaskGroup(of: [Seance].self) { group in
                for classe in schoolClasses {
                    group.addTask {
                        var sortedClasseProgresses = [ActivityProgressEntity]()
                        await ClasseEntity.context.perform {
                            // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                            sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber
                        }

                        var classeSeances: SeancesInDateInterval = .init()
                        var forDiscipline = Discipline.autre
                        var forClasseName = ""

                        await ClasseEntity.context.perform {
                            forDiscipline = classe.disciplineEnum
                            forClasseName = classe.displayString
                        }

                        // Liste des Séances à venir pour cette classe
                        await classeSeances.loadSeancesFromCalendar(
                            forDiscipline: forDiscipline,
                            forClasseName: forClasseName,
                            schoolName: schoolName,
                            during: DateInterval(
                                start: Date.now,
                                end: horizon.months.fromNow!
                            )
                        )

                        await ClasseEntity.context.perform {
                            // Synchroniser les Progressions de la classe avec les Séances de la classe
                            SequenceSeanceCoordinator.synchronize(
                                classeSeances: &classeSeances,
                                withProgresses: sortedClasseProgresses
                            )
                        }

                        return classeSeances.seances
                    }
                }
                for await seances in group {
                    foundSeances.append(contentsOf: seances)
                }
            }

            // remettre les séances dans l'ordre (async => désordre)
            foundSeances.sort(by: {
                $0.event.startDate < $1.event.startDate
            })

            // Ajouter les séances de cette classe à celles de l'établissement
            schoolSeances = SeancesInDateInterval(from: foundSeances)
        }
        #if os(iOS)
        .navigationTitle("Cours à venir")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

// struct SchoolNextSeancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolNextSeancesView()
//    }
// }
