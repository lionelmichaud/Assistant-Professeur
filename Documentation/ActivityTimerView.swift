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

    @Preference(\.seanceDuration)
    private var seanceDuration

    var body: some View {
        TimelineView(.periodic(from: .now, by: 5)) { timeLine in
            if let trimValue = cursorValue(for: timeLine.date) {
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
                        .foregroundColor(cursorColor(for: timeLine.date))
                        .animation(.easeInOut, value: 0.2)
                        .rotationEffect(.degrees(-90.0))

                    // le compte à rebour
                    if let elapsedTime = AgendaManager.shared.elapsedTime(to: timeLine.date),
                       let remainingTime = AgendaManager.shared.remainingTime(from: timeLine.date) {
                        DigitalClockView(
                            elapsedTime: elapsedTime,
                            remainingTime: remainingTime
                        )
                    }
                }

            } else {
                Text("Pas de séance en cours")
                    .font(.title)
            }
        }
        .padding(.horizontal, lineWidth)
    }

    private func elapsedTime(for date: Date) -> DateComponents? {
        guard !test else {
            return DateComponents(minute: date.minutes, second: date.seconds)
        }

        return AgendaManager.shared.elapsedTime(to: date)
    }

    private func remainingTime(for date: Date) -> DateComponents? {
        guard !test else {
            return DateComponents(minute: 60 - date.minutes, second: 60 - date.seconds)
        }

        return AgendaManager.shared.elapsedTime(to: date)
    }

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

    private func cursorColor(for date: Date) -> Color {
        guard let remaingMinutes = AgendaManager.shared.remainingMinutes(from: date) else {
            return .green
        }
        if let alertRemainingMinutes, remaingMinutes < alertRemainingMinutes {
            return .red
        }
        if let warningRemainingMinutes, remaingMinutes < warningRemainingMinutes {
            return .orange
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
                warningRemainingMinutes: nil,
                alertRemainingMinutes: 5,
                test: true
            )
            .previewDevice("iPad mini (6th generation)")
            ActivityTimerView(
                activity: activity,
                lineWidth: 40,
                warningRemainingMinutes: nil,
                alertRemainingMinutes: 5
            )
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
