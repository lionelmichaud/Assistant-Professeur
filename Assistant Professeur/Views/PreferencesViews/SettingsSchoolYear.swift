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
    @ObservedObject
    private var pref = UserPrefEntity.shared

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

    var body: some View {
        Form {
            // Zone scolaire
            Section {
                CasePicker(
                    pickedCase: $pref.viewSchoolYearPref.zone,
                    label: "Zone scolaire"
                )
                .pickerStyle(.segmented)
                Text("\(pref.viewSchoolYearPref.zone.academy)")
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
                        selection: $pref.viewSchoolYearPref.interval.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.viewSchoolYearPref.interval.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Année scolaire")
                    .style(.sectionHeader)
            }

            // Périodes de vacances scolaires
            ForEach($pref.viewSchoolYearPref.vacances) { $vacance in
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
                    .disabled(!EventManager.shared.isAccessAuthorized)
                    .horizontallyAligned(.center)
                } header: {
                    Text(vacance.name)
                        .style(.sectionHeader)
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
                    calendarName: pref.viewSchoolYearPref.calName
                )
            if let calendar {
                let success = EventManager.saveOrUpdate(
                    eventTitle: eventTitle,
                    eventDateInterval: eventDateInterval,
                    during: pref.viewSchoolYearPref.interval,
                    inCalendar: calendar,
                    inEventStore: eventStore
                )
                if success {
                    alertTitle = "L'événement a été enregistré."
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
}

struct SettingsSchoolYear_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchoolYear()
            .environmentObject(UserPrefEntity())
    }
}
