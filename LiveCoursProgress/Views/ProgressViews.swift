//
//  ProgressBar.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI

struct ProgressBar: View {
    let level: Double
    let foreGroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let boxWidth = frame.width * level

            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.gray)

            RoundedRectangle(cornerRadius: 5)
                .frame(width: boxWidth)
                .foregroundStyle(foreGroundColor)
        }
    }
}

