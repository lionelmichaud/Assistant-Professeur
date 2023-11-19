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

    // MARK: - Internal Types

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

    #if canImport(ActivityKit)
        /// The App live activity manager
        @StateObject
        private var activityManager = LiveActivityManager.shared
    #endif

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
            if let seance = timerVM.seanceOngoing(inSchool: school, at: timeLine.date) {
                ViewThatFits(in: .horizontal) {
                    regularView(date: timeLine.date, seance: seance)
                    compactView(date: timeLine.date, seance: seance)
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
        .task(id: school.id) {
            #if canImport(ActivityKit)

                // MARK: - Live Activty

                guard let seance = timerVM.seanceOngoing(inSchool: school, at: .now) else {
                    return
                }

                let seanceDuration = Int(seance.interval.duration) // seconds

                /// Démarrer la Live Activity
                let initialState =
                    LiveCoursProgressState(
                        elapsedMinutes: timerVM.elapsedMinutes(inSchool: school, to: .now),
                        remainingMinutes: timerVM.remainingMinutes(inSchool: school, from: .now),
                        cursorValue: timerVM.cursorValue(inSchool: school, for: .now),
                        timerZone: timerVM.timerZone(
                            inSchool: school,
                            for: .now,
                            seuilAlert: alertRemainingMinutes,
                            seuilWarning: warningRemainingMinutes
                        )
                    )
                let attribute =
                    LiveCoursProgressFixedAttributes(
                        seance: seance.interval,
                        schoolName: school.viewName,
                        classeName: seance.name ?? "",
                        warningRemainingMinutes: warningRemainingMinutes,
                        alertRemainingMinutes: alertRemainingMinutes
                    )
                await activityManager.start(
                    withInitialState: initialState,
                    fixedAttributes: attribute
                )
                #if DEBUG
                    print(">> Activité lancée")
                #endif

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
                            elapsedMinutes: timerVM.elapsedMinutes(inSchool: school, to: .now),
                            remainingMinutes: timerVM.remainingMinutes(inSchool: school, from: .now),
                            cursorValue: timerVM.cursorValue(inSchool: school, for: .now),
                            timerZone: timerVM.timerZone(
                                inSchool: school,
                                for: .now,
                                seuilAlert: alertRemainingMinutes,
                                seuilWarning: warningRemainingMinutes
                            )
                        )
                    await activityManager.updateActivity(
                        withNewState: newState,
                        alertConfiguration: alertConfig
                    )

                    #if DEBUG
                        print(">> Activité updated")
                    #endif

                    try? await Task.sleep(for: .seconds(updatePeriod)) // exception thrown when cancelled by SwiftUI when this view disappears.

                    if let elapsedSeconds = timerVM.elapsedSeconds(inSchool: school) {
                        keepOnLooping = elapsedSeconds < seanceDuration - Int(updatePeriod)
                    } else {
                        keepOnLooping = false
                    }
                } while !Task.isCancelled && keepOnLooping

                /// Arrêter la Live Activity
                var finalState: LiveCoursProgressState
                if Task.isCancelled {
                    // Tâche annulée par la disparition de la View avant la fin du cours
                    finalState = LiveCoursProgressState(
                        elapsedMinutes: timerVM.elapsedMinutes(inSchool: school, to: .now),
                        remainingMinutes: timerVM.remainingMinutes(inSchool: school, from: .now),
                        cursorValue: timerVM.cursorValue(inSchool: school, for: .now),
                        timerZone: timerVM.timerZone(
                            inSchool: school, for: .now,
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
                await activityManager.endActivity(
                    withFinalState: finalState
                )
                #if DEBUG
                    print(">> Activité canceled")
                #endif
            #endif
        }
    }
}

// MARK: - Methods

extension SeanceTimerView {
    /// Temps écoulé depuis le début de la séance
    private func elapsedTime(
        inSchool school: SchoolEntity,
        for date: Date
    ) -> DateComponents? {
        #if DEBUG
            if preview {
                return DateComponents(minute: date.minutes, second: date.seconds)
            }
        #endif

        return timerVM.elapsedTime(inSchool: school, to: date)
    }

    /// Temps restant avant le début de la séance
    private func remainingTime(
        inSchool school: SchoolEntity,
        for date: Date
    ) -> DateComponents? {
        #if DEBUG
            if preview {
                return DateComponents(minute: 60 - date.minutes, second: 60 - date.seconds)
            }
        #endif

        return timerVM.remainingTime(inSchool: school, from: date)
    }

    /// Position du curseur en % [0; 1]
    private func cursorValue(
        for date: Date
    ) -> Double? {
        #if DEBUG
            if preview {
                return date.minutes.double() / 60.0
            }
        #endif

        return timerVM.cursorValue(inSchool: school, for: date)
    }

    private func timerZone(
        inSchool school: SchoolEntity,
        for date: Date
    ) -> TimerZone {
        #if DEBUG
            if preview {
                return TimerZone.allCases.randomElement()!
            }
        #endif

        return timerVM.timerZone(
            inSchool: school,
            for: date,
            seuilAlert: alertRemainingMinutes,
            seuilWarning: warningRemainingMinutes
        )
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
    private func compactView(date: Date, seance: Seance) -> some View {
        VStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(seance.interval.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: cursorValue(for: date)!,
                    color: timerZone(inSchool: school, for: date).color,
                    elapsedTime: elapsedTime(inSchool: school, for: date),
                    remainingTime: remainingTime(inSchool: school, for: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth)
                .task(id: date) {
                    guard let remainingMinutes = timerVM.remainingMinutes(
                        inSchool: school,
                        from: date
                    ) else {
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
    private func regularView(date: Date, seance: Seance) -> some View {
        HStack {
            VStack {
                // heure de fin de la séance de travail
                Text("Fin de la séance à **\(seance.interval.end.formatted(date: .omitted, time: .shortened))**")
                    .font(.title)

                ProgressClockView(
                    trimValue: cursorValue(for: date)!,
                    color: timerZone(inSchool: school, for: date).color,
                    elapsedTime: elapsedTime(inSchool: school, for: date),
                    remainingTime: remainingTime(inSchool: school, for: date),
                    warningNotif: $warningAlarmIsActivited,
                    alertNotif: $alertAlarmIsActivated
                )
                .padding(lineWidth / 2)
                .task(id: date) {
                    guard let remainingMinutes = timerVM.remainingMinutes(
                        inSchool: school,
                        from: date
                    ) else {
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
