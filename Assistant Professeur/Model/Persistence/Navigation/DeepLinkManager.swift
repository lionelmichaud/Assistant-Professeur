//
//  DeepLinkManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/10/2023.
//

import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "DeepLinkManager"
)

/// @MainActor
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

    /// Gérer un deep link URL entrant
    @MainActor
    static func handleIncomingURL(
        _ url: URL,
        using navigationModel: NavigationModel
    ) {
        // Vérifier la légalité de l'URL
        var scheme = ""
        var action = ""
        var components = URLComponents()

        guard urlIsLegal(
            url: url,
            scheme: &scheme,
            action: &action,
            components: &components
        ) else {
            return
        }

        // Exécuter l'action requise
        let urlScheme = "assistprof"
        let urlUpdateProgressAction = "update-progress"

        guard scheme == urlScheme else {
            customLog.error("Detected scheme \(scheme) is not the right one!: \(url)")
            return
        }

        switch action {
            case urlUpdateProgressAction:
                handleUpdateProgressAction(
                    components: components,
                    using: navigationModel
                )

            default:
                // Action : inconnue
                customLog.debug("Action unknown: \(action) in \(url)")
        }
    }

    /// Vérifier la légalité de l'URL reçue.
    /// - Parameters:
    ///   - url: URL reçue
    ///   - scheme: Schéma détecté.
    ///   - action: Action (host) détectée.
    ///   - components: Queries détectés.
    /// - Returns: `false` si l'URL est illégale.
    private static func urlIsLegal(
        url: URL,
        scheme: inout String,
        action: inout String,
        components: inout URLComponents
    ) -> Bool {
        // Vérifier la légalité de l'URL
        guard let _scheme = url.scheme else {
            customLog.debug("No scheme detected in incoming URL: \(url)")
            return false
        }

        guard let _components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            customLog.debug("No compnent detected: \(url)")
            return false
        }

        guard let _action = _components.host else {
            customLog.debug("No action (host) detected: \(url)")
            return false
        }

        scheme = _scheme
        action = _action
        components = _components
        return true
    }

    /// Gérer l'action "update-progress".
    /// - Parameter components: Queries de l'URL reçue.
    @MainActor
    private static func handleUpdateProgressAction(
        components: URLComponents,
        using navigationModel: NavigationModel
    ) {
        // Action : Actualiser la progression d'une classe d'un établissement
        guard let schoolName = components.queryItems?.first(where: { $0.name == "school" })?.value else {
            customLog.debug("School name not found in queries: \(String(describing: components))")
            return
        }
        guard let classeName = components.queryItems?.first(where: { $0.name == "classe" })?.value else {
            customLog.debug("Classe name not found in queries: \(String(describing: components))")
            return
        }

        guard let classe = SchoolEntity.school(withName: schoolName)?.classe(withAcronym: classeName) else {
            customLog.debug("Classe inexistante pour: **\(schoolName) - \(classeName)**")
            return
        }

        handleLink(
            navigateTo: .classeProgressUpdate(classe: classe),
            using: navigationModel
        )
    }

    @MainActor
    static func handleLink(
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
