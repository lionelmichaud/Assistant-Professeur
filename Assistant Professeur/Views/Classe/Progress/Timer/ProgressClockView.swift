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

    var body: some View {
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
            if let elapsedTime,
               let remainingTime {
                DigitalClockView(
                    elapsedTime: elapsedTime,
                    remainingTime: remainingTime,
                    color: color
                )
            }
        }
        .padding(lineWidth)
    }
}

struct ProgressClockView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressClockView(
            trimValue: 0.25,
            color: .green,
            elapsedTime: DateComponents(minute: 15),
            remainingTime: DateComponents(minute: 45)
        )
    }
}
