//
//  DocsToBeLoadedScrollView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

import HelpersView
import SwiftUI

/// ScrollView présentant une liste de documents à partager
/// sur l'ENT avant une certaine date
struct DocsToBeLoadedScrollView: View {
    let seances: [Seance]

    @State
    private var toDoViewModel = ToDoViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            switch toDoViewModel.status {
                case .pending, .computing, .failed:
                    toDoViewModel.status.view
                        .horizontallyAligned(.center)
                case .finished:
                    ForEach(toDoViewModel.batchesOfDocsToBeLoaded) { batch in
                        DocsToBeLoadedGroupBox(batchOfDocToLoad: batch)
                    }
                    .emptyListPlaceHolder(toDoViewModel.batchesOfDocsToBeLoaded) {
                        ContentUnavailableView(
                            "Aucun partage à réaliser pour le mois à venir...",
                            systemImage: "checklist",
                            description: Text("Les partages nécessaires au cours du prochain mois apparaîtront ici.")
                        )
                    }
            }
        }
        .task {
            await toDoViewModel.getAllDocsToBeActioned(
                fromSeances: seances,
                forThisAction: ToDoAction.load
            )
        }
    }
}

struct DocsToBeLoadedGroupBox: View {
    let batchOfDocToLoad: BatchOfDocsToBeLoaded

    @State
    private var documentToBeViewed: DocumentEntity?

    @State
    private var isLoaded: Bool = false

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    var label: String {
        if hClass == .compact {
            "Ressources chargées"
        } else {
            "Ressources chargées sur ENT"
        }
    }

    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    // Classe - Discipline - Sequence - Activité
                    classeSequenceActivityView
                    Spacer()
                    navigateToActivityButton
                }

                // Document
                documentsView
                    .horizontallyAligned(.leading)
                    .padding(.top, 2)

                HStack {
                    uploadedButton
                    Spacer()
                    dateBeforeView
                }
                .padding(.top, 2)
            }
        }
        .onAppear {
            isLoaded = batchOfDocToLoad.activity.allProgresses.allSatisfy { $0.isLoaded }
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

// MARK: - Subviews

extension DocsToBeLoadedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Niveau de Classe
            Text(batchOfDocToLoad.classeLevel.pickerString)

            // Tags Séquence/Activité
            if let sequence = batchOfDocToLoad.activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTagWithPopOver(activity: batchOfDocToLoad.activity)
            }
        }
    }

    private var uploadedButton: some View {
        DocLoadedToggle(
            isLoaded: $isLoaded,
            save: { newValue in
                batchOfDocToLoad.activity.allProgresses.forEach { prog in
                    prog.isLoaded = newValue
                }
                try? ActivityProgressEntity.saveIfContextHasChanged()
            }
        )
        .buttonStyle(.plain)
    }

    private var navigateToActivityButton: some View {
        Group {
            if let sequence = batchOfDocToLoad.activity.sequence {
                Button {
                    DeepLinkManager.handle(
                        navigateTo: .activity(
                            program: sequence.program!,
                            sequence: sequence,
                            activity: batchOfDocToLoad.activity
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

    private var dateBeforeView: some View {
        HStack {
            Spacer()
            Text("Avant:")
                .foregroundStyle(.secondary)
            Text(formattedDate(batchOfDocToLoad.beforeDate))
        }
    }

    private var documentsView: some View {
        Group {
            ForEach(batchOfDocToLoad.documents) { document in
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

// MARK: - Methods

extension DocsToBeLoadedGroupBox {
    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 0:
                return "Aujourd'hui"

            case 1:
                return "Demain"

            case 2:
                return "Après-demain"

            case 3 ... 6:
                return "\(date.formatted(Date.FormatStyle().weekday(.wide))) prochain"

            default:
                return date
                    .formatted(Date.FormatStyle()
                        .weekday(.wide)
                        .day(.twoDigits)
                        .month(.twoDigits))
        }
    }
}

// #Preview {
//    DocToBeLoadedGroupBox()
// }
