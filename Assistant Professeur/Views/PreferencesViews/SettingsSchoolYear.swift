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
                    .style(.sectionHeader)
            }

            // Année scolaire
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
                    .style(.sectionHeader)
            }

            // Périodes de vacances scolaires
            ForEach($pref.schoolYear.vacances) { $vacance in
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
            actions: {}
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
