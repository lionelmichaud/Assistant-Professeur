//
//  BonusMalusMark.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/09/2023.
//

import Charts
import Foundation
import SwiftUI

struct BonusMalusMark: ChartContent {
    private let stats: BonusMalusStats
    private let label: PlottableValue<String>
    private let min: PlottableValue<Int>
    private let max: PlottableValue<Int>
    private let average: PlottableValue<Double>
    private var barHeight: CGFloat = 20.0

    // MARK: - Initializer

    init(
        stats: BonusMalusStats,
        barHeight: CGFloat = 20.0
    ) {
        self.stats = stats
        self.label = .value("élement", stats.label)
        self.min = .value("minimum", stats.min)
        self.max = .value("maximum", stats.max)
        self.average = .value("moyenne", stats.average)
        self.barHeight = barHeight
    }

    var body: some ChartContent {
        // Intervalle Min-Max
        RectangleMark(
            xStart: min,
            xEnd: max,
            y: label,
            height: MarkDimension(floatLiteral: barHeight)
        )
        .cornerRadius(barHeight / 2.0)
        .opacity(0.5)
        .annotation(position: .leading, alignment: .trailing) {
            Text(stats.min,format: .number)
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
        .annotation(position: .trailing, alignment: .leading) {
            Text(stats.max,format: .number)
                .dynamicTypeSize(.small)
                .foregroundColor(.secondary)
        }

        // Moyenne
        PointMark(
            x: average,
            y: label
        )
        .symbol(.circle)
        .symbolSize(CGSize(width: barHeight, height: barHeight))
        .foregroundStyle(.red)
    }
}
