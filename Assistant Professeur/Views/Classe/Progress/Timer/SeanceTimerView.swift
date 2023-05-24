//
//  ActivityTimerView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/04/2023.
//

import AppFoundation
import AVFoundation
import HelpersView
import SwiftUI

struct SeanceTimerView: View {
    var discipline: Discipline
    var classeName : String
    var schoolName: String
    var lineWidth: Double = 40.0
    var test: Bool = false

    // MARK: - Internal Types

    enum TimerZone {
        case normal, warning, alert
        var color: Color {
            switch self {
                case .normal: return .green
                case .warning: return .orange
                case .alert: return .red
            }
        }
    }

    // MARK: - Type Properties

    static let dingPlayer: AVPlayer = AVPlayer.soundPlayer(sound: "ding")
    static let bellPlayer: AVPlayer = AVPlayer.soundPlayer(sound: "bell")

    // MARK: - Type Methods

    static func playDingSound() {
        dingPlayer.seek(to: .zero)
        dingPlayer.play()
    }

    static func playBellSound() {
        bellPlayer.seek(to: .zero)
        bellPlayer.play()
    }

    // MARK: - Private Properties

    @SceneStorage("warningRemainingMinutes")
    private var warningRemainingMinutes: Int = 10

    @SceneStorage("alertRemainingMinutes")
    private var alertRemainingMinutes: Int = 5

    @SceneStorage("warningAlarmIsActivited")
    private var warningAlarmIsActivited = true

    @SceneStorage("alertAlarmIsActivated")
    private var alertAlarmIsActivated = true

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var timerVM: TimerVM = .init()

    private let period = TimeInterval(2) // seconds

    private let notificationFeedback = UINotificationFeedbackGenerator()

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

    @ViewBuilder
    private func compactView(date: Date, seance: DateInterval) -> some View {
        VStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(seance.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: cursorValue(for: date)!,
                    color: timerZone(for: date).color,
                    elapsedTime: elapsedTime(for: date),
                    remainingTime: remainingTime(for: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth)
            }

            // seuils d'alerte
            reglageSeuilView
        }
    }

    @ViewBuilder
    private func regularView(date: Date, seance: DateInterval) -> some View {
        HStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(seance.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: cursorValue(for: date)!,
                    color: timerZone(for: date).color,
                    elapsedTime: elapsedTime(for: date),
                    remainingTime: remainingTime(for: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth / 2)
            }

            VStack {
                // seuils d'alerte
                reglageSeuilView
            }
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: period)) { timeLine in
            if let seance = timerVM.seanceOngoing(at: timeLine.date) {
                ViewThatFits(in: .horizontal) {
                    regularView(date: timeLine.date, seance: seance)
                    compactView(date: timeLine.date, seance: seance)
                }

            } else {
                Text("Pas de séance en cours")
                    .font(.title)
            }
        }
        .task {
            /// Charge les heures de cours du jour
            await timerVM.loadTodaySeances(
                forDiscipline: discipline,
                forClasse: classeName,
                schoolName: schoolName
            )
        }
    }

    // MARK: - Methods

    /// Temps écoulé depuis le début de la séance
    private func elapsedTime(for date: Date) -> DateComponents? {
        #if DEBUG
            if test {
                return DateComponents(minute: date.minutes, second: date.seconds)
            }
        #endif

        return timerVM.elapsedTime(to: date)
    }

    /// Temps restant avant le début de la séance
    private func remainingTime(for date: Date) -> DateComponents? {
        #if DEBUG
            if test {
                return DateComponents(minute: 60 - date.minutes, second: 60 - date.seconds)
            }
        #endif

        return timerVM.remainingTime(from: date)
    }

    /// Position du curseur
    private func cursorValue(for date: Date) -> Double? {
        #if DEBUG
            if test {
                return date.minutes.double() / 60.0
            }
        #endif

        if let elapsedMinutes = timerVM.elapsedMinutes(to: date)?.double(),
           let seanceDuration = timerVM.seanceDuration()?.minute?.double() {
            return (elapsedMinutes / seanceDuration)
        } else {
            return nil
        }
    }

    private func timerZone(for date: Date) -> TimerZone {
        guard let remainingTime = remainingTime(for: date),
              let remainingMinutes = remainingTime.minute,
              let remainingSeconds = remainingTime.second else {
            return .normal
        }
        vibrate(remainingMinutes: remainingMinutes)
        playSound(
            remainingMinutes: remainingMinutes,
            remainingSeconds: remainingSeconds
        )

        switch remainingMinutes + 1 {
            case 0 ... alertRemainingMinutes:
                return .alert

            case alertRemainingMinutes ... warningRemainingMinutes:
                return .warning

            default:
                return .normal
        }
    }

    private func vibrate(remainingMinutes: Int) {
        let duration = 1
        switch remainingMinutes + 1 {
            case (alertRemainingMinutes - duration) ... alertRemainingMinutes:
                if alertAlarmIsActivated {
                    notificationFeedback.notificationOccurred(.error)
                }

            case (warningRemainingMinutes - duration) ... warningRemainingMinutes:
                if warningAlarmIsActivited {
                    notificationFeedback.notificationOccurred(.warning)
                }

            default:
                break
        }
    }

    private func playSound(
        remainingMinutes: Int,
        remainingSeconds _: Int
    ) {
        let duration = 1
        switch remainingMinutes + 1 {
            case (alertRemainingMinutes - duration) ... alertRemainingMinutes:
                if alertAlarmIsActivated {
                    SeanceTimerView.playBellSound()
                }

            case (warningRemainingMinutes - duration) ... warningRemainingMinutes:
                if warningAlarmIsActivited {
                    SeanceTimerView.playDingSound()
                }

            default:
                break
        }
    }
}

// MARK: - Subviews

extension SeanceTimerView {
    private var reglageSeuilView: some View {
        VStack {
            Stepper(
                value: $warningRemainingMinutes,
                in: alertRemainingMinutes ... 45,
                step: 1
            ) {
                Text("Alerte: ")
                    .foregroundColor(TimerZone.warning.color)
                    + Text(warningString)
            }
            .padding(.horizontal)

            Stepper(
                value: $alertRemainingMinutes,
                in: 0 ... warningRemainingMinutes,
                step: 1
            ) {
                Text("Alarme: ")
                    .foregroundColor(TimerZone.alert.color)
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
}

// MARK: - Previews

struct SeanceTimerView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        return Group {
            SeanceTimerView(
                discipline: classe.disciplineEnum,
                classeName: classe.displayString,
                schoolName: classe.school!.viewName,
                lineWidth: 40,
                test: true
            )
            .previewDevice("iPad mini (6th generation)")
            
            SeanceTimerView(
                discipline: classe.disciplineEnum,
                classeName: classe.displayString,
                schoolName: classe.school!.viewName,
                lineWidth: 40,
                test: true
            )
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
