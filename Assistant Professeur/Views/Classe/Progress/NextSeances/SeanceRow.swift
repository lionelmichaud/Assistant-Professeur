//
//  NextSeanceRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import SwiftUI

struct SeanceRow: View {
    var seance: Seance
    let classeName: String? = nil

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var documentToBeViewed: DocumentEntity?

    @State
    private var isDocumentExpanded = false

    var body: some View {
        GroupBox {
            HStack {
                if hClass == .regular && !seance.isVacance {
                    horaireView
                    Divider()
                }
                if seance.isVacance {
                    vacancesInfoView
                } else {
                    coursInfoView
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

        } label: {
            if seance.isVacance {
                vacancesLabelView
            } else {
                coursLabelView
            }
        }
    }
}

// MARK: - Subviews

extension SeanceRow {
    private var groupBoxLabelSuite: String {
        if hClass == .regular {
            return ""
        } else {
            return seance.interval.start.formatted(date: .omitted, time: .shortened) +
                " à " +
                seance.interval.end.formatted(date: .omitted, time: .shortened)
        }
    }

    private var vacancesLabelView: some View {
        HStack {
            Text(formattedDate(seance.interval.start))
            Spacer()
            Image(systemName: "arrowshape.right")
                .symbolVariant(.fill)
            Spacer()
            Text(formattedDate(seance.interval.end))
        }
        .foregroundColor(.orange)
        .bold()
    }

    private var coursLabelView: some View {
        HStack {
            Text(formattedDate(seance.interval.start))
                .foregroundColor(.blue2)
                .bold()
            Spacer()

            if let classeName = seance.name {
                Text(classeName)
                    .foregroundColor(.blue2)
                    .bold()
                Spacer()
            }

            Text(groupBoxLabelSuite)
                .foregroundColor(.secondary)
        }
    }

    /// Dates de début et de fin de la séance
    private var horaireView: some View {
        HStack {
            Image(systemName: "clock")
                .resizable()
                .frame(width: 25, height: 25)
            VStack(alignment: .leading) {
                Text(
                    seance.interval.start,
                    format: .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                )
                Text(
                    seance.interval.end,
                    format: .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                )
            }
            .font(.system(size: 20, design: .monospaced))
            .fontWeight(.semibold)
        }
        .foregroundColor(.secondary)
    }

    private var coursInfoView: some View {
        VStack(alignment: .leading) {
            ForEach(seance.activities) { activity in
                HStack(alignment: .center) {
                    VStack {
                        // Discipline
                        if let discipline = activity.sequence?.program?.disciplineEnum {
                            Text(discipline.acronym)
                                .foregroundColor(.secondary)
                        }
                        // Tags Séquence/Activité
                        HStack {
                            if let sequence = activity.sequence {
                                SequenceTagWithPopOver(sequence: sequence)
                            }
                            ActivityTag(activity: activity)
                        }
                    }
                    Divider()

                    // Nom de l'activité / Documents utilisés
                    VStack(alignment: .leading) {
                        // Nom de l'activité
                        Text(activity.viewName)

                        // Documents utilisés
                        if activity.nbOfDocuments != 0 {
                            DisclosureGroup("Documents", isExpanded: $isDocumentExpanded) {
                                ForEach(activity.documentsSortedByName) { document in
                                    Button {
                                        documentToBeViewed = document
                                    } label: {
                                        Label(
                                            document.viewName,
                                            systemImage: DocumentEntity.defaultImageName
                                        )
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }

                    Spacer()
                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: false
                    )
                }
                if activity != seance.activities.last {
                    Divider()
                }
            }
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

    private var vacancesInfoView: some View {
        Text(seance.name ?? "Vacances")
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.25))
    }

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

// struct NextSeanceRow_Previews: PreviewProvider {
//    static var previews: some View {
//        NextSeanceRow(seance: <#EKEvent#>)
//    }
// }
