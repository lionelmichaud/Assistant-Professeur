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

    var body: some View {
        GroupBox {
            HStack {
                if hClass == .regular {
                    horaireView
                    Divider()
                }
                infoView
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        } label: {
            labelView
        }
    }
}

// MARK: - Subviews

extension SeanceRow {
    private var groupBoxLabelSuite: String {
        if hClass == .regular {
            return ""
        } else {
            return seance.event.startDate.formatted(date: .omitted, time: .shortened) +
                " à " +
                seance.event.endDate.formatted(date: .omitted, time: .shortened)
        }
    }

    private var labelView: some View {
        HStack {
            Text(formattedDate(seance.event.startDate))
                .foregroundColor(.blue2)
                .bold()
            Spacer()

            if let classeName = seance.classeName {
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
                    seance.event.startDate,
                    format: .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                )
                Text(
                    seance.event.endDate,
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

    private var infoView: some View {
        VStack(alignment: .leading) {
            ForEach(seance.activities) { activity in
                HStack(alignment: .center) {
                    VStack {
                        if let discipline = activity.sequence?.program?.disciplineEnum {
                            Text(discipline.acronym)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            if let sequence = activity.sequence {
                                SequenceTagWithPopOver(sequence: sequence)
                            }
                            ActivityTag(activity: activity)
                        }
                    }
                    Divider()

                    VStack(alignment: .leading) {
                        Text(activity.viewName)
                        ForEach(activity.documentsSortedByName) { document in
                            Button {
                                documentToBeViewed = document
                            } label: {
                                Label(
                                    document.viewName,
                                    systemImage: DocumentEntity.defaultImageName
                                )
                            }
                            .padding(.top, 4)
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
