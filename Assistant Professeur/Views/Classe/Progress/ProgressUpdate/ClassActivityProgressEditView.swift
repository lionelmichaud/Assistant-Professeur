//
//  ClassActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Activité d'une Séquence donnée
struct ClassActivityProgressEditView: View {
    // MARK: - Properties

    @ObservedObject
    var progress: ActivityProgressEntity

    @Binding
    var progressChanged: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = false

    @State
    private var isShowingActivityTimer: Bool = false

    @State
    private var progressValue: Double = 0

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                regularView
                // priorité 2
                compactView
            }
        } label: {
            labelView
        }
        .onAppear {
            isExpanded = progress.status == .inProgress
        }
        #if os(macOS)
        .sheet(isPresented: $isShowingActivityTimer) {
            NavigationStack {
                if let discipline = progress.classe?.disciplineEnum,
                   let classeName = progress.classe?.displayString,
                   let schoolName = progress.classe!.school?.viewName {
                    ClasseTimerModal(
                        discipline: discipline,
                        classeName: classeName,
                        schoolName: schoolName
                    )
                } else {
                    Text("Impossible d'afficher le chronomètre")
                }
            }
        }
        #else
                .fullScreenCover(isPresented: $isShowingActivityTimer) {
                    NavigationStack {
                        if let discipline = progress.classe?.disciplineEnum,
                           let classeName = progress.classe?.displayString,
                           let schoolName = progress.classe!.school?.viewName {
                            ClasseTimerModal(
                                discipline: discipline,
                                classeName: classeName,
                                schoolName: schoolName
                            )
                        } else {
                            Text("Impossible d'afficher le chronomètre")
                        }
                    }
                }
        #endif
    }
}

// MARK: - Subviews

extension ClassActivityProgressEditView {
    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 1:
                return "dem."

            case 2 ... 6:
                return date
                    .formatted(Date.FormatStyle()
                        .weekday(.abbreviated))

            default:
                return date
                    .formatted(Date.FormatStyle()
                        .day(.twoDigits)
                        .month(.twoDigits))
        }
    }

    private var labelView: some View {
        Group {
            if let activity = progress.activity {
                HStack(alignment: .center) {
                    VStack {
                        HStack {
                            CompletionSymbol(
                                status: progress.status
                            )

                            ActivityTag(
                                activity: activity,
                                font: hClass == .compact ? .callout : .body
                            )
                        }
                        if (progress.status == .inProgress || progress.status == .notStarted) &&
                            hClass == .compact {
                            if let startDate = progress.startDate {
                                VStack {
                                    // Date à laquelle débutera l'activité
                                    Text(formattedDate(startDate))
                                        .font(.callout)
                                    if let endDate = progress.endDate,
                                       endDate.day != startDate.day {
                                        // Date à laquelle se terminera l'activité
                                        Text(formattedDate(endDate))
                                            .font(.callout)
                                    }
                                }
                            }
                        }
                    }

                    Text(activity.viewName)
                        .font(hClass == .compact ? .callout : .body)
                        .textSelection(.enabled)

                    Spacer(minLength: 2)

                    if (progress.status == .inProgress || progress.status == .notStarted) &&
                        hClass == .regular {
                        if let startDate = progress.startDate {
                            VStack {
                                // Date à laquelle débutera l'activité
                                Text(formattedDate(startDate))
                                    .font(.callout)
                                if let endDate = progress.endDate,
                                   endDate.day != startDate.day {
                                    // Date à laquelle se terminera l'activité
                                    Text(formattedDate(endDate))
                                        .font(.callout)
                                }
                            }
                        }
                    }

                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: hClass == .regular ? true : false,
                        axis: hClass == .regular ? .horizontal : .vertical
                    )
                }
            } else {
                Text("nil")
            }
        }
    }

    // Boyon navigant vers l'activité associée
    private var voirButton: some View {
        Button {
            if let activity = progress.activity,
               let sequence = activity.sequence,
               let program = sequence.program {
                navig.selectedTab = .program
                navig.selectedProgramMngObjId = program.objectID
//                navig.selectedSequenceMngObjId = sequence.objectID
//                navig.selectedActivityMngObjId = activity.objectID
//                navig.programPath = NavigationPath()
//                navig.programPath.append(program)
//                navig.programPath.append(sequence)
            }
        } label: {
            Text("Voir l'activité")
        }
        .buttonStyle(.borderedProminent)
    }

    @ViewBuilder
    private func stopWatchButton(for _: ActivityEntity) -> some View {
        Button {
            isShowingActivityTimer.toggle()
        } label: {
            Text("Chrono")
            Image(systemName: "stopwatch")
        }
        .buttonStyle(.borderedProminent)
    }

    private var buttons: some View {
        HStack {
            Spacer()
            if let activity = progress.activity,
               activity.isTP || activity.isProject {
                stopWatchButton(for: activity)
                Spacer()
            }
            voirButton
            Spacer()
        }
    }

    private var annotation: some View {
        TextField(
            "",
            text: $progress.annotation.bound,
            prompt: Text("description"),
            axis: .vertical
        )
        .multilineTextAlignment(.leading)
        .lineLimit(5)
        .textFieldStyle(.roundedBorder)
        .onSubmit {
            try? ActivityProgressEntity.saveIfContextHasChanged()
        }
    }

    private var isPrintedCheckBox: some View {
        // checkbox isPrinted
        Button {
            progress.toggleIsPrinted()
        } label: {
            Label(
                title: {
                    Text("Supports de cours imprimés")
                }, icon: {
                    Image(systemName: progress.isPrinted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(progress.isPrinted ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }

    private var isDistributedCheckBox: some View {
        // checkbox isDistributed
        Button {
            progress.toggleIsDistributed()
        } label: {
            Label(
                title: {
                    Text("Supports de cours distribués")
                }, icon: {
                    Image(systemName: progress.isDistributed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(progress.isDistributed ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }

    private var regularView: some View {
        VStack(alignment: .leading) {
            LabeledContent("Progression") {
                ActivityProgressSlider(
                    progress: progress,
                    progressChanged: $progressChanged
                )
                .frame(minWidth: 250)
            }

            annotation

            isPrintedCheckBox
            isDistributedCheckBox

            buttons
        }
        .padding(.leading)
    }

    private var compactView: some View {
        VStack(alignment: .leading) {
            ActivityProgressSlider(
                progress: progress,
                progressChanged: $progressChanged
            )

            annotation

            isPrintedCheckBox
            isDistributedCheckBox

            buttons
        }
    }
}

struct ClassActivityProgressView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        let progress = classe.allProgresses.first!
        //            let currentActivity = classe.currentActivity!
        //            let currentSequence = currentActivity.sequence!
        //            let progress = ClasseEntity.all().first!.currentActivity
        return Group {
            List {
                ClassActivityProgressEditView(
                    progress: progress,
                    progressChanged: .constant(false)
                )
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassActivityProgressEditView(
                    progress: progress,
                    progressChanged: .constant(false)
                )
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
