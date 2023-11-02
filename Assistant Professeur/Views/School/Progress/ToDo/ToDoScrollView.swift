//
//  ToDoScrollView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/10/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

/// Liste des documents à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct ToDoScrollView: View {
    let seances: [Seance]

    // MARK: - Internal Types

    enum Action: String, PickableEnumP {
        case print = "Impressions"
        case load = "Partages"

        var pickerString: String { self.rawValue }
        var imageName: String {
            switch self {
                case .print:
                    DocumentEntity.forEleveImageName
                case .load:
                    DocumentEntity.forEntImageName
            }
        }
    }

    /// Un document devant être imprimés en un certain nombre d'exemplaires
    /// avant une certaine date.
    struct DocToBeActionned: Identifiable, CustomStringConvertible {
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
    private var isExpandedPrintings = true
    @State
    private var isExpandedLoadings = true

    /// Tableau des documents à imprimer dans les séances à venir
    @State
    private var docsToBePrinted: [DocToBePrinted] = []

    /// Tableau des documents à charger dans l'ENT dans les séances à venir
    @State
    private var docsToBeLoaded: [DocToBeLoaded] = []

    @State
    private var selectedAction: Action = .print

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Picker("Action", selection: $selectedAction ) {
                    ForEach(Action.allCases, id: \.self) { enu in
                        Label(enu.pickerString, systemImage: enu.imageName)
                    }
                }
                .pickerStyle(.segmented)
            }.padding()

            switch selectedAction {
                case .print:
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(docsToBePrinted) { doc in
                            DocToBePrintedGroupBox(docToPrint: doc)
                        }
                        .emptyListPlaceHolder(docsToBePrinted) {
                            ContentUnavailableView(
                                "Aucune impression à réaliser pour le mois à venir...",
                                systemImage: "checklist",
                                description: Text("Les impressions nécessaires au cours du prochain mois apparaîtront ici.")
                            )
                        }
                    }

                case .load:
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(docsToBeLoaded) { doc in
                            DocToBeLoadedGroupBox(docToLoad: doc)
                        }
                        .emptyListPlaceHolder(docsToBeLoaded) {
                            ContentUnavailableView(
                                "Aucun partage à réaliser pour le mois à venir...",
                                systemImage: "checklist",
                                description: Text("Les partages nécessaires au cours du prochain mois apparaîtront ici.")
                            )
                        }
                    }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("A faire dans le mois à venir")
        #endif
        .task(id: selectedAction) {
            switch selectedAction {
                case .print:
                    getAllDocsToBeActioned(action: .print)
                case .load:
                    getAllDocsToBeActioned(action: .load)
            }
        }
    }

    // MARK: - Methods

    /// Recherche tous les documents à imprimer/partager dans les séances à venir
    /// et calcule le nombre d'exemplaires à imprimer et la date au plus tard.
    private func getAllDocsToBeActioned(
        action: Action
    ) {
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
        var docsToBeActionned = [DocToBeActionned]()

        seancesToProcess.forEach { seance in
            // Pour la séance
            guard let schoolName = seance.schoolName,
                  let classeName = seance.name,
                  let classe = SchoolEntity
                  .school(withName: schoolName)?
                  .classe(withAcronym: classeName) else {
                return
            }
            let dateSeance = seance.interval.start

            seance.activities.forEach { activity in
                // Pour chaque activité inclue dans la séance
                let activityHasSomeDocToBeActionned =
                    switch action {
                    case .print:
                        activity.hasSomeDocumentForEleves
                    case .load:
                        activity.hasSomeDocumentForENT
                }

                guard activityHasSomeDocToBeActionned,
                      let progress = ProgressClasseCoordinator
                      .progressFor(thisActivity: activity, thisClasse: classe) else {
                    return
                }

                let activityIsAlreadyActionned =
                    switch action {
                    case .print:
                        progress.isPrinted
                    case .load:
                        progress.isLoaded
                }

                guard !activityIsAlreadyActionned else {
                    return
                }

                // Pour les documents de l'activité qui ne sont pas imprimés/uploadés
                activity.allDocuments.forEach { document in
                    // Ajouter, si nécessaire, le document de l'activité à la liste des docs à actionner
                    if action == .print && document.isForEleve ||
                        action == .load && document.isForENT {
                        docsToBeActionned.append(
                            DocToBeActionned(
                                classe: classe,
                                document: document,
                                beforeDate: dateSeance
                            )
                        )
                    }
                }
            }
        }

        // Compilation des actions à réaliser
        switch action {
            case .print:
                // Supprimer les doublons (Classe, Document)
                var actions = [DocToBeActionned]()
                for element in docsToBeActionned where !actions.contains(where: {
                    $0.document == element.document && $0.classe == element.classe
                }) {
                    actions.append(element)
                }

                docsToBePrinted = []
                actions.forEach { action in
                    docsToBePrinted.append(
                        DocToBePrinted(
                            classe: action.classe,
                            document: action.document,
                            quantity: action.classe.nbOfEleves,
                            beforeDate: action.beforeDate
                        )
                    )
                }

            case .load:
                // Supprimer les doublons (Niveau de classe, Document)
                var actions = [DocToBeActionned]()
                for element in docsToBeActionned where !actions.contains(where: {
                    $0.document == element.document && $0.classe.levelEnum == element.classe.levelEnum
                }) {
                    actions.append(element)
                }

                docsToBeLoaded = []
                actions.forEach { action in
                    docsToBeLoaded.append(
                        DocToBeLoaded(
                            classeLevel: action.classe.levelEnum,
                            document: action.document,
                            beforeDate: action.beforeDate
                        )
                    )
                }
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
