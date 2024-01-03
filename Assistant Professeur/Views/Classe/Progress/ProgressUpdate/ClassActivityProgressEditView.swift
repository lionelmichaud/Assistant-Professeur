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

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                regularView
                // .padding(.leading)
                // priorité 2
                compactView
            }
            .customizedListItemStyle(isSelected: false)
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
        } label: {
            labelView
        }
        .onAppear {
            isExpanded = progress.status == .inProgress
        }
        #if os(macOS)
        .sheet(
            isPresented: $isShowingActivityTimer,
            onDismiss: {
                if let classe = progress.classe {
                    DeepLinkManager.handleLink(
                        navigateTo: .classeProgressUpdate(classe: classe),
                        using: navig
                    )
                }
            },
            content: {
                if let classe = progress.classe,
                   let school = progress.classe?.school {
                    NavigationStack {
                        ClasseTimerModal(
                            school: school
                        )
                    }
                } else {
                    Text("Impossible d'afficher le chronomètre")
                }
            }
        )
        #else
                .fullScreenCover(
                    isPresented: $isShowingActivityTimer,
                    onDismiss: {
                        if let classe = progress.classe {
                            DeepLinkManager.handleLink(
                                navigateTo: .classeProgressUpdate(classe: classe),
                                using: navig
                            )
                        }
                    },
                    content: {
                        if let school = progress.classe?.school {
                            NavigationStack {
                                ClasseTimerModal(
                                    school: school
                                )
                            }
                        } else {
                            Text("Impossible d'afficher le chronomètre")
                        }
                    }
                )
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
                                activityNumber: activity.viewNumber,
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

                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: hClass == .regular ? true : false,
                        axis: hClass == .regular ? .horizontal : .vertical
                    )

                    // Dates de la prochaine activité
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
                }
            } else {
                Text("nil")
            }
        }
    }

    private var regularView: some View {
        VStack(alignment: .leading) {
            RegularActivityProgress(
                progress: progress,
                progressChanged: $progressChanged
            )

            buttons
        }
    }

    private var compactView: some View {
        VStack(alignment: .leading) {
            CompactActivityProgress(
                progress: progress,
                progressChanged: $progressChanged
            )

            buttons
        }
    }

    private var buttons: some View {
        HStack {
            Spacer()
            Button {
                isShowingActivityTimer.toggle()
            } label: {
                Label("Chrono.", systemImage: "stopwatch")
            }
            .buttonStyle(.bordered)
            Spacer()
            jumpToActivityButton
            Spacer()
        }
    }

    /// Bouton navigant vers l'activité associée
    private var jumpToActivityButton: some View {
        Button {
            if let activity = progress.activity,
               let sequence = activity.sequence,
               let program = sequence.program {
                DeepLinkManager.handleLink(
                    navigateTo: .activity(
                        program: program,
                        sequence: sequence,
                        activity: activity
                    ),
                    using: navig
                )
            }
        } label: {
            Label("Voir l'activité", systemImage: ActivityEntity.defaultImageName)
        }
        .buttonStyle(.bordered)
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
