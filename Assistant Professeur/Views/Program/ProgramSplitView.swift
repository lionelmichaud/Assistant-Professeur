//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import AppFoundation
import SwiftUI

// MARK: - State Machine de l'état de la colonne "détail"

/// Contenus possibles de la colonne Détail
enum ProgramDetailColumnState {
    case showProgramSteps
    case showSequenceSteps
    case showActivityDetail
}

// MARK: - View

/// Vues de Programmes / Séquences / Activités
struct ProgramSplitView: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @Environment(Store.self)
    private var store

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var preferredColumn = NavigationSplitViewColumn.sidebar

    var body: some View {
        ZStack {
            if store.isPurchased(service: .program) {
                NavigationSplitView(
                    columnVisibility: $navig.columnVisibility,
                    preferredCompactColumn: $preferredColumn
                ) {
                    // 1ère colonne
                    ProgramSidebar()
                        .navigationSplitViewColumnWidth(
                            min: 300,
                            ideal: 300,
                            max: 500
                        )

                } content: {
                    // 2nde colonne
                    SequenceSidebar()
                    // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                        .id(navig.selectedProgramMngObjId)
                        .navigationSplitViewColumnWidth(
                            min: 400,
                            ideal: 500,
                            max: 600
                        )

                } detail: {
                    // 3ième colonne
                    NavigationStack(path: $navig.programPath) {
                        ActivitySideBar()
                        // Workaround: Conditional views in columns of NavigationSplitView fail to update on some state changes. (91311311)
                            .id(navig.selectedSequenceMngObjId)
                            .navigationDestination(for: ProgramNavigationRoute.self) { route in
                                route.destination()
                            }
                    }
                }
                .navigationSplitViewStyle(.balanced)

                // Désélectionner la séquence et l'activité quand on change de programme
                // Afficher la colonne du milieu sur iPhone
                .onChange(of: navig.selectedProgramMngObjId) {
                    Task {
                        await navig.changeSelectedProgram()
                    }
                }

                // Désélectionner l'activité quand on change de séquence
                // Afficher la colonne détail sur iPhone
                .onChange(of: navig.selectedSequenceMngObjId) {
                    navig.changeSelectedSequence()
                }
            } else {
                VStack {
                    Image(.ecranIPadProgram)
                        .resizable()
                        .scaledToFit()
                    Text("Pour avoir accès à la création de vos **progressions pédagogiques** et les associer à vos cours, rendez-vous en magazin.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .frame(maxWidth: hClass == .regular ? 600 : 300)
                    Button("Magazin") {
                        store.isShowingStore = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return ProgramSplitView()
        .padding()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .previewDevice("iPad mini (6th generation)")
}
