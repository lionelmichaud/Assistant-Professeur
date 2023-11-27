//
//  ProgramPlanningView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import AppFoundation
import Charts
import EventKit
import SwiftUI

struct ProgramPlanningView: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(UserContext.self)
    private var userContext

    @State
    private var data = ProgramPlanningGraphData()

    @State
    private var showClasses = false

    @State
    private var eventStore = EKEventStore()

    @State
    private var calendar: EKCalendar?

    @State
    private var alertTitle = ""
    @State
    private var alertMessage = ""
    @State
    private var alertIsPresented = false

    @State
    private var dateBrevet: Date?
    @State
    private var dateBac: Date?

    @State
    private var classesOffsets = [String: CGFloat]()

    private let horizon = 3 // mois

    // MARK: - Computed Properties

    private var sequences: [SequenceEntity] {
        program.sequencesSortedByNumber
    }

    private var nbLines: Int {
        sequences.count + 1
    }

    private func nbVisibleLines(visiblePlotHeigth: CGFloat) -> Int {
        min(
            Int(visiblePlotHeigth) / programPlanningStyle.minLineHeigth,
            nbLines
        )
    }

    private func offset(classeName: String) -> CGFloat {
        if let s = classeName.substring(
            start: classeName.count - 1,
            offsetBy: 1
        ),
            let i = Int(s) {
            return CGFloat(i * 10)
        } else {
            return 0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Chart {
                // élongation de l'année scolaire
                if data.schoolYear != nil {
                    schoolYearMark
                }

                // élongation des séquences pédagogiques
                ForEach(data.sequences) { sequence in
                    sequenceMark(sequence: sequence)
                }

                // Dates d'avancement réel de chacune des classes
                if showClasses {
                    ForEach(Array(data.datesClasses.keys), id: \.self) { classeName in
                        RuleMark(x: .value(classeName, data.datesClasses[classeName]!))
                            .foregroundStyle(programPlanningStyle.classeDateLineColor)
                            .lineStyle(
                                StrokeStyle(
                                    lineWidth: programPlanningStyle.classeDateLineWidth,
                                    lineCap: .round,
                                    dash: [10, 5]
                                )
                            )
                            .annotation(
                                position: .top,
                                alignment: .leading,
                                spacing: nil,
                                overflowResolution: .init(x: .fit, y: .fit)
                            ) {
                                Text(classeName)
                                    .font(.footnote)
                                    .bold()
                                    .offset(y: classesOffsets[classeName] ?? CGFloat(0))
                            }
                    }
                }

                // date de début des épreuvent du brevet
                if program.levelEnum == .n3ieme, let dateBrevet {
                    RuleMark(x: .value("Brevet", dateBrevet))
                        .foregroundStyle(programPlanningStyle.examLineColor)
                        .lineStyle(
                            StrokeStyle(
                                lineWidth: programPlanningStyle.examLineWidth,
                                lineCap: .round
                            )
                        )
                        .annotation(
                            position: .top,
                            alignment: .trailing,
                            spacing: nil,
                            overflowResolution: .init(x: .fit, y: .fit)
                        ) {
                            Text("Brevet ")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(programPlanningStyle.examLineColor)
                        }

                } else if program.levelEnum == .n0terminale, let dateBac {
                    RuleMark(x: .value("Baccalauréat", dateBac))
                        .foregroundStyle(programPlanningStyle.examLineColor)
                        .lineStyle(
                            StrokeStyle(
                                lineWidth: programPlanningStyle.examLineWidth,
                                lineCap: .round
                            )
                        )
                        .annotation(
                            position: .top,
                            alignment: .trailing,
                            spacing: nil,
                            overflowResolution: .init(x: .fit, y: .fit)
                        ) {
                            Text("Baccalauréat ")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(programPlanningStyle.examLineColor)
                        }
                }

                // date courante
                RuleMark(x: .value("Aujourd'hui", Date.now))
                    .foregroundStyle(programPlanningStyle.currentDateLineColor)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: programPlanningStyle.currentDateLineWidth,
                            lineCap: .round
                        )
                    )
            }
            .chartScrollableAxes(.vertical)
            .chartYVisibleDomain(length: nbVisibleLines(visiblePlotHeigth: geometry.size.height))
            .chartScrollTargetBehavior(
                .valueAligned(
                    unit: 1,
                    majorAlignment: .unit(3)
                )
            )
            .chartForegroundStyleScale([
                SequenceData.Serie.activity: Color.sequenceTag,
                SequenceData.Serie.vacance: programPlanningStyle.vacanceColor
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { value in
                    if let date = value.as(Date.self) {
                        let month = Calendar.current.component(.month, from: date)
                        switch month {
                            case 1, 4, 7, 10:
                                AxisValueLabel {
                                    Text(date, format: .dateTime.month(.abbreviated).year(.twoDigits))
                                        .font(.callout)
                                        .foregroundColor(.primary)
                                }
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            default:
                                AxisGridLine()
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                        .font(.subheadline)
                        .foregroundStyle(Color.sequenceTag)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(programPlanningStyle.plotAreaColor)
            }
            .padding()
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {},
                message: { Text(alertMessage) }
            )
            .task {
                await ProgramEntity.context.perform {
                    data = ProgramPlanningGraphData(
                        forProgram: program,
                        schoolYear: userContext.prefs.viewSchoolYearPref
                    )
                }

                // Calcul des dates d'avancement réel de chacune des classes
                let classes = ProgramManager.classesAssociatedTo(thisProgram: program)
                for classe in classes {
                    // Liste des Séances à venir pour cette classe
                    guard let schoolName = classe.school?.viewName else {
                        continue
                    }

                    // Demander les droits d'accès aux calendriers de l'utilisateur
                    (
                        calendar,
                        alertIsPresented,
                        alertTitle,
                        alertMessage
                    ) = await EventManager.shared
                        .requestCalendarAccess(
                            eventStore: eventStore,
                            calendarName: schoolName
                        )
                    guard let calendar else {
                        continue
                    }

                    var plannedDate: Date?
                    await ClasseEntity.context.perform {
                        let schoolYear = userContext.prefs.viewSchoolYearPref
                        var classeSeances: SeancesInDateInterval = .init()

                        let horizon = DateInterval(
                            start: schoolYear.interval.start,
                            end: horizon.months.fromNow!
                        )

                        // Liste des Séances à venir pour cette classe
                        classeSeances.loadClasseSeancesFromCalendar(
                            forDiscipline: classe.disciplineEnum,
                            forSchoolName: schoolName,
                            forClasseName: classe.displayString,
                            inCalendar: calendar,
                            inEventStore: eventStore,
                            during: horizon,
                            schoolYear: schoolYear
                        )

                        // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                        let sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber

                        // Calculer la date à laquelle l'activité en cours aurait due survenir
                        plannedDate = SequenceSeanceCoordinator
                            .plannedDateOfCurrentActivity(
                                inProgram: program,
                                classeProgresses: sortedClasseProgresses,
                                yearSeances: classeSeances
                            )
                    }
                    if let plannedDate {
                        data.datesClasses[classe.displayString] = plannedDate
                    }
                }

                // Calcul des offsets des libellés de dates d'avancement actuelle de chaque classe
                data.datesClasses.keys.forEach { name in
                    if let s = name.substring(
                        start: name.count - 1,
                        offsetBy: 1
                    ), let i = Int(s) {
                        classesOffsets[name] = CGFloat(i * 10)
                    } else {
                        classesOffsets[name] = 0
                    }
                }
                if let min = classesOffsets.values.min() {
                    classesOffsets.keys.forEach { name in
                        if classesOffsets[name] != nil {
                            classesOffsets[name] = classesOffsets[name]! - min
                        }
                    }
                }
            }
            .toolbar {
                if calendar != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Toggle(isOn: $showClasses) {
                            Image(systemName: showClasses ? EleveEntity.defaultImageName + ".fill" : EleveEntity.defaultImageName)
                        }
                        .controlSize(.mini)
                        .toggleStyle(.button)
                    }
                }
            }
        }
        .task {
            await getDatesBrevetBac(during: userContext.prefs.viewSchoolYearPref)
        }
    }

    private func getDatesBrevetBac(during schoolYear: SchoolYearPref) async {
        if program.levelEnum == .n3ieme || program.levelEnum == .n0terminale {
            // Demander les droits d'accès aux calendriers de l'utilisateur
            var alert = AlertInfo()
            var schoolYearcalendar: EKCalendar?
            (
                schoolYearcalendar,
                alert.isPresented,
                alert.title,
                alert.message
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: schoolYear.calName
                )
            guard let schoolYearcalendar else {
                return
            }

            if program.levelEnum == .n3ieme {
                // Récupérer les dates du brevet des collèges
                dateBrevet = EventManager.getBrevet(
                    inCalendar: schoolYearcalendar,
                    inEventStore: eventStore,
                    during: schoolYear.interval
                )?.startDate

            } else if program.levelEnum == .n0terminale {
                // Récupérer les dates du baccalauréat
                dateBac = EventManager.getBac(
                    inCalendar: schoolYearcalendar,
                    inEventStore: eventStore,
                    during: schoolYear.interval
                )?.startDate
            }
        }
    }
}

// MARK: - Chart Content Items

extension ProgramPlanningView {
    // MARK: - Methods

    @ViewBuilder
    private func dateLabel(date: Date) -> Text {
        Text(
            date,
            format: .dateTime.day().month(.abbreviated) // .year(.twoDigits)
        )
        .font(.footnote)
        .foregroundColor(.secondary)
    }

    /// Ligne de l'année scolaire
    private var schoolYearMark: some ChartContent {
        // barre
        RuleMark(
            xStart: .value("Début", data.schoolYear!.interval.start, unit: .month),
            xEnd: .value("Fin", data.schoolYear!.interval.end, unit: .day),
            y: .value("Année Scolaire", "Année Scolaire")
        )
        .foregroundStyle(.green)
        .lineStyle(StrokeStyle(lineWidth: programPlanningStyle.lineWidth))
        .offset(y: programPlanningStyle.lineOffset)

        // date de début
        .annotation(position: .bottom, alignment: .leading) {
            dateLabel(date: data.schoolYear!.interval.start)
        }

        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            dateLabel(date: data.schoolYear!.interval.end)
        }
    }

    /// Ligne d'une séquence
    private func sequenceMark(sequence: SequenceData) -> some ChartContent {
        // barre
        RuleMark(
            xStart: .value("Début", sequence.dateInterval.start, unit: .day),
            xEnd: .value("Fin", sequence.dateInterval.end, unit: .day),
            y: .value("Séquence", sequence)
        )
        .foregroundStyle(by: .value("serie", sequence.serie))
        .lineStyle(
            StrokeStyle(
                lineWidth: sequence.serie == .activity ?
                    programPlanningStyle.lineWidth * 2 :
                    programPlanningStyle.lineWidth,
                lineCap: sequence.serie == .activity ? .round : .butt
            )
        )
        .offset(y: -programPlanningStyle.lineWidth / 3.0)

        // date de début
        .annotation(position: .top, alignment: .leading) {
            if sequence.isFirstInterval {
                dateLabel(date: sequence.dateInterval.start)
            }
        }

        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            if sequence.isLastInterval {
                dateLabel(date: sequence.dateInterval.end)
            }
        }
    }
}

// MARK: - Construction des données du graphique

struct ProgramPlanningPDF: View {
    @ObservedObject
    var program: ProgramEntity

    let data: ProgramPlanningGraphData?

    private let lineWidth = CGFloat(4)
    private let lineOffset = CGFloat(-10)

    private var sequences: [SequenceEntity] {
        program.sequencesSortedByNumber
    }

    var body: some View {
        if let data {
            Chart {
                // élongation de l'année scolaire
                if data.schoolYear != nil {
                    schoolYearMark(data: data)
                }

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
            xStart: .value("Début", data.schoolYear!.interval.start, unit: .month),
            xEnd: .value("Fin", data.schoolYear!.interval.end, unit: .day),
            y: .value("Année Scolaire", "Année Scolaire")
        )
        .foregroundStyle(.green)
        // barre
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .offset(y: lineOffset)
        // date de début
        .annotation(position: .bottom, alignment: .leading) {
            Text(
                data.schoolYear!.interval.start,
                format: .dateTime.day().month(.abbreviated).year(.twoDigits)
            )
            .dynamicTypeSize(.small)
            .foregroundColor(.secondary)
        }
        // date de fin
        .annotation(position: .bottom, alignment: .trailing) {
            Text(
                data.schoolYear!.interval.end,
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
