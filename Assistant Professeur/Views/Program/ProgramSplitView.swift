//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import Stateful
import SwiftUI

// MARK: - State Machine de l'état de la colonne "détail"

private enum DetailColumnEvent {
    case onActivitySelected
    case onActivityDeselected
    case onSelectedSequenceChanged
    case onSelectedProgramChanged
    case onShowSequenceStepsRequested
    case onShowprogramStepsRequested
}

private enum DetailColumnState {
    case showNone, showProgramSteps, showSequenceSteps, showActivityDetail
}

private typealias DetailColumnTransition = Transition<DetailColumnState, DetailColumnEvent>
private typealias DetailColumnStateMachine = StateMachine<DetailColumnState, DetailColumnEvent>

// MARK: - ViewModel

private final class ProgramSplitViewModel: ObservableObject {
    // MARK: - Properties

    var detailColumnSM: DetailColumnStateMachine

    // MARK: - Computed Properties

    var detailColumnContent: DetailColumnState {
        detailColumnSM.currentState
    }

    // MARK: - Initializer

    init(detailColumnSM: DetailColumnStateMachine) {
        self.detailColumnSM = detailColumnSM
    }
}

// MARK: - View

/// Vues de Programmes / Séquences / Activités
struct ProgramSplitView: View {
    // MARK: - Properties

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var vm: ProgramSplitViewModel

    @State
    private var showProgramSteps: Bool = false

    @State
    private var showSequenceSteps: Bool = false

//    @State
//    private var programPath = NavigationPath()

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            ProgramSidebarView()
                .navigationSplitViewColumnWidth(min: 250,
                                                ideal: 300,
                                                max: 500)

        } content: {
            // 2nde colonne
            NavigationStack(path: $navig.programPath) {
                SequenceSidebarView(showProgramSteps: $showProgramSteps)
                    .navigationSplitViewColumnWidth(min: 300,
                                                    ideal: 400,
                                                    max: 500)
                    .navigationDestination(for: SequenceEntity.self) { sequence in
                        ActivitySideBar(
                            sequence: sequence,
                            showSequenceSteps: $showSequenceSteps
                        )
                    }
            }

        } detail: {
            // Détail dans la 3ième colonne
            switch vm.detailColumnContent {
                case .showNone:
                    EmptyListMessage(
                        title: "Aucune activité sélectionnée.",
                        message: "Sélectionner une activité pour en visualiser le contenu.",
                        showAsGroupBox: true
                    )
                    .padding()
                    .foregroundStyle(.secondary)
                    .font(.title2)

                case .showActivityDetail:
                    ActivityDetail()

                case .showProgramSteps:
                    ProgramTimeLine()

                case .showSequenceSteps:
                    SequenceTimeLine()
            }
        }
        .navigationSplitViewStyle(.balanced)

        .onAppear {
            if navig.selectedSequenceMngObjId == nil {
                navig.columnVisibility = .all
            }
        }

        // désélectionner la séquence et l'activité quand on change de programme
        .onChange(of: navig.selectedProgramMngObjId) { _ in
            vm.detailColumnSM.process(event: .onSelectedProgramChanged)
        }

        // désélectionner l'activité quand on change de séquence
        .onChange(of: navig.selectedSequenceMngObjId) { [oldSequenceID = navig.selectedSequenceMngObjId] _ in
            if oldSequenceID != nil {
                vm.detailColumnSM.process(event: .onSelectedSequenceChanged)
            }
        }

        // escamoter la 1ère colonne quand une activité est sélectionnée
        .onChange(of: navig.selectedActivityMngObjId) { newActivityId in
            if newActivityId == nil {
                vm.detailColumnSM.process(event: .onActivityDeselected)
            } else {
                vm.detailColumnSM.process(event: .onActivitySelected)
            }
        }

        .onChange(of: showProgramSteps) { show in
            if show {
                vm.detailColumnSM.process(event: .onShowprogramStepsRequested)
                showProgramSteps = false
            }
        }

        .onChange(of: showSequenceSteps) { show in
            if show {
                vm.detailColumnSM.process(event: .onShowSequenceStepsRequested)
                showSequenceSteps = false
            }
        }
    }

    // MARK: - Initializer

    init(navig: NavigationModel) {
        let sm = DetailColumnStateMachine(initialState: .showNone)

        // A partir de showNone
        let transition10 =
            DetailColumnTransition(
                with: .onActivitySelected,
                from: .showNone,
                to: .showActivityDetail,
                postBlock: {
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition10)

        let transition11 =
            DetailColumnTransition(
                with: .onSelectedSequenceChanged,
                from: .showNone,
                to: .showNone,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition11)

        let transition12 =
            DetailColumnTransition(
                with: .onSelectedProgramChanged,
                from: .showNone,
                to: .showNone,
                postBlock: {
                    navig.selectedSequenceMngObjId = nil
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition12)

        let transition13 =
            DetailColumnTransition(
                with: .onShowSequenceStepsRequested,
                from: .showNone,
                to: .showSequenceSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition13)

        let transition14 =
            DetailColumnTransition(
                with: .onShowprogramStepsRequested,
                from: .showNone,
                to: .showProgramSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition14)

        // A partir de showActivityDetail
        let transition20 =
            DetailColumnTransition(
                with: .onActivityDeselected,
                from: .showActivityDetail,
                to: .showNone,
                postBlock: {
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition20)

        let transition21 =
            DetailColumnTransition(
                with: .onSelectedSequenceChanged,
                from: .showActivityDetail,
                to: .showNone,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition21)

        let transition22 =
            DetailColumnTransition(
                with: .onSelectedProgramChanged,
                from: .showActivityDetail,
                to: .showNone,
                postBlock: {
                    navig.selectedSequenceMngObjId = nil
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition22)

        let transition23 =
            DetailColumnTransition(
                with: .onShowSequenceStepsRequested,
                from: .showActivityDetail,
                to: .showSequenceSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition23)

        let transition24 =
            DetailColumnTransition(
                with: .onShowprogramStepsRequested,
                from: .showActivityDetail,
                to: .showProgramSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition24)

        // A partir de showProgramSteps

        let transition30 =
            DetailColumnTransition(
                with: .onActivitySelected,
                from: .showProgramSteps,
                to: .showActivityDetail,
                postBlock: {
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition30)

        let transition31 =
            DetailColumnTransition(
                with: .onSelectedSequenceChanged,
                from: .showProgramSteps,
                to: .showProgramSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
//                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition31)

        let transition32 =
        DetailColumnTransition(
            with: .onSelectedProgramChanged,
            from: .showProgramSteps,
            to: .showNone,
            postBlock: {
                navig.selectedSequenceMngObjId = nil
                navig.selectedActivityMngObjId = nil
                navig.columnVisibility = .all
            }
        )
        sm.add(transition: transition32)

        let transition33 =
        DetailColumnTransition(
            with: .onShowSequenceStepsRequested,
            from: .showProgramSteps,
            to: .showSequenceSteps,
            postBlock: {
                navig.columnVisibility = .doubleColumn
            }
        )
        sm.add(transition: transition33)

        // A partir de showSequenceSteps

        let transition40 =
            DetailColumnTransition(
                with: .onActivitySelected,
                from: .showSequenceSteps,
                to: .showActivityDetail,
                postBlock: {
                    navig.columnVisibility = .doubleColumn
                }
            )
        sm.add(transition: transition40)

        let transition41 =
            DetailColumnTransition(
                with: .onSelectedSequenceChanged,
                from: .showSequenceSteps,
                to: .showSequenceSteps,
                postBlock: {
                    navig.selectedActivityMngObjId = nil
                }
            )
        sm.add(transition: transition41)

        let transition42 =
        DetailColumnTransition(
            with: .onSelectedProgramChanged,
            from: .showSequenceSteps,
            to: .showNone,
            postBlock: {
                navig.selectedSequenceMngObjId = nil
                navig.selectedActivityMngObjId = nil
                navig.columnVisibility = .all
            }
        )
        sm.add(transition: transition42)

        let transition43 =
        DetailColumnTransition(
            with: .onShowprogramStepsRequested,
            from: .showSequenceSteps,
            to: .showProgramSteps,
            postBlock: {
                navig.columnVisibility = .doubleColumn
            }
        )
        sm.add(transition: transition43)

        #if DEBUG
            sm.enableLogging = true
        #endif

        self.vm = ProgramSplitViewModel(detailColumnSM: sm)
    }
}

// struct ProgramSplitView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramSplitView()
//    }
// }
