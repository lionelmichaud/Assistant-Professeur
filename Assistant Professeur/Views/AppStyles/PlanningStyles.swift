//
//  PlanningStyles.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/10/2023.
//

import SwiftUI

let programPlanningStyle = PlanningStyle(
    minLineHeigth: 75,
    lineWidth: 4,
    lineOffset: -10,
    currentDateLineColor: .primary,
    currentDateLineWidth: 1,
    vacanceColor: .gray,
    plotAreaColor: Color.blue8.opacity(0.15)
)

struct PlanningStyle {
    var minLineHeigth: Int = 75
    var lineWidth: CGFloat = 4
    var lineOffset: CGFloat = -10

    var currentDateLineColor: Color = .primary
    var currentDateLineWidth: Double = 1.0

    var classeDateLineColor: Color = .red
    var classeDateLineWidth: Double = 0.75

    var vacanceColor: Color = .gray

    var plotAreaColor: Color = .blue
}
