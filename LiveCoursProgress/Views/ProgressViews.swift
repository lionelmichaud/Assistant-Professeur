//
//  ProgressBar.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI
struct TimeOverSymbol : View {
    var body: some View {
        Image(systemName: "clock.badge.exclamationmark.fill")
            .symbolRenderingMode(.multicolor)
        //Image(systemName: "alarm.waves.left.and.right")
            //.foregroundStyle(.primary, .red)
            .imageScale(.large)

    }
}

struct ProgressBar: View {
    let value: Double
    let foreGroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let boxWidth = frame.width * value

            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.gray)

            RoundedRectangle(cornerRadius: 5)
                .frame(width: boxWidth)
                .foregroundStyle(foreGroundColor)
        }
    }
}

struct ProgressCircle: View {
    let elapsed: Double
    let remaining: Double
    let foreGroundColor: Color

    var body: some View {
        ProgressView(value: elapsed, total: elapsed+remaining) {
            Text("\(remaining.formatted(.number))")
                .bold()
                .contentTransition(.numericText(value: elapsed))
        }
        .progressViewStyle(.circular)
        .tint(foreGroundColor)
    }
}
