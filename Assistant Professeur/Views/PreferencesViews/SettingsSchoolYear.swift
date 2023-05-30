//
//  SettingsSchoolYear.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/05/2023.
//

import HelpersView
import SwiftUI

struct SettingsSchoolYear: View {
    @EnvironmentObject
    private var pref: UserPreferences

    @State
    private var alertTitle = ""
    @State
    private var alertIsPresented = false

    var body: some View {
        Form {
            // Zone scolaire
            Section {
                CasePicker(
                    pickedCase: $pref.schoolYear.zone,
                    label: "Zone scolaire"
                )
                .pickerStyle(.segmented)
                Text("\(pref.schoolYear.zone.academy)")
                    .foregroundColor(.secondary)
            } header: {
                Text("Zone scolaire")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.interval.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.interval.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Année scolaire")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.autumnVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.autumnVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                Button {
                    saveEvent(
                        eventTitle: "Vacances de Toussaint",
                        eventDateInterval: pref.schoolYear.autumnVacation
                    )
                } label: {
                    Text("Mettre à jour l'App Calendrier")
                }
                .horizontallyAligned(.center)
            } header: {
                Text("Vacances de Toussaint")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.noelVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.noelVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                Button {
                    saveEvent(
                        eventTitle: "Vacances de Noël",
                        eventDateInterval: pref.schoolYear.noelVacation
                    )
                } label: {
                    Text("Mettre à jour l'App Calendrier")
                }
                .horizontallyAligned(.center)
            } header: {
                Text("Vacances de Noël")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.winterVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.winterVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                Button {
                    saveEvent(
                        eventTitle: "Vacances d'hiver",
                        eventDateInterval: pref.schoolYear.winterVacation
                    )
                } label: {
                    Text("Mettre à jour l'App Calendrier")
                }
                .horizontallyAligned(.center)
            } header: {
                Text("Vacances d'hiver")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.paqueVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.paqueVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                Button {
                    saveEvent(
                        eventTitle: "Vacances de printemps",
                        eventDateInterval: pref.schoolYear.paqueVacation
                    )
                } label: {
                    Text("Mettre à jour l'App Calendrier")
                }
                .horizontallyAligned(.center)
            } header: {
                Text("Vacances de printemps")
            }
        }
        .padding(.bottom, 34)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {}
        )
        #if os(iOS)
        .navigationTitle("Année scolaire")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func saveEvent(
        eventTitle: String,
        eventDateInterval: DateInterval
    ) {
        Task {
            let success = await EventManager.saveOrUpdate(
                eventTitle: eventTitle,
                eventDateInterval: eventDateInterval,
                toCalendarNamed: pref.schoolYear.calName,
                during: pref.schoolYear.interval
            )
            if success {
                alertTitle = "L'événement a été enregistré."
                alertIsPresented.toggle()
            } else {
                alertTitle = "L'enregistrement à échoué."
                alertIsPresented.toggle()
            }
        }
    }
}

struct SettingsSchoolYear_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchoolYear()
            .environmentObject(UserPreferences())
    }
}
