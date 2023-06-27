//
//  ClassActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Activité d'une Séquence donnée
struct ClassActivityProgressEditView: View {
    // MARK: - Initializer

    init(progress: ActivityProgressEntity) {
        self.progress = progress
        self._isExpanded =
            State(initialValue: progress.status == .inProgress)
    }

    // MARK: - Properties

    @ObservedObject
    private var progress: ActivityProgressEntity

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
    private var labelView: some View {
        Group {
            if let activity = progress.activity {
                HStack(alignment: .center) {
                    CompletionSymbol(
                        status: progress.status
                    )
                    ActivityTag(
                        activity: activity,
                        font: hClass == .compact ? .callout : .body
                    )
                    Text(activity.viewName)
                        .font(hClass == .compact ? .callout : .body)
                        .textSelection(.enabled)
                    Spacer(minLength: 2)
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

    private var description: some View {
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

    private var regularView: some View {
        VStack(alignment: .leading) {
            LabeledContent("Progression") {
                ActivityProgressSlider(progress: progress)
                    .frame(minWidth: 250)
            }

            description

            buttons
        }
        .padding(.leading)
    }

    private var compactView: some View {
        VStack(alignment: .leading) {
            ActivityProgressSlider(progress: progress)

            description

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
                ClassActivityProgressEditView(progress: progress)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassActivityProgressEditView(progress: progress)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
