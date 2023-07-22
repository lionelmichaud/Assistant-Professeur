//
//  ProgramPlanningView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import AppFoundation
import Charts
import SwiftUI

struct ProgramPlanningView: View {
    @ObservedObject
    var program: ProgramEntity

    @ObservedObject
    private var pref = UserPrefEntity.shared

    @State
    private var data = ProgramPlanningGraphData()

    private let lineWidth = CGFloat(4)
    private let lineOffset = CGFloat(-10)

    private var sequences: [SequenceEntity] {
        program.sequencesSortedByNumber
    }

    var body: some View {
        Chart {
            // élongation de l'année scolaire
            schoolYearMark

            // élongation des séquences pédagogiques
            ForEach(data.sequences) { sequence in
                sequenceMark(sequence: sequence)
            }
            RuleMark(x: .value("Aujourd'hui", Date.now))
                .foregroundStyle(.red)
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 0.75,
                        lineCap: .round,
                        dash: [10, 5]
                    )
                )
        }
        .chartForegroundStyleScale([
            SequenceData.Serie.activity: Color.sequenceTag,
            SequenceData.Serie.vacance: .gray
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) { value in
                if let date = value.as(Date.self) {
                    let month = Calendar.current.component(.month, from: date)
                    switch month {
                        case 1, 4, 7, 10:
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.abbreviated).year(.twoDigits))
                                    .foregroundColor(.primary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        default:
                            AxisGridLine()
                    }
                }
            }
//            AxisMarks(values: .stride(by: .weekOfYear, count: 1)) { value in
//                AxisGridLine()
//            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.blue8.opacity(0.1))
        }
        .padding()
        .dynamicTypeSize(.xxLarge)
        .onAppear {
            buidChartDatum()
        }
    }
}

// MARK: - Chart Content Items

extension ProgramPlanningView {
    /// Ligne de l'année scolaire
    private var schoolYearMark: some ChartContent {
        RuleMark(
            xStart: .value("Début", data.schoolYear.interval.start, unit: .month),
            xEnd: .value("Fin", data.schoolYear.interval.end, unit: .day),
            y: .value("Année Scolaire", "Année Scolaire")
        )
        .foregroundStyle(.green)
        // barre
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .offset(y: lineOffset)
        // date de début
        .annotation(position: .bottom, alignment: .leading) {
            Text(
                data.schoolYear.interval.start,
                format: .dateTime.day().month(.abbreviated).year(.twoDigits)
            )
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            Text(
                data.schoolYear.interval.end,
                format: .dateTime.day().month(.abbreviated).year(.twoDigits)
            )
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
    }

    /// Ligne d'une séquence
    private func sequenceMark(sequence: SequenceData) -> some ChartContent {
        RuleMark(
            xStart: .value("Début", sequence.dateInterval.start, unit: .day),
            xEnd: .value("Fin", sequence.dateInterval.end, unit: .day),
            y: .value("Séquence", sequence)
        )
        .foregroundStyle(by: .value("serie", sequence.serie))
        // barre
        .lineStyle(
            StrokeStyle(
                lineWidth: sequence.serie == .activity ? lineWidth * 2 : lineWidth,
                lineCap: sequence.serie == .activity ? .round : .butt
            )
        )
        .offset(y: -lineWidth / 2.0)
        // date de début
        .annotation(position: .top, alignment: .leading) {
            if sequence.isFirstInterval {
                Text(
                    sequence.dateInterval.start,
                    format: .dateTime.day().month(.abbreviated)
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            if sequence.isLastInterval {
                Text(
                    sequence.dateInterval.end,
                    format: .dateTime.day().month(.abbreviated)
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Construction des données du graphique

extension ProgramPlanningView {
    /// Fabrication des données du graphique
    private func buidChartDatum() {
        // Initialiser les données avec l'année et les vacances scolaires
        data = ProgramPlanningGraphData(schoolYear: pref.viewSchoolYearPref)

        // Calcul des périodes d'activité de chaque séquence du programme
        let programSequencesData = ProgramManager.getProgramActivitiesPeriods(
            program: program,
            schoolYear: data.schoolYear
        )
        data.sequences += programSequencesData

        // Calcul des périodes de vacance de chaque séquence du programme
        sequences.forEach { sequence in
            // Ajout des périodes de vacances de la Séquence
            data.schoolYear.vacances.forEach { vacance in
                data
                    .sequences
                    .append(
                        SequenceData(
                            name: sequence.viewName,
                            number: sequence.viewNumber,
                            serie: .vacance,
                            dateInterval: vacance.interval
                        )
                    )
            }
        }
    }
}

struct ProgramPlanningPDF: View {
    @ObservedObject
    var program: ProgramEntity

    let data: ProgramPlanningGraphData?
    
    @ObservedObject
    private var pref = UserPrefEntity.shared

    private let lineWidth = CGFloat(4)
    private let lineOffset = CGFloat(-10)

    private var sequences: [SequenceEntity] {
        program.sequencesSortedByNumber
    }

    var body: some View {
        if let data {
            Chart {
                // élongation de l'année scolaire
                schoolYearMark(data: data)

                // élongation des séquences pédagogiques
                ForEach(data.sequences) { sequence in
                    sequenceMark(sequence: sequence)
                }
                RuleMark(x: .value("Aujourd'hui", Date.now))
                    .foregroundStyle(.red)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 0.75,
                            lineCap: .round,
                            dash: [10, 5]
                        )
                    )
            }
            .chartForegroundStyleScale([
                SequenceData.Serie.activity: Color.sequenceTag,
                SequenceData.Serie.vacance: .gray
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { value in
                    if let date = value.as(Date.self) {
                        let month = Calendar.current.component(.month, from: date)
                        switch month {
                            case 1, 4, 7, 10:
                                AxisValueLabel {
                                    Text(date, format: .dateTime.month(.abbreviated).year(.twoDigits))
                                        .foregroundColor(.primary)
                                }
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            default:
                                AxisGridLine()
                        }
                    }
                }
                //            AxisMarks(values: .stride(by: .weekOfYear, count: 1)) { value in
                //                AxisGridLine()
                //            }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.blue8.opacity(0.1))
            }
            .padding()
            .dynamicTypeSize(.xxLarge)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Chart Content Items

extension ProgramPlanningPDF {
    /// Ligne de l'année scolaire
    private func schoolYearMark(data: ProgramPlanningGraphData) -> some ChartContent {
        RuleMark(
            xStart: .value("Début", data.schoolYear.interval.start, unit: .month),
            xEnd: .value("Fin", data.schoolYear.interval.end, unit: .day),
            y: .value("Année Scolaire", "Année Scolaire")
        )
        .foregroundStyle(.green)
        // barre
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .offset(y: lineOffset)
        // date de début
        .annotation(position: .bottom, alignment: .leading) {
            Text(
                data.schoolYear.interval.start,
                format: .dateTime.day().month(.abbreviated).year(.twoDigits)
            )
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            Text(
                data.schoolYear.interval.end,
                format: .dateTime.day().month(.abbreviated).year(.twoDigits)
            )
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
    }

    /// Ligne d'une séquence
    private func sequenceMark(sequence: SequenceData) -> some ChartContent {
        RuleMark(
            xStart: .value("Début", sequence.dateInterval.start, unit: .day),
            xEnd: .value("Fin", sequence.dateInterval.end, unit: .day),
            y: .value("Séquence", sequence)
        )
        .foregroundStyle(by: .value("serie", sequence.serie))
        // barre
        .lineStyle(
            StrokeStyle(
                lineWidth: sequence.serie == .activity ? lineWidth * 2 : lineWidth,
                lineCap: sequence.serie == .activity ? .round : .butt
            )
        )
        .offset(y: -lineWidth / 2.0)
        // date de début
        .annotation(position: .top, alignment: .leading) {
            if sequence.isFirstInterval {
                Text(
                    sequence.dateInterval.start,
                    format: .dateTime.day().month(.abbreviated)
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            if sequence.isLastInterval {
                Text(
                    sequence.dateInterval.end,
                    format: .dateTime.day().month(.abbreviated)
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
    }
}

// struct ProgramPlanningView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramPlanningView()
//    }
// }
