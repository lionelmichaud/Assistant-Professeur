//
//  DocToBeLoadedGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

import HelpersView
import SwiftUI

struct DocToBeLoaded: Identifiable {
    var id = UUID()
    var classeLevel: LevelClasse
    var document: DocumentEntity
    var beforeDate: Date
}

struct DocToBeLoadedGroupBox: View {
    let docToLoad: DocToBeLoaded

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
            "Ressource chargée"
        } else {
            "Ressource chargée sur ENT"
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
                documentView
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
        .task {
            if let activity = docToLoad.document.activity {
                isLoaded = activity.allProgresses.allSatisfy { $0.isLoaded }
            }
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

// MARK: - Subviews

extension DocToBeLoadedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Niveau de Classe
            Text(docToLoad.classeLevel.pickerString)

            // Tags Séquence/Activité
            if let activity = docToLoad.document.activity,
               let sequence = activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTagWithPopOver(activity: activity)
                    // Naviguer vers l'activité pédagogique
                    .onTapGesture {
                        DeepLinkManager.handle(
                            navigateTo: .activity(
                                program: sequence.program!,
                                sequence: sequence,
                                activity: activity
                            ),
                            using: navig
                        )
                    }
            }
        }
    }

    private var uploadedButton: some View {
        Group {
            if let activity = docToLoad.document.activity {
                Button {
                    isLoaded.toggle()
                    activity.allProgresses.forEach { prog in
                        prog.isLoaded = isLoaded
                    }
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                } label: {
                    Label(
                        title: {
                            Text(label)
                        }, icon: {
                            Image(systemName: isLoaded ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isLoaded ? .green : .gray)
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var navigateToActivityButton: some View {
        Group {
            if let activity = docToLoad.document.activity,
               let sequence = activity.sequence {
                Button {
                    DeepLinkManager.handle(
                        navigateTo: .activity(
                            program: sequence.program!,
                            sequence: sequence,
                            activity: activity
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
            Text(formattedDate(docToLoad.beforeDate))
        }
    }

    private var documentView: some View {
        Button {
            documentToBeViewed = docToLoad.document
        } label: {
            Text(docToLoad.document.viewName)
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

// MARK: - Methods

extension DocToBeLoadedGroupBox {
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
