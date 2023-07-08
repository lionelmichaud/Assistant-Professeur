//
//  NextSeanceRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import SwiftUI

struct NextSeanceRow: View {
    var seance: EKEvent

    var body: some View {
        GroupBox {
            HStack {
                horaireView
                infoView
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        } label: {
            Text(formattedDate(seance.startDate))
                .bold()
        }
    }
}

extension NextSeanceRow {
    private var horaireView: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .resizable()
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text(
                    seance.startDate,
                    format: .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                )
                Text(
                    seance.endDate,
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
        Text("Info")
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
