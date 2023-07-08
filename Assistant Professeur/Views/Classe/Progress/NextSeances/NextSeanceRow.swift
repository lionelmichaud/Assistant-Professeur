//
//  NextSeanceRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import SwiftUI

struct NextSeanceRow: View {
    var seance: Seance

    @Environment(\.horizontalSizeClass)
    private var hClass

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

extension NextSeanceRow {
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
            Text(groupBoxLabelSuite)
                .foregroundColor(.secondary)
        }
    }

    /// Dates de début et de fin de la séance
    private var horaireView: some View {
        HStack(spacing: 4) {
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
                HStack(alignment: .center, spacing: 4) {
                    SequenceTagWithPopOver(sequence: activity.sequence!)
                    ActivityTag(activity: activity)
                    Text(activity.viewName)
                }
                if activity != seance.activities.last {
                    Divider()
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 1:
                return "demain"

            case 2:
                return "après-demain"

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
