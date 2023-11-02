//
//  ToBePrinted.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/10/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

struct DocToBePrinted: Identifiable {
    var id = UUID()
    var classe: ClasseEntity
    var document: DocumentEntity
    var quantity: Int
    var beforeDate: Date
}

/// Liste des documents à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct ToBePrintedDisclosureGroup: View {
    let seances: [Seance]

    /// Un document devant être imprimés en un certain nombre d'exemplaires
    /// avant une certaine date.
    struct Printing: Identifiable, CustomStringConvertible {
        var id = UUID()
        var classe: ClasseEntity
        var document: DocumentEntity
        var beforeDate: Date

        var description: String {
            "\nClasse  : \(classe.displayString)" +
                "\(document.description)\n" +
                "Quantité: \(classe.nbOfEleves)\n" +
                "Date    : \(beforeDate.formatted(date: .abbreviated, time: .omitted))\n"
        }
    }

    @State
    private var isExpanded = true

    /// Tableau des documents à imprimer dans les séances à venir
    @State
    private var docsToBePrinted: [DocToBePrinted] = []

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(docsToBePrinted) { doc in
                DocToBePrintedGroupBox(
                    classe: doc.classe,
                    document: doc.document,
                    quantity: doc.quantity,
                    beforeDate: doc.beforeDate
                )
            }
            .emptyListPlaceHolder(docsToBePrinted) {
                ContentUnavailableView(
                    "Aucune impression à réaliser pour le moi à venir...",
                    systemImage: "checklist",
                    description: Text("Les impressions nécessaires au cours du prochain mois apparaîtront ici.")
                )
            }
        } label: {
            Label("A imprimer pour le mois à venir (\(docsToBePrinted.count, format: .number))", systemImage: "printer")
                .font(.headline)
                .padding(.bottom)
        }
        .padding(.leading)
        .task {
            getAllDocsToBePrinted()
        }
    }

    // MARK: - Methods

    /// Recherche tous les documents à imprimer dans les séances à venir
    /// et calcule le nombre d'exemplaires et la date au plus tard.
    private func getAllDocsToBePrinted() {
        guard seances.isNotEmpty else {
            return
        }

        // Colecter tous les documents restant à imprimer
        let nbSeancesToProcess = 4 * 18 // 3 semaines de cours en temps complet
        let maxIndex = (seances.startIndex + nbSeancesToProcess)
            .clamp(
                low: seances.startIndex,
                high: seances.endIndex - 1
            )
        let seancesToProcess = seances[seances.startIndex ... maxIndex]
        var printings = [Printing]()

        seancesToProcess.forEach { seance in
            // Pour la séance
            guard let schoolName = seance.schoolName,
                  let classeName = seance.name,
                  let classe = SchoolEntity
                  .school(withName: schoolName)?
                  .classe(withAcronym: classeName) else {
                return
            }

            seance.activities.forEach { activity in
                // Pour chaque activité inclue dans la séance
                guard activity.hasSomeDocumentForEleves,
                      let progress = ProgressClasseCoordinator.progressFor(thisActivity: activity, thisClasse: classe),
                      !progress.isPrinted else {
                    return
                }
                let dateSeance = seance.interval.start

                // Les documents de l'activité ne sont pas imprimés
                activity.allDocuments.forEach { document in
                    // Ajouter tous les documents de l'activité à la liste des docs à imprimer
                    if document.isForEleve {
                        printings.append(
                            Printing(
                                classe: classe,
                                document: document,
                                beforeDate: dateSeance
                            )
                        )
                    }
                }
            }
        }

        // Supprimer les doublons (Classe, Document)
        var uniquePrintings = [Printing]()
        for element in printings where !uniquePrintings.contains(where: {
            $0.document == element.document && $0.classe == element.classe
        }) {
            uniquePrintings.append(element)
        }

        // Cumuler les quantités de documents à imprimer et
        // calculer la date au plus tard de l'impression

        docsToBePrinted = []
        uniquePrintings.forEach { printing in
            docsToBePrinted.append(
                DocToBePrinted(
                    classe: printing.classe,
                    document: printing.document,
                    quantity: printing.classe.nbOfEleves,
                    beforeDate: printing.beforeDate
                )
            )
        }
    }
}

/// GrouepBox présentant un document à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct DocToBePrintedGroupBox: View {
    var classe: ClasseEntity
    var document: DocumentEntity
    var quantity: Int
    var beforeDate: Date

    @State
    private var documentToBeViewed: DocumentEntity?

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Classe
            Button {
                DeepLinkManager.handle(
                    navigateTo: .classeProgressUpdate(classe: classe),
                    using: navig
                )
            } label: {
                Text(classe.displayString)
            }
            .buttonStyle(.bordered)

            // Tags Séquence/Activité
            if let activity = document.activity,
               let sequence = activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTag(activityNumber: activity.viewNumber)
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

    private var documentView: some View {
        Button {
            documentToBeViewed = document
        } label: {
            Text(document.viewName)
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

    var body: some View {
        GroupBox {
            if hClass == .regular {
                HStack {
                    // Classe - Discipline - Sequence - Activité
                    classeSequenceActivityView
                    Spacer()
                    // Document
                    documentView
                }
            } else {
                VStack(alignment: .leading) {
                    // Classe - Discipline - Sequence - Activité
                    classeSequenceActivityView
                    // Document
                    documentView
                }
                .horizontallyAligned(.leading)
            }

            HStack {
                if quantity > 0 {
                    HStack {
                        Text("Nombre d'ex.:")
                            .foregroundStyle(.secondary)
                        Text("\(quantity, format: .number)")
                    }
                }
                Spacer()
                HStack {
                    Text("Avant:")
                        .foregroundStyle(.secondary)
                    Text(formattedDate(beforeDate))
                }
            }
            .padding(.top, 2)
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    // MARK: - Methods

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

// #Preview("DocToBePrintedView") {
//    DisclosureGroup(isExpanded: .constant(true)) {
//        DocToBePrintedGroupBox(
//            levelClasse: LevelClasse.n3ieme.displayString,
//            title: "Le nom du document à imprimer qui est très très long et ne tient pas sur une seule ligne",
//            quantity: 64,
//            beforeDate: .now
//        )
//        DocToBePrintedGroupBox(
//            levelClasse: LevelClasse.n0terminale.displayString,
//            title: "Le nom d'un autre document à imprimer qui est très très long et ne tient pas sur une seule ligne",
//            quantity: 128,
//            beforeDate: 1.months.fromNow!
//        )
//    } label: {
//        Label("A imprimer pour le mois à venir", systemImage: "printer")
//            .font(.headline)
//            .fontWeight(.bold)
//            .padding(.bottom)
//    }
//    .padding(.leading)
// }
