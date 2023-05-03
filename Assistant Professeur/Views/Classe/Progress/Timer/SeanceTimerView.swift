//
//  ActivityTimerView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/04/2023.
//

import HelpersView
import SwiftUI

struct SeanceTimerView: View {
    @Binding
    var warningRemainingMinutes: Int

    @Binding
    var alertRemainingMinutes: Int

    var lineWidth: Double = 40.0
    var test: Bool = false

    // MARK: - Internal Types

    enum TimerColors {
        case normal, warning, alert
        var color: Color {
            switch self {
                case .normal:
                    return .green
                case .warning:
                    return .orange
                case .alert:
                    return .red
            }
        }
    }

    // MARK: - Private Properties

    private let period = TimeInterval(2)

    private let notificationFeddback = UINotificationFeedbackGenerator()

    @State
    private var warningNotif = true

    @State
    private var alertNotif = true

    // MARK: - Computed Properties

    private var warningString: String {
        if warningRemainingMinutes == 0 {
            return "-"
        } else {
            return "-\(warningRemainingMinutes) minutes"
        }
    }

    private var alertString: String {
        if alertRemainingMinutes == 0 {
            return "-"
        } else {
            return "-\(alertRemainingMinutes) minutes"
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: period)) { timeLine in
            if let seance = seanceOngoing(at: timeLine.date) {
                VStack {
                    // heure de fin de la séance de travail
                    Text("Fin de la séance à **\(seance.end.formatted(date: .omitted, time: .shortened))**")
                        .font(.title)

                    ProgressClockView(
                        trimValue: cursorValue(for: timeLine.date)!,
                        color: cursorColor(for: timeLine.date),
                        elapsedTime: elapsedTime(for: timeLine.date),
                        remainingTime: remainingTime(for: timeLine.date),
                        warningNotif: $warningNotif,
                        alertNotif: $alertNotif
                    )

                    // seuils d'alerte
                    VStack {
                        Stepper(
                            value: $warningRemainingMinutes,
                            in: 1 ... 30,
                            step: 1
                        ) {
                            Text("Alerte: ")
                                .foregroundColor(TimerColors.warning.color)
                                + Text(warningString)
                        }
                        .padding(.horizontal)

                        Stepper(
                            value: $alertRemainingMinutes,
                            in: 1 ... 15,
                            step: 1
                        ) {
                            Text("Alarme: ")
                                .foregroundColor(TimerColors.alert.color)
                                + Text(alertString)
                        }.padding(.horizontal)
                    }
                    .font(.system(size: 25))
                    .fontWeight(.heavy)
                    .frame(maxWidth: 400)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.3))
                    )
                    .padding(.horizontal, 4)
                }

            } else {
                Text("Pas de séance en cours")
                    .font(.title)
            }
        }
    }

    // MARK: - Methods

    /// Retourne la séance en cours à la date
    private func seanceOngoing(at date: Date) -> DateInterval? {
        #if DEBUG
            if test {
                let hourStart = (date.minutes).minutes.before(date)!
                return DateInterval(start: hourStart, duration: 3600)
            }
        #endif

        return AgendaManager.shared.seanceOngoing(at: date)
    }

    /// Temps écoulé depuis le début de la séance
    private func elapsedTime(for date: Date) -> DateComponents? {
        #if DEBUG
            if test {
                return DateComponents(minute: date.minutes, second: date.seconds)
            }
        #endif

        return AgendaManager.shared.elapsedTime(to: date)
    }

    /// Temps restant avant le début de la séance
    private func remainingTime(for date: Date) -> DateComponents? {
        #if DEBUG
            if test {
                return DateComponents(minute: 60 - date.minutes, second: 60 - date.seconds)
            }
        #endif

        return AgendaManager.shared.remainingTime(from: date)
    }

    /// Position du curseur
    private func cursorValue(for date: Date) -> Double? {
        #if DEBUG
            if test {
                return date.minutes.double() / 60.0
            }
        #endif

        if let elapsedMinutes = AgendaManager.shared.elapsedMinutes(to: date)?.double(),
           let seanceDuration = AgendaManager.shared.seanceDuration().minute?.double() {
            return (elapsedMinutes / seanceDuration)
        } else {
            return nil
        }
    }

    /// Couleur du curseur
    private func cursorColor(for date: Date) -> Color {
        guard let remaingMinutes = remainingTime(for: date)?.minute else {
            return TimerColors.normal.color
        }
        if remaingMinutes < alertRemainingMinutes {
            if alertRemainingMinutes <= remaingMinutes + 1 && alertNotif {
                notificationFeddback.notificationOccurred(.error)
            }
            return TimerColors.alert.color
        }
        if remaingMinutes < warningRemainingMinutes {
            if warningRemainingMinutes <= remaingMinutes + 1 && warningNotif {
                notificationFeddback.notificationOccurred(.warning)
            }
            return TimerColors.warning.color
        }
        return .green
    }
}

// MARK: - Previews

struct SeanceTimerView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SeanceTimerView(
                warningRemainingMinutes: .constant(30),
                alertRemainingMinutes: .constant(15),
                lineWidth: 40,
                test: true
            )
            .previewDevice("iPad mini (6th generation)")
            SeanceTimerView(
                warningRemainingMinutes: .constant(30),
                alertRemainingMinutes: .constant(15),
                lineWidth: 40,
                test: true
            )
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
