//
//  ClasseProgressionSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import EventKit
import SwiftUI

struct ClasseProgressSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var classeSeances: SeancesInDateInterval = .init()

    @State
    private var eventStore = EKEventStore()

    @State
    private var calendar: EKCalendar?

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    private let horizon = 3 // mois

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
        NavigationLink(value: ClasseNavigationRoute.activity(classe.id)) {
            HStack {
                Label(hClass == .compact ? "Activité" : "Activité en cours", systemImage: "book")
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
                            SequenceTag(sequenceNumber: sequence.viewNumber, font: .body)
                            ActivityTag(activityNumber: activity.viewNumber, font: .body)
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
        NavigationLink(value: ClasseNavigationRoute.nextSeances(classe.id)) {
            HStack {
                Label("Prochains cours", systemImage: "clock")
                if let firstSeance = classeSeances.seances.first {
                    Spacer()
                    Text(formattedDate(firstSeance.interval.start))
                        .foregroundColor(.secondary)
                        .bold(false)
                }
            }
            .fontWeight(.bold)
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {},
                message: { Text(alertMessage) }
            )
            .task(id: classe.objectID) { // actualiser si on sélectionne une autre classe
                // Liste des Séances à venir pour cette classe
                guard let schoolName = classe.school?.viewName else {
                    return
                }

                // Demander les droits d'accès aux calendriers de l'utilisateur
                (
                    calendar,
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = await EventManager.shared
                    .requestCalendarAccess(
                        eventStore: eventStore,
                        calendarName: schoolName
                    )
                guard let calendar else {
                    return
                }

                await ClasseEntity.context.perform {
                    let schoolYear = UserPrefEntity.shared.viewSchoolYearPref

                    let horizon = DateInterval(
                        start: Date.now,
                        end: horizon.months.fromNow!
                    )

                    // Liste des Séances à venir pour cette classe
                    classeSeances.loadClasseSeancesFromCalendar(
                        forDiscipline: classe.disciplineEnum,
                        forSchoolName: schoolName,
                        forClasseName: classe.displayString,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: horizon,
                        schoolYear: schoolYear
                    )
                }
            }
        }
    }

    private var progressView: some View {
        NavigationLink(value: ClasseNavigationRoute.progress(classe.id)) {
            Label("Actualiser la progression", systemImage: "figure.walk.motion")
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
