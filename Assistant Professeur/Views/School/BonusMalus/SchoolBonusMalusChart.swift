//
//  SchoolBonusMalusChart.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/09/2023.
//

import Charts
import SwiftUI

struct SchoolBonusMalusChart: View {
    @ObservedObject
    var school: SchoolEntity

    var rowHeight: CGFloat = 40

    var chartHeight: CGFloat {
        CGFloat(school.nbOfClasses) * rowHeight
    }

    ///    struct ClasseData: Identifiable {
    ///        var classe: String
    ///        var min: Int
    ///        var max: Int
    ///        var average: Double
    ///
    ///        var id: String { classe }
    ///    }
    ///
    ///    @State
    ///    private var data = [ClasseData]()
    ///
    var body: some View {
        Chart {
            // Statistiques de chaque classe
            ForEach(school.classesSortedByLevelNumber) { classe in
                BonusMalusMark(
                    stats: .init(
                        label: classe.displayString,
                        min: classe.minBonus,
                        max: classe.maxBonus,
                        average: classe.averageBonus
                    ),
                    barHeight: rowHeight / 2.0
                )
            }
            .offset(.init(width: 0, height: -rowHeight / 4.0))

            // Moyenne de l'établiseement
            RuleMark(x: .value(
                "Etablissement",
                school.averageBonus
            ))
            .foregroundStyle(.red)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 10)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.tertiary)
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                AxisValueLabel()
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.blue8.opacity(0.1))
        }
        .frame(minHeight: CGFloat(chartHeight))
    }
}

// MARK: - Construction des données du graphique

extension SchoolBonusMalusChart {
    /// Fabrication des données du graphique
    private func buidChartDatum() {}
}

// struct SchoolBonusMalusChart_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolBonusMalusChart()
//    }
// }
