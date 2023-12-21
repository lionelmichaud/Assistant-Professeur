//
//  UserContext.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/11/2023.
//

import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "UserContext"
)

/// Cette classe mémorise un lien vers l'utilisateur `owner` et
/// un lien ves les préférences de cet utilisateur `prefs`.
///
/// Si le `owner` possède déjà des préférences, elles sont utilisées.
/// Sinon de nouvelles préférences par défaut sont créées.
@Observable
final class UserContext {
    /// Lien vers l'utilisateur `owner` de l'appli.
    @MainActor
    private(set) var owner: OwnerEntity?

    /// Lien ves les préférences de l'utilisateur `owner` de l'appli.
    @MainActor
    var prefs: UserPrefEntity!

    // MARK: - Initializers

    init() {}

    // MARK: - Computed Properties

    /// Valide si :
    /// (1) l'utilisateur `owner` de l'appli est trouvé dans la BDD et
    /// (2) les préférences de l'utilisateur `owner` de l'appli sont trouvées dans la BDD.
    @MainActor
    var isValid: Bool {
        owner != nil && prefs != nil && owner?.prefs == prefs
    }

    // MARK: - Properties

    /// Définir le `owner` du contexte et ses préférences.
    /// - Parameter owner: owner du context
    /// - Note: Si les préférences du `owner` ne sont pas définies, tente
    ///         de les retrouver dans la base de donnée ou les crée.
    @MainActor
    func setOwner(to owner: OwnerEntity?) {
        guard let owner else {
            return
        }

        self.owner = owner

        if let prefs = owner.prefs {
            // Objet Owner avec préférences existantes
            self.prefs = prefs

        } else {
            // Objet Owner sans préférences existantes
            if OwnerEntity.cardinal() == 1 && UserPrefEntity.cardinal() == 1 {
                // Il existe des préférences utilisateurs orphelines,
                // les connecter ensemble.
                owner.prefs = UserPrefEntity.all().first
                self.prefs = owner.prefs!

            } else {
                // La synchro iCloud n'a sans doute pas encore synchronisé les objets OwnerEntity et PrefEntity
                customLog.info(
                    ">> Préférences utilisateur (Owner) de \(owner.userIdentifier ?? "nil") introuvables !"
                )
            }
        }
    }

    @MainActor
    func setPreferences(to prefs: UserPrefEntity) {
        self.prefs = prefs
    }
}
