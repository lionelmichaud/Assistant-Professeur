//
//  ActivityTimerView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/04/2023.
//

import SwiftUI

struct ActivityTimerView: View {
    @ObservedObject
    var activity: ActivityEntity
    var lineWidth: Double = 40.0
    var warningRemainingMinutes: Int? = nil
    var alertRemainingMinutes: Int? = nil
    var test: Bool = false

    enum TimerColors {
        case normal, warning, alert
        var color: Color {
            switch self {
                case .normal:
                    return .green
                case .warning:
                    return .orange
                case .alert:
                    return .red
            }
        }
    }

    @Preference(\.seanceDuration)
    private var seanceDuration

    var body: some View {
        TimelineView(.periodic(from: .now, by: 5)) { timeLine in
            if let trimValue = cursorValue(for: timeLine.date) {
                let color = cursorColor(for: timeLine.date)
                VStack {
                    ZStack {
                        // le fond
                        Circle()
                            .fill(Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.secondary,
                                        lineWidth: lineWidth
                                    )
                            )

                        // le curseur
                        Circle()
                            .trim(from: 0, to: trimValue)
                            .stroke(style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round,
                                lineJoin: .round
                            ))
                            .foregroundColor(color)
                            .animation(.easeInOut, value: 0.2)
                            .rotationEffect(.degrees(-90.0))

                        // le compte à rebour
                        if let elapsedTime = elapsedTime(for: timeLine.date),
                           let remainingTime = remainingTime(for: timeLine.date) {
                            DigitalClockView(
                                elapsedTime: elapsedTime,
                                remainingTime: remainingTime,
                                color: color
                            )
                        }
                    }
                    .padding(lineWidth)

                    // affichage des seuils d'alerte
                    if let warningRemainingMinutes {
                        Text("Alerte: ")
                            .font(.title)
                            .bold()
                            .foregroundColor(TimerColors.warning.color)
                        + Text("-\(warningRemainingMinutes) minutes")
                            .font(.title)
                            .bold()
                    }
                    if let alertRemainingMinutes {
                        Text("Alarme: ")
                            .font(.title)
                            .bold()
                            .foregroundColor(TimerColors.alert.color)
                        + Text("-\(alertRemainingMinutes) minutes")
                            .font(.title)
                            .bold()
                    }
                }

            } else {
                Text("Pas de séance en cours")
                    .font(.title)
            }
        }
    }

    /// Temps écoulé depuis le début de la séance
    private func elapsedTime(for date: Date) -> DateComponents? {
        guard !test else {
            return DateComponents(minute: date.minutes, second: date.seconds)
        }

        return AgendaManager.shared.elapsedTime(to: date)
    }

    /// Temps restant avant le début de la séance
    private func remainingTime(for date: Date) -> DateComponents? {
        guard !test else {
            return DateComponents(minute: 60 - date.minutes, second: 60 - date.seconds)
        }

        return AgendaManager.shared.elapsedTime(to: date)
    }

    /// Position du curseur
    private func cursorValue(for date: Date) -> Double? {
        guard !test else {
            return date.minutes.double() / 60.0
        }

        if let elapsedMinutes = AgendaManager.shared.elapsedMinutes(to: date)?.double(),
           let seanceDuration = seanceDuration.minute?.double() {
            return (elapsedMinutes / seanceDuration)
        } else {
            return nil
        }
    }

    /// Couleur du curseur
    private func cursorColor(for date: Date) -> Color {
        guard let remaingMinutes = remainingTime(for: date)?.minute else {
            return TimerColors.normal.color
        }
        if let alertRemainingMinutes, remaingMinutes < alertRemainingMinutes {
            return TimerColors.alert.color
        }
        if let warningRemainingMinutes, remaingMinutes < warningRemainingMinutes {
            return TimerColors.warning.color
        }
        return .green
    }
}

struct ActivityTimerView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let activity = ActivityEntity.all().first!
        return Group {
            ActivityTimerView(
                activity: activity,
                warningRemainingMinutes: 10,
                alertRemainingMinutes: 5,
                test: true
            )
            .previewDevice("iPad mini (6th generation)")
            ActivityTimerView(
                activity: activity,
                lineWidth: 40,
                warningRemainingMinutes: 10,
                alertRemainingMinutes: 5,
                test: true
            )
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
