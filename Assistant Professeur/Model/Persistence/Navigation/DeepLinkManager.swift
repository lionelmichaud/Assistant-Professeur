//
//  DeepLinkManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/10/2023.
//

import Foundation

//@MainActor
enum DeepLinkManager {
    enum Destination {
        case classe(
            classe: ClasseEntity)

        case classeProgressUpdate(
            classe: ClasseEntity)

        case eleve(
            eleve: EleveEntity)

        case activity(
            program: ProgramEntity,
            sequence: SequenceEntity,
            activity: ActivityEntity
        )
    }

    static func handle(
        navigateTo destination: Destination,
        using navigationModel: NavigationModel
    ) {
        switch destination {
            case let .classe(classe):
                Task {
                    await navigationModel
                        .navigateTo(thisClasse: classe)
                }

            case let .classeProgressUpdate(classe):
                Task {
                    await navigationModel
                        .navigateToProgressOf(thisClasse: classe)
                }

            case let .eleve(eleve):
                Task {
                    await navigationModel
                        .navigateTo(thisEleve: eleve)
                }

            case let .activity(program, sequence, activity):
                Task {
                    await navigationModel
                        .navigateToActivity(
                            activity: activity,
                            inSequence: sequence,
                            inProgram: program
                        )
                }
        }
    }
}
