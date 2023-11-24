//
//  DigitalClockView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/04/2023.
//

import SwiftUI

struct DigitalClockView: View {
    var elapsedTime: DateComponents
    var remainingTime: DateComponents
    var color: Color = .primary

    private var elapsedHour: String {
        let hours = elapsedTime.hour ?? 0
        if hours == 0 {
            return ""
        } else {
            return "\(hours):"
        }
    }

    // Temps échu
    private var elapsedMinutes: String {
        let minutes = elapsedTime.minute ?? 0
        return "\(minutes < 10 ? "0" : "")\(minutes):"
    }

    private var elapsedSecondes: String {
        let seconds = elapsedTime.second ?? 0
        return "\(seconds < 10 ? "0" : "")\(seconds)"
    }

    private var elapsedCounter: String {
        elapsedHour + elapsedMinutes + elapsedSecondes
    }

    // Temps restant
    private var remainingHours: String {
        let hours = remainingTime.hour ?? 0
        if hours == 0 {
            return ""
        } else {
            return "\(hours):"
        }
    }

    private var remainingMinutes: String {
        let minutes = remainingTime.minute ?? 0
        return "\(minutes < 10 ? "0" : "")\(minutes):"
    }

    private var remainingSecondes: String {
        let seconds = max(0, (remainingTime.second ?? 0))
        return "\(seconds < 10 ? "0" : "")\(seconds)"
    }

    private var remainingCounter: String {
        remainingHours + remainingMinutes + remainingSecondes
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Text(elapsedCounter)
                .font(.system(size: 60, design: .monospaced))
                .fontWeight(.black)
            Text(remainingCounter)
                .font(.system(size: 60, design: .monospaced))
                .fontWeight(.black)
                .foregroundColor(color)
        }
    }
}

struct DigitalClockView_Previews: PreviewProvider {
    static var previews: some View {
        DigitalClockView(
            elapsedTime: DateComponents(minute: 45, second: 05),
            remainingTime: DateComponents(minute: 4, second: 38)
        )
    }
}
