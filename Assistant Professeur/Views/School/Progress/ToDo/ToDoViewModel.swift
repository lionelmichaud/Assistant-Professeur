//
//  ToDoViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/11/2023.
//

import Foundation

/// Un document devant être imprimés en un certain nombre d'exemplaires
/// avant une certaine date.
struct BatchOfDocToBeActionned: Identifiable, CustomStringConvertible {
    var id = UUID()
    var classe: ClasseEntity
    var activity: ActivityEntity
    var progress: ActivityProgressEntity
    var documents: [DocumentEntity]
    var beforeDate: Date

    var description: String {
        "\nClasse  : \(classe.displayString)" +
            "\(documents.description)\n" +
            "Quantité: \(classe.nbOfEleves)\n" +
            "Date    : \(beforeDate.formatted(date: .abbreviated, time: .omitted))\n"
    }
}

@MainActor
class ToDoViewModel: ObservableObject {
    /// Tableau des documents à imprimer dans les séances à venir
    @Published
    var batchesOfDocsToBePrinted: [BatchOfDocsToBePrinted] = []

    /// Tableau des documents à charger dans l'ENT dans les séances à venir
    @Published
    var batchesOfDocsToBeLoaded: [BatchOfDocsToBeLoaded] = []

    /// Recherche tous les documents à imprimer/partager dans les séances à venir
    /// et calcule le nombre d'exemplaires à imprimer et la date au plus tard.
    func getAllDocsToBeActioned(
        fromSeances seances: [Seance],
        forThisAction action: ToDoAction
    ) async {
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
        var batchesOfDocsToBeActionned = [BatchOfDocToBeActionned]()

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

                // Liste de documents actionnables pour cette activité
                let actionableDocuments = activity.allDocuments.filter {
                    switch action {
                        // Liste de documents imprimable de l'activité
                        case .print: $0.isForEleve
                        // Liste de documents partageables de l'activité
                        case .load: $0.isForENT
                    }
                }

                batchesOfDocsToBeActionned.append(
                    BatchOfDocToBeActionned(
                        classe: classe,
                        activity: activity,
                        progress: progress,
                        documents: actionableDocuments,
                        beforeDate: dateSeance
                    )
                )
            }
        }

        // Compilation des actions à réaliser
        filterDocsToBeActioned(
            batchesOfDocsToBeActionned: batchesOfDocsToBeActionned,
            forThisAction: action
        )
    }

    private func filterDocsToBeActioned(
        batchesOfDocsToBeActionned: [BatchOfDocToBeActionned],
        forThisAction action: ToDoAction
    ) {
        // Compilation des actions à réaliser
        switch action {
            case .print:
                /// Supprimer les doublons (Activité, Classe)
                var batches = [BatchOfDocToBeActionned]()
                for element in batchesOfDocsToBeActionned where !batches.contains(where: {
                    $0.activity == element.activity && $0.classe == element.classe
                }) {
                    batches.append(element)
                }

                batchesOfDocsToBePrinted = []
                batches.forEach { batch in
                    batchesOfDocsToBePrinted.append(
                        BatchOfDocsToBePrinted(
                            classe: batch.classe,
                            activity: batch.activity,
                            progress: batch.progress,
                            documents: batch.documents,
                            quantity: batch.classe.nbOfEleves,
                            beforeDate: batch.beforeDate
                        )
                    )
                }

            case .load:
                /// Supprimer les doublons (Activité, Niveau de classe,)
                var batches = [BatchOfDocToBeActionned]()
                for element in batchesOfDocsToBeActionned where !batches.contains(where: {
                    $0.activity == element.activity && $0.classe.levelEnum == element.classe.levelEnum
                }) {
                    batches.append(element)
                }

                batchesOfDocsToBeLoaded = []
                batches.forEach { batch in
                    batchesOfDocsToBeLoaded.append(
                        BatchOfDocsToBeLoaded(
                            classeLevel: batch.classe.levelEnum,
                            activity: batch.activity,
                            documents: batch.documents,
                            beforeDate: batch.beforeDate
                        )
                    )
                }
        }
    }
}
