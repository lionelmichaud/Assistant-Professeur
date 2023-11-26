//
//  EvalsToBeCorrectedScrollView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/11/2023.
//

import SwiftUI
import HelpersView

struct EvalsToBeCorrectedScrollView: View {
    let seances: [Seance]

    @StateObject
    private var toDoViewModel = ToDoViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            switch toDoViewModel.status {
                case .pending, .computing, .failed:
                    toDoViewModel.status.view
                        .horizontallyAligned(.center)
                case .finished:
                    ForEach(toDoViewModel.batchesOfEvalsToBeCorrected) { batch in
                        EvalsToBeCorrectedGroupBox(batchOfEvalsToBeCorrected: batch)
                    }
                    .emptyListPlaceHolder(toDoViewModel.batchesOfEvalsToBeCorrected) {
                        ContentUnavailableView(
                            "Aucune évaluation à corriger pour le mois à venir...",
                            systemImage: "checklist",
                            description: Text("Les évaluations à corriger au cours du prochain mois apparaîtront ici.")
                        )
                    }
            }
        }
        .task {
            await toDoViewModel.getAllDocsToBeActioned(
                fromSeances: seances,
                forThisAction: ToDoAction.correct
            )
        }
    }
}

/// GroupBox présentant une évaluation à corriger et
/// son état d'avancement dans la correction
struct EvalsToBeCorrectedGroupBox: View {
    let batchOfEvalsToBeCorrected: BatchOfEvalsToBeCorrected

    @State
    private var documentToBeViewed: DocumentEntity?

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var evalStatusEnum: EvalStateEnum = .toBeCorrected

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                // Classe - Discipline - Sequence - Activité
                HStack {
                    classeSequenceActivityView
                    Spacer()
                    navigateToActivityButton
                }
                // Document
                documentsView
                    .padding(.top, 2)
                // Picker
                CasePicker(
                    pickedCase: $evalStatusEnum,
                    label: "Correction"
                )
                .pickerStyle(.segmented)
                    .padding(.top, 2)
            }
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .onAppear {
            evalStatusEnum = batchOfEvalsToBeCorrected.progress.evalStatusEnum
        }
        .onChange(of: evalStatusEnum) {
            batchOfEvalsToBeCorrected.progress.evalStatusEnum = evalStatusEnum
            try? ActivityProgressEntity.saveIfContextHasChanged()        }
    }
}

// MARK: - Subviews

extension EvalsToBeCorrectedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Classe
            Button {
                DeepLinkManager.handle(
                    navigateTo: .classeProgressUpdate(classe: batchOfEvalsToBeCorrected.classe),
                    using: navig
                )
            } label: {
                Text(batchOfEvalsToBeCorrected.classe.displayString)
            }
            .buttonStyle(.bordered)

            // Tags Séquence/Activité
            if let sequence = batchOfEvalsToBeCorrected.activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTagWithPopOver(activity: batchOfEvalsToBeCorrected.activity)
            }
        }
    }

    private var navigateToActivityButton: some View {
        Group {
            if let sequence = batchOfEvalsToBeCorrected.activity.sequence {
                Button {
                    DeepLinkManager.handle(
                        navigateTo: .activity(
                            program: sequence.program!,
                            sequence: sequence,
                            activity: batchOfEvalsToBeCorrected.activity
                        ),
                        using: navig
                    )
                } label: {
                    Label(
                        "Voir l'activité",
                        systemImage: "figure.walk.motion"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var documentsView: some View {
        Group {
            ForEach(batchOfEvalsToBeCorrected.documents) { document in
                Button {
                    documentToBeViewed = document
                } label: {
                    Text(document.viewName)
                }
                .horizontallyAligned(.leading)
                #if os(macOS)
                    .sheet(item: $documentToBeViewed) { doc in
                        NavigationStack {
                            PdfDocumentViewer(document: doc)
                        }
                    }
                #else
                        .fullScreenCover(item: $documentToBeViewed) { doc in
                            NavigationStack {
                                PdfDocumentViewer(document: doc)
                            }
                        }
                #endif
            }
        }
    }
}

// #Preview {
//    EvalsToBeCorrectedScrollView()
// }
