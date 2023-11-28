//
//  SettingsSchoolYear.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/05/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct SettingsSchoolYear: View {
    @Environment(UserContext.self)
    private var userContext

    @State
    private var eventStore = EKEventStore()

    @State
    private var calendar: EKCalendar?

    @State
    private var popOverSynchroIsPresented: Bool = false

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        @Bindable var userContext = userContext
        Form {
            // Zone scolaire
            Section {
                CasePicker(
                    pickedCase: $userContext.prefs.viewSchoolYearPref.zone,
                    label: "Zone scolaire"
                )
                .pickerStyle(.segmented)
                Text("\(userContext.prefs.viewSchoolYearPref.zone.academy)")
                    .foregroundColor(.secondary)
            } header: {
                Text("Zone scolaire")
                    .style(.sectionHeader)
            }

            // Année scolaire
            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $userContext.prefs.viewSchoolYearPref.interval.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $userContext.prefs.viewSchoolYearPref.interval.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                .popover(isPresented: $popOverSynchroIsPresented) {
                    Text("""
                            Il est possible de mettre à jour le calendrier **'\(userContext.prefs.viewSchoolYearPref.calName)'** dans l'application Calendrier depuis ici.
                            Mais une mise à jour dans l'application Calendrier ne sera pas répercutée ici.
                            """)
                    .foregroundColor(.primary)
                    .padding()
                }
            } header: {
                Text("Année scolaire")
                    .style(.sectionHeader)
            }

            // Périodes de vacances scolaires
            ForEach($userContext.prefs.viewSchoolYearPref.vacances) { $vacance in
                Section {
                    HStack {
                        Text("du")
                        DatePicker(
                            "Début",
                            selection: $vacance.interval.start,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        Text("au")
                        DatePicker(
                            "Fin",
                            selection: $vacance.interval.end,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                    Button {
                        saveOrUpdate(
                            eventTitle: vacance.name,
                            eventDateInterval: vacance.interval
                        )
                    } label: {
                        Text("Mettre à jour l'App Calendrier")
                    }
                    .disabled(!EventManager.shared.isFullAccessAuthorized)
                    .horizontallyAligned(.center)
                } header: {
                    HStack {
                        Text(vacance.name)
                            .style(.sectionHeader)
                        // Afficher le PopOver d'information
                        Button {
                            popOverSynchroIsPresented = true
                        } label: {
                            Image(systemName: "info.bubble")
                        }
                    }
                }
            }
        }
        .padding(.bottom, 34)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Année scolaire")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// Ajouter ou mettre à jour le calendrier "Année scoalire" dans l'appli Calendrier.
    ///
    /// - Parameters:
    ///   - eventTitle: Nom de l'événement à ajouter / modifier
    ///   - eventDateInterval: Dates début / fin
    private func saveOrUpdate(
        eventTitle: String,
        eventDateInterval: DateInterval
    ) {
        Task {
            // Demander les droits d'accès aux calendriers de l'utilisateur
            (
                calendar,
                alertIsPresented,
                alertTitle,
                alertMessage
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: userContext.prefs.viewSchoolYearPref.calName
                )

            guard let calendar else {
                return
            }

            let success = EventManager.saveOrUpdate(
                eventTitle: eventTitle,
                eventDateInterval: eventDateInterval,
                during: await userContext.prefs.viewSchoolYearPref.interval,
                inCalendar: calendar,
                inEventStore: eventStore
            )
            if success {
                alertTitle = "L'événement a été enregistré dans le calendrier **\(await userContext.prefs.viewSchoolYearPref.calName)**."
                alertMessage = ""
                alertIsPresented.toggle()
            } else {
                alertTitle = "L'enregistrement à échoué."
                alertMessage = ""
                alertIsPresented.toggle()
            }
        }
    }
}

struct SettingsSchoolYear_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchoolYear()
            .environmentObject(UserPrefEntity())
    }
}
