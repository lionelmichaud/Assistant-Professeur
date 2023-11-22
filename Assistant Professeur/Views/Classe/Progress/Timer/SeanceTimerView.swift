//
//  ActivityTimerView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/04/2023.
//

import AppFoundation
import AVFoundation
import EventKit
import HelpersView
import SwiftUI
#if canImport(ActivityKit)
    import ActivityKit
#endif

/// Présentation d'un chronomètre de séance
struct SeanceTimerView: View {
    let school: SchoolEntity
    var lineWidth: Double = 40.0
    var preview: Bool = false

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
    private var timerVM = TodaySeances.shared

    private let updatePeriod = TimeInterval(10) // seconds

    private let notificationFeedback = UINotificationFeedbackGenerator()

    @State
    private var alert = AlertInfo()

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
        TimelineView(.periodic(from: .now, by: updatePeriod)) { timeLine in
            // Vue rafraichie périodiquement
            if timerVM.seanceOngoing != nil {
                ViewThatFits(in: .horizontal) {
                    regularView(date: timeLine.date)
                    compactView(date: timeLine.date)
                }

            } else {
                // TODO: - Proposer d'aller à la vue "mise à jour de l'avancement de la classe"
                Text("Pas de séance en cours")
                    .font(.title)
            }
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )

        // MARK: - Live Activty

        .onAppear(perform: initializeVM)
        .task {
            #if canImport(ActivityKit)
                // Gérer la Live Activity
                await manageLiveActivity()
            #endif
        }
    }
}

// MARK: - Methods

extension SeanceTimerView {
    private func initializeVM() {
        // Recherche et mémoriser la séance en cours à la `date` dans  `school`
        timerVM.findOngoingSeance(inSchool: school, at: .now)
    }

    /// Gérer la Live Activity
    private func manageLiveActivity() async {
        guard timerVM.seanceOngoing != nil else {
            return
        }

        // Démarrer la Live Activity
        await startLiveActivity()

        // Mettre à jour la Live Activity
        await updateLiveActivity()

        // Arrêter la Live Activity
        await endLiveActivity()
    }

    /// Démarrer la Live Activity
    private func startLiveActivity() async {
        let initialState =
            LiveCoursProgressState(
                elapsedMinutes: timerVM.elapsedMinutes(to: .now),
                remainingMinutes: timerVM.remainingMinutes(from: .now),
                cursorValue: timerVM.cursorValue(for: .now),
                timerZone: timerVM.timerZone(
                    for: .now,
                    seuilAlert: alertRemainingMinutes,
                    seuilWarning: warningRemainingMinutes
                )
            )
        let attribute =
            LiveCoursProgressFixedAttributes(
                seance: timerVM.seanceOngoing!.interval,
                schoolName: timerVM.seanceOngoing?.schoolName ?? "",
                classeName: timerVM.seanceOngoing?.name ?? "",
                warningRemainingMinutes: warningRemainingMinutes,
                alertRemainingMinutes: alertRemainingMinutes
            )
        await LiveActivityManager.shared.start(
            withInitialState: initialState,
            fixedAttributes: attribute
        )
        #if DEBUG
            print(">> Activité lancée")
        #endif
    }

    /// Mettre à jour la Live Activity
    func updateLiveActivity() async {
        var keepOnLooping = true
        repeat {
            var alertConfig: AlertConfiguration?
            // code you want to repeat
            // Update périodique de la Live Activity
            // TODO: - Gérer le déclenchement des message d'alerte dans Live Activity
            if false {
                alertConfig = AlertConfiguration(
                    title: "Title",
                    body: "Body",
                    sound: .default
                )
            }
            let newState =
                LiveCoursProgressState(
                    elapsedMinutes: timerVM.elapsedMinutes(to: .now),
                    remainingMinutes: timerVM.remainingMinutes(from: .now),
                    cursorValue: timerVM.cursorValue(for: .now),
                    timerZone: timerVM.timerZone(
                        for: .now,
                        seuilAlert: alertRemainingMinutes,
                        seuilWarning: warningRemainingMinutes
                    )
                )
            await LiveActivityManager.shared.update(
                withNewState: newState,
                alertConfiguration: alertConfig
            )

            #if DEBUG
                print(">> Activité updated")
            #endif

            do {
                try await Task.sleep(for: .seconds(updatePeriod)) // exception thrown when cancelled by SwiftUI when this view disappears.
            } catch is CancellationError {
                // If the task is cancelled before the time ends, this function throws CancellationError
                break
            } catch {
                break
            }

            if let elapsedSeconds = timerVM.elapsedSeconds() {
                keepOnLooping = (TimeInterval(elapsedSeconds) + updatePeriod) < timerVM.seanceOngoing!.interval.duration
            } else {
                keepOnLooping = false
            }
        } while !Task.isCancelled && keepOnLooping
    }

    /// Arrêter la Live Activity
    private func endLiveActivity() async {
        var finalState: LiveCoursProgressState
        if Task.isCancelled {
            // Tâche annulée par la disparition de la View avant la fin du cours
            finalState = LiveCoursProgressState(
                elapsedMinutes: timerVM.elapsedMinutes(to: .now),
                remainingMinutes: timerVM.remainingMinutes(from: .now),
                cursorValue: timerVM.cursorValue(for: .now),
                timerZone: timerVM.timerZone(
                    for: .now,
                    seuilAlert: alertRemainingMinutes,
                    seuilWarning: warningRemainingMinutes
                )
            )
        } else {
            // Fin du cours avant la disparition de la View
            finalState = LiveCoursProgressState(
                elapsedMinutes: 1,
                remainingMinutes: 0,
                cursorValue: 1.0,
                timerZone: .alert
            )
        }
        await LiveActivityManager.shared.end(
            withFinalState: finalState
        )
        timerVM.resetOngoingSeance()
        #if DEBUG
            print(">> Activité canceled")
        #endif
    }

    /// Vibre à chaque appel durant la période de une minute suivant le franchissement d'un seuil d'alerte.
    /// - Parameters:
    ///   - remainingMinutes: Nombre de minutes restantes avant la fin du cours.
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

    /// Joue un son à chaque appel durant la période de une minute suivant le franchissement d'un seuil d'alerte.
    /// - Parameters:
    ///   - remainingMinutes: Nombre de minutes restantes avant la fin du cours.
    private func playSound(remainingMinutes: Int) {
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
    @ViewBuilder
    private func compactView(date: Date) -> some View {
        VStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(timerVM.seanceOngoing!.interval.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: timerVM.cursorValue( for: date)!,
                    color: timerVM.timerZone(
                        for: date,
                        seuilAlert: alertRemainingMinutes,
                        seuilWarning: warningRemainingMinutes
                    ).color,
                    elapsedTime: timerVM.elapsedTime(to: date),
                    remainingTime: timerVM.remainingTime(from: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth)
                .task(id: date) {
                    guard let remainingMinutes = timerVM.remainingMinutes(from: date) else {
                        return
                    }
                    vibrate(remainingMinutes: remainingMinutes)
                    playSound(remainingMinutes: remainingMinutes)
                }
            }

            // seuils d'alerte
            reglageSeuilView
        }
    }

    @ViewBuilder
    private func regularView(date: Date) -> some View {
        HStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(timerVM.seanceOngoing!.interval.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: timerVM.cursorValue( for: date)!,
                    color: timerVM.timerZone(
                        for: date,
                        seuilAlert: alertRemainingMinutes,
                        seuilWarning: warningRemainingMinutes
                    ).color,
                    elapsedTime: timerVM.elapsedTime(to: date),
                    remainingTime: timerVM.remainingTime(from: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth / 2)
                .task(id: date) {
                    guard let remainingMinutes = timerVM.remainingMinutes(from: date) else {
                        return
                    }
                    vibrate(remainingMinutes: remainingMinutes)
                    playSound(remainingMinutes: remainingMinutes)
                }
            }

            VStack {
                // seuils d'alerte
                reglageSeuilView
            }
        }
    }

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
                school: classe.school!,
                lineWidth: 40,
                preview: true
            )
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
