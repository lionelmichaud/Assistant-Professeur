//
//  UserContext.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/11/2023.
//

import SwiftUI

/// Cette classe mémorise un lien vers l'utilisateur `owner` et
/// un lien ves les préférences de cet utilisatur `prefs`.
///
/// Si le `owner` possède déjà des préférences, elles sont utilisées.
/// Sinon de nouvelles préférences par défaut sont créées.
@Observable final class UserContext {
    @MainActor
    private(set) var owner: OwnerEntity?
    
    @MainActor
    var prefs: UserPrefEntity!

    // MARK: - Initializers

    init() {}

    // MARK: - Computed Properties
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
                // Il existe des préférences utilisateurs orphelines
                owner.prefs = UserPrefEntity.all().first
                self.prefs = owner.prefs!

            } else {
                // Créer les préférences utilisateurs
                let userPrefs = UserPrefEntity.created()
                owner.prefs = userPrefs
                self.prefs = userPrefs
            }
        }
    }
}
