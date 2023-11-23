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

struct LiveActivityProgressBar : View {
    let remainingMinutes: Int?
    let elapsedMinutes: Int?
    let isStale: Bool
    let progressColor: Color

    var body: some View {
        if let remainingMinutes,
           let elapsedMinutes {
            if remainingMinutes <= 0 {
                // Cours terminé
                Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                    .padding(4)
                    .background(ContainerRelativeShape().fill(Color.red))
                    .padding(.bottom)

            } else {
                // Cours en cours
                HStack(alignment: .center) {
                    ProgressBar(
                        value: Double(remainingMinutes) / Double(elapsedMinutes + remainingMinutes),
                        foreGroundColor: isStale ? .gray : progressColor
                    )
                    Text("\(remainingMinutes) min")
                        .foregroundStyle(
                            isStale ? .gray : progressColor
                        )
                        .bold()
                        .contentTransition(.numericText(value: Double(remainingMinutes)))
                }
                .frame(height: 10)
                .padding(.bottom)
            }
        } else {
            // Cours terminé
            Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                .padding(4)
                .background(ContainerRelativeShape().fill(Color.red))
                .padding(.bottom)
        }
    }
}

struct ProgressBar: View {
    let value: Double
    let foreGroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let boxWidth = frame.width * value

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color.gray)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: boxWidth)
                    .foregroundStyle(foreGroundColor)
            }
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
