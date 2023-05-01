//
//  SettingsAgenda.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/04/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

struct SettingsAgenda: View {
    @Preference(\.seanceDuration)
    var seanceDuration

    @Preference(\.interSeancesDuration)
    var interSeancesDuration

    @Preference(\.recreationDuration)
    var recreationDuration

    @Preference(\.lunchDuration)
    var lunchDuration

    @Preference(\.hourOfFirstSeance)
    var hourOfFirstSeance
    @Preference(\.minutesOfFirstSeance)
    var minutesOfFirstSeance

    @State
    private var firstSeanceOfTheDay: Date = .now

    var body: some View {
        VStack(spacing: 10) {
            List {
                editView
                    .onAppear {
                        let startOfDay = Calendar.current.startOfDay(for: .now)
                        firstSeanceOfTheDay = (hourOfFirstSeance.hours + minutesOfFirstSeance.minutes).from(startOfDay)!
                    }
                ForEach(AgendaManager.shared.seances, id: \.self) { seance in
                    HStack {
                        Image(systemName: "clock")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(seance.start.formatted(date: .omitted, time: .shortened))
                            Text(seance.end.formatted(date: .omitted, time: .shortened))
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Agenda")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Subviews

extension SettingsAgenda {
    private var editView: some View {
        Section {
            DatePicker(
                "1er cours de la journée à",
                selection: $firstSeanceOfTheDay,
                displayedComponents: [.hourAndMinute]
            )
            .onChange(of: firstSeanceOfTheDay) { newDate in
                let firstSeance =
                    Calendar.current.dateComponents(
                        [.hour, .minute],
                        from: newDate
                    )
                hourOfFirstSeance = firstSeance.hour!
                minutesOfFirstSeance = firstSeance.minute!
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée d'une séance")
                    Spacer()
                    Text("\(seanceDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                seanceDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                seanceDuration -= 5
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée inter-séance")
                    Spacer()
                    Text("\(interSeancesDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                interSeancesDuration += 1
                AgendaManager.shared.update()
            } onDecrement: {
                interSeancesDuration -= 1
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée de la récréation")
                    Spacer()
                    Text("\(recreationDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                recreationDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                recreationDuration -= 5
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée du déjeuné")
                    Spacer()
                    Text("\(lunchDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                lunchDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                lunchDuration -= 5
                AgendaManager.shared.update()
            }

        } header: {
            Text("Horaires de cours journaliers")
        } footer: {
            Text("Durée exprimées en minutes")
        }
    }
}

struct SettingsAgenda_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsAgenda()
        }
        .previewDevice("iPhone 13")
    }
}
