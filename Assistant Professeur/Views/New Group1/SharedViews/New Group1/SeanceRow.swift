//
//  NextSeanceRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import SwiftUI

/// Affichage du contenu de la prochaine séance
/// Si plusieurs activités sont programmées, chacune est affichée
struct SeanceRow: View {
    let seance: Seance
    let showWatchButton: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isShowingClasseTimer = false

    private var classe: ClasseEntity? {
        guard let schoolName = seance.schoolName,
              let classeName = seance.name else {
            return nil
        }
        return SchoolEntity.school(withName: schoolName)?.classe(withAcronym: classeName)
    }

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
                    CoursInfoView(seance: seance)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            // Boutons
            HStack {
                // Navigation vers la page d'actualisation de la progression
                if let classe {
                    Button {
                        DeepLinkManager.handleLink(
                            navigateTo: .classeProgressUpdate(classe: classe),
                            using: navig
                        )
                    } label: {
                        Label(
                            "Actualiser la progression",
                            systemImage: "figure.walk.motion"
                        )
                    }
                }

                // Chronomètre de classe
                if showWatchButton,
                   let classe,
                   let school = classe.school {
                    Button {
                        isShowingClasseTimer.toggle()
                    } label: {
                        Label("Chrono.", systemImage: "stopwatch")
                            .labelStyle(.iconOnly)
                    }
                    .padding(.leading)
                    .fullScreenCover(
                        isPresented: $isShowingClasseTimer,
                        onDismiss: {
                            if let seance = TodaySeances.shared.seanceOngoing(inSchool: school),
                               let classe = SchoolEntity.school(withName: seance.schoolName!)?.classe(withAcronym: seance.name!) {
                                DeepLinkManager.handleLink(
                                    navigateTo: .classeProgressUpdate(classe: classe),
                                    using: navig
                                )
                            }
                        },
                        content: {
                            NavigationStack {
                                ClasseTimerModal(
                                    school: school
                                )
                            }
                        }
                    )
                }
            }
            .buttonStyle(.bordered)
            .padding(.top)

        } label: {
            if seance.isVacance {
                vacancesLabelView
            } else {
                coursLabelView
            }
        }
    }
}

// MARK: - Metods

extension SeanceRow {
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

    private var vacancesInfoView: some View {
        Text(seance.name ?? "Vacances")
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.25))
    }
}

// struct NextSeanceRow_Previews: PreviewProvider {
//    static var previews: some View {
//        NextSeanceRow(seance: <#EKEvent#>)
//    }
// }
