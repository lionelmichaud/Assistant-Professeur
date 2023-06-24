//
//  TagCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/06/2023.
//

import HelpersView
import SwiftUI
import TagKit

/// Styles de capsules
extension TagCapsuleStyle {
    /// Style adapté aux Niveaux de classe
    static func levelTagStyle(level: LevelClasse) -> TagCapsuleStyle {
        TagCapsuleStyle(
            foregroundColor: .black,
            backgroundColor: level.imageColor,
            borderColor: .primary,
            borderWidth: 1,
            padding: .init(
                top: 3,
                leading: 6,
                bottom: 3,
                trailing: 6
            )
        )
    }

    /// Style adapté aux Séquences pédagogiques
    static var sequenceTagStyle = TagCapsuleStyle(
        foregroundColor: .black,
        backgroundColor: .blue4,
        borderColor: .primary,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )

    /// Style adapté aux Activités pédagogiques
    static var activityTagStyle = TagCapsuleStyle(
        foregroundColor: .black,
        backgroundColor: .blue2,
        borderColor: .primary,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )

    /// Style adapté aux Classes
    static var classeTagStyle = TagCapsuleStyle(
        foregroundColor: .primary,
        backgroundColor: .blue5,
        borderColor: .primary,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )

    /// Style adapté aux Compétences disciplinaires
    static var disciplineCompTagStyle = TagCapsuleStyle(
        foregroundColor: .primary,
        backgroundColor: .blue6,
        borderColor: .primary,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )

    /// Style adapté aux Compétences socle travaillées
    static var workedCompTagStyle = TagCapsuleStyle(
        foregroundColor: .primary,
        backgroundColor: .blue7,
        borderColor: .primary,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )
}
