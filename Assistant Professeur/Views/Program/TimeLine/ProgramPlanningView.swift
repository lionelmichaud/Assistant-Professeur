//
//  ProgramPlanningView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import AppFoundation
import Charts
import SwiftUI

struct PlanningData {
    enum Serie: String {
        case activity = "Activité"
        case vacance = "Vacance"

        var plotableValue: String {
            rawValue
        }
    }

    struct SequenceData: Identifiable {
        var name: String = ""
        var number: Int = 1
        var serie = Serie.activity
        var dateInterval = DateInterval()

        var id: Int { number }
    }

    var schoolYear = SchoolYearPref()
    var sequences = [SequenceData]()
}

struct ProgramPlanningView: View {
    @ObservedObject
    var program: ProgramEntity

    @EnvironmentObject
    private var pref: UserPreferences

    @State
    private var data = PlanningData()

    var sequences: [SequenceEntity] {
        program.sequencesSortedByNumber
    }

    var body: some View {
        Chart {
            BarMark(
                xStart: .value("Début", data.schoolYear.interval.start, unit: .month),
                xEnd: .value("Fin", data.schoolYear.interval.end, unit: .day),
                y: .value("Année Scolaire", "Année Scolaire")
            )
            .foregroundStyle(.green)
            ForEach(data.sequences) { sequence in
                BarMark(
                    xStart: .value("Début", sequence.dateInterval.start, unit: .day),
                    xEnd: .value("Fin", sequence.dateInterval.end, unit: .day),
                    y: .value("Séquence", "S\(sequence.number) \(sequence.name)")
                )
                .foregroundStyle(by: .value("serie", sequence.serie.plotableValue))
//                RuleMark(
//                    xStart: .value("Début", sequence.viewNumber),
//                    xEnd: .value("Fin", sequence.viewNumber + 1),
//                    y: .value("Séquence", sequence.viewName)
//                )
//                .foregroundStyle(.green)
//                RuleMark(
//                    xStart: .value("Début", sequence.viewNumber+1),
//                    xEnd: .value("Fin", sequence.viewNumber + 2),
//                    y: .value("Séquence", sequence.viewName)
//                )
//                .foregroundStyle(.red)
            }
        }
        .chartForegroundStyleScale([
            PlanningData.Serie.activity.rawValue: .blue,
            PlanningData.Serie.vacance.rawValue: .gray
        ])
        .padding(.horizontal)
        .dynamicTypeSize(.xxxLarge)
        .task {
            buidChartDatum()
        }
    }
}

// MARK: - Construction des données du graphique

extension ProgramPlanningView {
    private func buidChartDatum() {
        // Année et vacances scolaires
        data.schoolYear = pref.schoolYear

        // Calcul des périodes d'activité de chaque séquence du programme
        var programSequencesData = ProgramManager.getProgramActivitiesPeriods(
            program: program,
            schoolYear: data.schoolYear
        )
        data.sequences += programSequencesData

        // Calcul des périodes de vacance de chaque séquence du programme
        sequences.forEach { sequence in
            // Ajout des périodes de vacances de la Séquence
            data
                .sequences
                .append(
                    PlanningData.SequenceData(
                        name: sequence.viewName,
                        number: sequence.viewNumber,
                        serie: .vacance,
                        dateInterval: data.schoolYear.autumnVacation
                    )
                )
            data
                .sequences
                .append(
                    PlanningData.SequenceData(
                        name: sequence.viewName,
                        number: sequence.viewNumber,
                        serie: .vacance,
                        dateInterval: data.schoolYear.noelVacation
                    )
                )
            data
                .sequences
                .append(
                    PlanningData.SequenceData(
                        name: sequence.viewName,
                        number: sequence.viewNumber,
                        serie: .vacance,
                        dateInterval: data.schoolYear.winterVacation
                    )
                )
            data
                .sequences
                .append(
                    PlanningData.SequenceData(
                        name: sequence.viewName,
                        number: sequence.viewNumber,
                        serie: .vacance,
                        dateInterval: data.schoolYear.paqueVacation
                    )
                )
        }
    }
}

// struct ProgramPlanningView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramPlanningView()
//    }
// }
