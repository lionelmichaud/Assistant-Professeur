//
//  ProgramPlanningView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import AppFoundation
import Charts
import SwiftUI

/// Données nécessaires au Graph du Planning annuel des séquences pédagogiques
struct ProgramPlanningGraphData {
    // MARK: - Types

    enum Serie: String {
        case activity = "Activité"
        case vacance = "Vacance"

        var plotableValue: String {
            rawValue
        }
    }

    /// Intervalle d'activité d'une séquence
    struct SequenceData: Identifiable {
        var name: String = ""
        var number: Int = 1
        var serie = Serie.activity
        var dateInterval = DateInterval()

        var id: Int { number }
    }

    // MARK: - Properties

    var schoolYear = SchoolYearPref()
    var sequences = [SequenceData]()

    // MARK: - Initilizers

    init() {}

    init(schoolYear: SchoolYearPref) {
        self.schoolYear = schoolYear
    }
}

struct ProgramPlanningView: View {
    @ObservedObject
    var program: ProgramEntity

    @EnvironmentObject
    private var pref: UserPreferences

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
        }
        .chartForegroundStyleScale([
            ProgramPlanningGraphData.Serie.activity.rawValue: .blue,
            ProgramPlanningGraphData.Serie.vacance.rawValue: .gray
        ])
        .padding(.horizontal)
        .dynamicTypeSize(.xxLarge)
        .task {
            buidChartDatum()
        }
    }
}

// MARK: - Chart Content Items

extension ProgramPlanningView {
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
            Text(data.schoolYear.interval.start.formatted(date: .numeric, time: .omitted))
                .dynamicTypeSize(.small)
                .foregroundColor(.secondary)
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            Text(data.schoolYear.interval.end.formatted(date: .numeric, time: .omitted))
                .dynamicTypeSize(.small)
                .foregroundColor(.secondary)
        }
    }

    private func sequenceMark(sequence: ProgramPlanningGraphData.SequenceData) -> some ChartContent {
        RuleMark(
            xStart: .value("Début", sequence.dateInterval.start, unit: .day),
            xEnd: .value("Fin", sequence.dateInterval.end, unit: .day),
            y: .value("Séquence", "S\(sequence.number) \(sequence.name)")
        )
        .foregroundStyle(by: .value("serie", sequence.serie.plotableValue))
        // barre
        .lineStyle(
            StrokeStyle(lineWidth: sequence.serie == .activity ? lineWidth * 2 : lineWidth)
        )
        .offset(y: -lineWidth / 2.0)
        // date de début
//        .annotation(position: .top, alignment: .leading) {
//            if sequence.id == data.sequences.first!.id {
//                Text(sequence.dateInterval.start.formatted(date: .numeric, time: .omitted))
//                    .dynamicTypeSize(.small)
//                    .foregroundColor(.secondary)
//            }
//        }
        // date de fin
//        .annotation(position: .bottom, alignment: .trailing) {
//            if sequence.id == data.sequences.last!.id {
//                Text(sequence.dateInterval.end.formatted(date: .numeric, time: .omitted))
//                    .dynamicTypeSize(.small)
//                    .foregroundColor(.secondary)
//            }
//        }
    }
}

// MARK: - Construction des données du graphique

extension ProgramPlanningView {
    /// élongation de l'année scolaire
    private func buidChartDatum() {
        // Initialiser les données avec l'année et les vacances scolaires
        data = ProgramPlanningGraphData(schoolYear: pref.schoolYear)

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
                        ProgramPlanningGraphData.SequenceData(
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

// struct ProgramPlanningView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramPlanningView()
//    }
// }
