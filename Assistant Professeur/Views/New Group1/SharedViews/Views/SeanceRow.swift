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
    var seance: Seance
    let showWatchButton: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isShowingClasseTimer = false

    @State
    private var documentToBeViewed: DocumentEntity?

    @State
    private var isDocumentExpanded = false

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
                    coursInfoView
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
                        DeepLinkManager.handle(
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
                   let schoolName = seance.schoolName {
                    Button {
                        isShowingClasseTimer.toggle()
                    } label: {
                        Label("Chrono.", systemImage: "stopwatch")
                            .labelStyle(.iconOnly)
                    }
                    .padding(.leading)
                    .fullScreenCover(isPresented: $isShowingClasseTimer) {
                        NavigationStack {
                            ClasseTimerModal(
                                discipline: classe.disciplineEnum,
                                classeName: classe.displayString,
                                schoolName: schoolName
                            )
                        }
                    }
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

    private var coursInfoView: some View {
        VStack(alignment: .leading) {
            // Pour chaque activité prévue pendant la séance
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
                        // Naviguer vers l'activité pédagogique
                        .onTapGesture {
                            if let sequence = activity.sequence,
                               let program = sequence.program {
                                DeepLinkManager.handle(
                                    navigateTo: .activity(
                                        program: program,
                                        sequence: sequence,
                                        activity: activity
                                    ),
                                    using: navig
                                )
                            }
                        }
                    }
                    Divider()

                    // Nom de l'activité / Documents utilisés
                    VStack(alignment: .leading) {
                        // Nom de l'activité
                        Text(activity.viewName)

                        // Documents de l'activité à distribuer aux élèves ou à stocker sur l'ENT
                        if activity.hasSomeDocumentForEleves || activity.hasSomeDocumentForENT {
                            DisclosureGroup(isExpanded: $isDocumentExpanded) {
                                ForEach(activity.documentsSortedByName) { document in
                                    // N'afficher que les documents destinés aux élèves ou à l'ENT
                                    if document.isForEleve || document.isForENT {
                                        Button {
                                            documentToBeViewed = document
                                        } label: {
                                            Label(
                                                document.viewName,
                                                systemImage: document.destinationImageName
                                            )
                                            Spacer()
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(hClass == .compact ? "Documents élèves" : "Documents destinés aux élèves")
                                    progressDocumentsSymbol(classe: classe, activity: activity)
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

    @ViewBuilder
    func progressDocumentsSymbol(
        classe: ClasseEntity?,
        activity: ActivityEntity
    ) -> some View {
        Group {
            if let classe,
               let progress = ProgressClasseCoordinator.progressFor(thisActivity: activity, thisClasse: classe) {
                if activity.hasSomeDocumentForEleves && !progress.isPrinted {
                    // Documents pas déclarés comme tous imprimés par l'utilisateur
                    Image(systemName: "printer.filled.and.paper").tint(.red)
                }
                if activity.hasSomeDocumentForEleves && progress.isPrinted && !progress.isDistributed {
                    // Documents imprimés mais pas déclarés comme tous distribués par l'utilisateur
                    Image(systemName: "arrow.up.doc").tint(.red)
                }
                if activity.hasSomeDocumentForENT && !progress.isLoaded {
                    // Documents pas déclarés comme tous stockés sur l'ENT
                    Image(systemName: "externaldrive").tint(.red)
                }
            } else {
                EmptyView()
            }
        }
    }
}

// struct NextSeanceRow_Previews: PreviewProvider {
//    static var previews: some View {
//        NextSeanceRow(seance: <#EKEvent#>)
//    }
// }
