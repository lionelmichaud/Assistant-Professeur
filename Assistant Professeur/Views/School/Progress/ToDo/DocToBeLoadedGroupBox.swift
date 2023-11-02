//
//  DocToBeLoadedGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

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

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        GroupBox {
            if hClass == .regular {
                VStack {
                    HStack {
                        // Classe - Discipline - Sequence - Activité
                        classeSequenceActivityView
                        Spacer()
                        navigateToActivityButton
                    }
                    HStack {
                        // Document
                        documentView
                        Spacer()
                        dateBeforeView
                    }
                    .padding(.top, 2)
                }
            } else {
                VStack(alignment: .leading) {
                    // Classe - Discipline - Sequence - Activité
                    HStack {
                        classeSequenceActivityView
                        Spacer()
                        navigateToActivityButton
                    }
                    // Document
                    documentView
                        .padding(.top, 2)
                    dateBeforeView
                        .padding(.top, 2)
                }
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
