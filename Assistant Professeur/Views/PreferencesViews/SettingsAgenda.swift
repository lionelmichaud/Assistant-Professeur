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
    @EnvironmentObject
    private var pref: UserPreferences

    @State
    private var firstSeanceOfTheDay: Date = .now

    var body: some View {
        VStack(spacing: 10) {
            List {
                editView
                    .onAppear {
                        firstSeanceOfTheDay = AgendaManager.dateOfFirstSeance()
                    }
                dailyView
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
                pref.hourOfFirstSeance = firstSeance.hour!
                pref.minutesOfFirstSeance = firstSeance.minute!
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée d'une séance")
                    Spacer()
                    Text("\(pref.seanceDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                pref.seanceDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                pref.seanceDuration -= 5
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée inter-séance")
                    Spacer()
                    Text("\(pref.interSeancesDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                pref.interSeancesDuration += 1
                AgendaManager.shared.update()
            } onDecrement: {
                pref.interSeancesDuration -= 1
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée de la récréation")
                    Spacer()
                    Text("\(pref.recreationDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                pref.recreationDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                pref.recreationDuration -= 5
                AgendaManager.shared.update()
            }

            Stepper {
                HStack {
                    Text("Durée du déjeuné")
                    Spacer()
                    Text("\(pref.lunchDuration.formatted(.number))")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                pref.lunchDuration += 5
                AgendaManager.shared.update()
            } onDecrement: {
                pref.lunchDuration -= 5
                AgendaManager.shared.update()
            }

        } header: {
            Text("Horaires de cours journaliers")
        } footer: {
            Text("Durée exprimées en minutes")
        }
    }

    private var dailyView: some View {
        ForEach(AgendaManager.shared.seances.indices) { idx in
            HStack {
                Image(systemName: "clock")
                    .font(.title)
                HStack {
                    Text(AgendaManager.shared[idx]!.start
                        .formatted(date: .omitted, time: .shortened))
                    Spacer()
                    Text(" - ")
                    Spacer()
                    Text(AgendaManager.shared[idx]!.end
                        .formatted(date: .omitted, time: .shortened))
                }
                .font(.title3).bold()
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(AgendaManager.shared[idx]!).gradient))
        }
    }

    private func backgroundColor(_ amPm: AmPm) -> Color {
        return amPm == .morning ? Color.mint : Color.cyan
    }
}

struct SettingsAgenda_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsAgenda()
                    .environmentObject(UserPreferences())
            }
            .previewDevice("iPhone 13")
            SettingsAgenda()
                .environmentObject(UserPreferences())
                .previewDevice("iPad mini (6th generation)")
        }
    }
}
