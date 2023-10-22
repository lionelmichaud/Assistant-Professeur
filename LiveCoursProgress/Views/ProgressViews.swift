//
//  ProgressBar.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI

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
    let value: Double
    let total: Double
    let foreGroundColor: Color

    var body: some View {
        ProgressView(value: value, total: total) {
            Text("\(value.formatted(.number))")
                .bold()
                .contentTransition(.numericText(value: value))
        }
        .progressViewStyle(.circular)
        .tint(foreGroundColor)
    }
}

#Preview {
    ProgressBar(
        value: 0.75,
        foreGroundColor: .red
    )
}

#Preview {
    ProgressCircle(
        value: 25,
        total: 100,
        foreGroundColor: .red
    )
}
