//
//  ClasseProgressionSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import SwiftUI

struct ClasseProgressSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var classeSeances: DateIntervalSeances = .init()

    var body: some View {
        if let progresses = classe.progresses,
           progresses.count != 0 {
            Section {
                // Activité en cours
                currentActivityView

                // Cours à venir
                nextSeancesView

                // Actualisation de la progression glogale
                progressView
            } header: {
                Text("Progression")
                    .style(.sectionHeader)
            }
        }
    }
}

// MARK: - Subviews

extension ClasseProgressSection {
    private var currentActivityView: some View {
        NavigationLink(value: ClasseNavigationRoute.activity(classe)) {
            HStack {
                Label(hClass == .compact ? "Activité" : "Activité en cours", systemImage: "book.fill")
                    .fontWeight(.bold)
                if let activity = classe.currentActivity,
                   let sequence = activity.sequence {
                    let currentActivityProgress =
                        classe
                            .sortedProgressesInSequence(sequence)
                            .first(where: { $0.activity == activity })
                    Spacer()
                    if hClass == .compact {
                        HStack {
                            SequenceTag(sequence: sequence, font: .body)
                            ActivityTag(activity: activity, font: .body)
                            Text("(\(currentActivityProgress!.progress, format: .percent))")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Séquence \(sequence.viewNumber) - Activité \(activity.viewNumber) (\(currentActivityProgress!.progress, format: .percent))")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var nextSeancesView: some View {
        NavigationLink(value: ClasseNavigationRoute.nextSeances(classe)) {
            HStack {
                Label("Prochains cours", systemImage: "clock")
                if classeSeances.seances.isNotEmpty {
                    Spacer()
                    Text(formattedDate(classeSeances.seances.first!.event.startDate))
                        .foregroundColor(.secondary)
                        .bold(false)
                }
            }
            .fontWeight(.bold)
            .task {
                // Liste des Séances à venir pour cette classe
                if let schoolName = classe.school?.viewName {
                    await $classeSeances.loadSeancesFromCalendar(
                        forDiscipline: classe.disciplineEnum,
                        forClasse: classe.displayString,
                        schoolName: schoolName,
                        during: DateInterval(
                            start: Date.now,
                            end: 3.months.fromNow!
                        )
                    )
                }
            }
        }
    }

    private var progressView: some View {
        NavigationLink(value: ClasseNavigationRoute.progress(classe)) {
            Label("Actualiser la progression", systemImage: ProgramEntity.defaultImageName)
                .fontWeight(.bold)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 1:
                return "demain"

            case 2:
                return "après-demain"

            case 3 ... 6:
                return "\(date.formatted(Date.FormatStyle().weekday(.wide))) prochain"

            default:
                return date
                    .formatted(Date.FormatStyle()
                        .weekday(.wide)
                        .day(.twoDigits)
                        .month(.twoDigits))
        }
    }
}

struct ClasseProgressionSection_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseProgressSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseProgressSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
