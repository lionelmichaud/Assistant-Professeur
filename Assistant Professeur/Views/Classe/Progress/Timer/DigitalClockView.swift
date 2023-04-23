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

    private var elapsedMinutes: Int {
        elapsedTime.minute ?? 0
    }

    private var elapsedSecondes: Int {
        elapsedTime.second ?? 0
    }

    private var counter: String {
        "\(elapsedMinutes):\(elapsedSecondes < 10 ? "0" : "")\(elapsedSecondes)"
    }

    private var remainingMinutes: Int {
        remainingTime.minute ?? 0
    }

    private var remainingSecondes: Int {
        remainingTime.second ?? 0
    }

    private var countDown: String {
        "\(remainingMinutes):\(remainingSecondes < 10 ? "0" : "")\(remainingSecondes)"
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Text(counter)
                .font(.system(size: 60, design: .monospaced))
                .fontWeight(.black)
            Text(countDown)
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
