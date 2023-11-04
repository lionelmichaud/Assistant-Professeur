//
//  DocsToBePrintedScrollView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

import HelpersView
import SwiftUI

struct BatchOfDocsToBePrinted: Identifiable {
    var id = UUID()
    var classe: ClasseEntity
    var activity: ActivityEntity
    var progress: ActivityProgressEntity
    var documents: [DocumentEntity]
    var quantity: Int
    var beforeDate: Date
}

/// ScrollView présentant une liste de documents à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct DocsToBePrintedScrollView: View {
    @Binding
    var batchesOfDocsToBePrinted: [BatchOfDocsToBePrinted]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(batchesOfDocsToBePrinted) { batch in
                DocsToBePrintedGroupBox(batchOfDocToPrint: batch)
            }
            .emptyListPlaceHolder(batchesOfDocsToBePrinted) {
                ContentUnavailableView(
                    "Aucune impression à réaliser pour le mois à venir...",
                    systemImage: "checklist",
                    description: Text("Les impressions nécessaires au cours du prochain mois apparaîtront ici.")
                )
            }
        }
    }
}

/// GrouepBox présentant un document à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct DocsToBePrintedGroupBox: View {
    let batchOfDocToPrint: BatchOfDocsToBePrinted

    @State
    private var documentToBeViewed: DocumentEntity?

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isPrinted: Bool = false

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
                // Bouton
                printedButton
                    .horizontallyAligned(.leading)
                    .padding(.top, 2)
            }

            // Nb exemplaires - date limite
            HStack {
                if batchOfDocToPrint.quantity > 0 {
                    nbExemplaires
                }
                Spacer()
                dateBeforeView
            }
            .padding(.top, 2)
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .onAppear {
            isPrinted = batchOfDocToPrint.progress.isPrinted
        }
        .onChange(of: isPrinted) {
            batchOfDocToPrint.progress.isPrinted = isPrinted
        }
    }
}

// MARK: - Subviews

extension DocsToBePrintedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Classe
            Button {
                DeepLinkManager.handle(
                    navigateTo: .classeProgressUpdate(classe: batchOfDocToPrint.classe),
                    using: navig
                )
            } label: {
                Text(batchOfDocToPrint.classe.displayString)
            }
            .buttonStyle(.bordered)

            // Tags Séquence/Activité
            if let sequence = batchOfDocToPrint.activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTagWithPopOver(activity: batchOfDocToPrint.activity)
            }
        }
    }

    private var navigateToActivityButton: some View {
        Group {
            if let sequence = batchOfDocToPrint.activity.sequence {
                Button {
                    DeepLinkManager.handle(
                        navigateTo: .activity(
                            program: sequence.program!,
                            sequence: sequence,
                            activity: batchOfDocToPrint.activity
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

    private var printedButton: some View {
        DocPrintedToggle(
            isPrinted: $isPrinted,
            nbExemplaires: nil,
            save: { try? ActivityProgressEntity.saveIfContextHasChanged() }
        )
    }

    private var dateBeforeView: some View {
        HStack {
            Spacer()
            Text("Avant:")
                .foregroundStyle(.secondary)
            Text(formattedDate(batchOfDocToPrint.beforeDate))
        }
    }

    private var documentsView: some View {
        Group {
            ForEach(batchOfDocToPrint.documents) { document in
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

    private var nbExemplaires: some View {
        HStack {
            Text("Nombre d'ex.:")
                .foregroundStyle(.secondary)
            Text("\(batchOfDocToPrint.quantity, format: .number)")
        }
    }
}

// MARK: - Methods

extension DocsToBePrintedGroupBox {
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
//    DocToBePrintedGroupBox()
// }
