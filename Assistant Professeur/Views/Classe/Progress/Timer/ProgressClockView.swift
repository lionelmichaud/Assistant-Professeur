//
//  ProgressClockView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/04/2023.
//

import SwiftUI

struct ProgressClockView: View {
    var trimValue: Double
    var color: Color
    var elapsedTime: DateComponents?
    var remainingTime: DateComponents?
    var lineWidth: Double = 40.0

    @Binding
    var warningNotif: Bool

    @Binding
    var alertNotif: Bool

    private let impactFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        ZStack {
            // le fond
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .fill(Color.clear)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.secondary,
                                    lineWidth: lineWidth
                                )
                        )

                    // le bouton d'activation de la notification de warning
                    Button {
                        warningNotif.toggle()
                        impactFeedback.selectionChanged()
                    } label: {
                        Image(systemName: warningNotif ? "timer.circle.fill" : "timer.circle")
                            .font(.system(size: 50))
                            .foregroundColor(TimerZone.warning.color)
                            .offset(x: -30, y: 30)
                    }
                }

                // le bouton d'activation de la notification d'alerte
                Button {
                    alertNotif.toggle()
                    impactFeedback.selectionChanged()
                } label: {
                    Image(systemName: alertNotif ? "timer.circle.fill" : "timer.circle")
                        .font(.system(size: 50))
                        .foregroundColor(TimerZone.alert.color)
                        .offset(x: 30, y: 30)
                }
            }

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
            if let elapsedTime,
               let remainingTime {
                VStack {
                    Text("minutes")
                    DigitalClockView(
                        elapsedTime: elapsedTime,
                        remainingTime: remainingTime,
                        color: color
                    )
                }
            }
        }
    }
}

struct ProgressClockView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressClockView(
            trimValue: 0.25,
            color: .green,
            elapsedTime: DateComponents(minute: 15),
            remainingTime: DateComponents(minute: 45),
            warningNotif: .constant(true),
            alertNotif: .constant(true)
        )
    }
}
