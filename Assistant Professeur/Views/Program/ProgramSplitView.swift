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

    ///    private var navig: NavigationModel
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
//                .navigationSplitViewColumnWidth(min: 200,
//                                                ideal: 250,
//                                                max: 500)
        } content: {
            // 2nde colonne
            NavigationStack(path: $navig.programPath) {
                SequenceSidebarView(showProgramSteps: $showProgramSteps)
                    .navigationDestination(for: ProgramEntity.self) { program in
                        ProgramDetailGroupBox(program: program)
                    }
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
                    VStack(alignment: .center) {
                        Text("Aucune Activité sélectionnée.")
                        Text("Sélectionner une Activité pour en visualiser le détail ou le Programme/Séquence pour en visualiser le déroulement.")
                            .font(.callout)
                            .padding(.top)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .foregroundStyle(.secondary)
                    .font(.title2)

                case .showActivityDetail:
                    ActivityDetail()

                case .showProgramSteps:
                    Text("ProgramSteps")

                case .showSequenceSteps:
                    Text("sequenceSteps")
            }
        }
        .navigationSplitViewStyle(.balanced)

        .onAppear {
            if navig.selectedSequenceId == nil {
                navig.columnVisibility = .all
            }
        }

        // désélectionner la séquence et l'activité quand on change de programme
        .onChange(of: navig.selectedProgramId) { _ in
            vm.detailColumnSM.process(event: .onSelectedProgramChanged)
        }

        // désélectionner l'activité quand on change de séquence
        .onChange(of: navig.selectedSequenceId) { _ in
            vm.detailColumnSM.process(event: .onSelectedSequenceChanged)
        }

        // escamoter la 1ère colonne quand une activité est sélectionnée
        .onChange(of: navig.selectedActivityId) { newActivityId in
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
                    navig.selectedActivityId = nil
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
                    navig.selectedSequenceId = nil
                    navig.selectedActivityId = nil
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
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition13)

        let transition14 =
            DetailColumnTransition(
                with: .onShowprogramStepsRequested,
                from: .showNone,
                to: .showProgramSteps,
                postBlock: {
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition14)

        // A partir de showActivityDetail
        let transition20 =
            DetailColumnTransition(
                with: .onActivityDeselected,
                from: .showActivityDetail,
                to: .showNone,
                postBlock: { navig.columnVisibility = .all }
            )
        sm.add(transition: transition20)

        let transition21 =
            DetailColumnTransition(
                with: .onSelectedSequenceChanged,
                from: .showActivityDetail,
                to: .showNone,
                postBlock: {
                    navig.selectedActivityId = nil
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
                    navig.selectedSequenceId = nil
                    navig.selectedActivityId = nil
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
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition23)

        let transition24 =
            DetailColumnTransition(
                with: .onShowprogramStepsRequested,
                from: .showActivityDetail,
                to: .showProgramSteps,
                postBlock: {
                    navig.columnVisibility = .all
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
                to: .showNone,
                postBlock: {
                    navig.selectedActivityId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition31)

        let transition32 =
            DetailColumnTransition(
                with: .onSelectedProgramChanged,
                from: .showProgramSteps,
                to: .showNone,
                postBlock: {
                    navig.selectedSequenceId = nil
                    navig.selectedActivityId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition32)

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
                to: .showNone,
                postBlock: {
                    navig.selectedActivityId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition41)

        let transition42 =
            DetailColumnTransition(
                with: .onSelectedProgramChanged,
                from: .showSequenceSteps,
                to: .showNone,
                postBlock: {
                    navig.selectedSequenceId = nil
                    navig.selectedActivityId = nil
                    navig.columnVisibility = .all
                }
            )
        sm.add(transition: transition42)

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
