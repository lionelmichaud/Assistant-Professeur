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
            borderColor: .borderTag,
            borderWidth: 1,
            padding: .init(
                top: 3,
                leading: 6,
                bottom: 3,
                trailing: 6
            )
        )
    }

    /// Style adapté aux Groupes
    static var groupTagStyle = TagCapsuleStyle(
        foregroundColor: .foregroundTag,
        backgroundColor: .groupTag,
        borderColor: .borderTag,
        borderWidth: 2,
        padding: .init(
            top: 5,
            leading: 6,
            bottom: 5,
            trailing: 6
        )
    )

    /// Style adapté aux Séquences pédagogiques
    static var sequenceTagStyle = TagCapsuleStyle(
        foregroundColor: .black,
        backgroundColor: .sequenceTag,
        borderColor: .borderTag,
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
        foregroundColor: .primary,
        backgroundColor: .activityTag,
        borderColor: .borderTag,
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
        foregroundColor: .foregroundTag,
        backgroundColor: .classeTag,
        borderColor: .borderTag,
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
        foregroundColor: .foregroundTag,
        backgroundColor: .disciplineCompTag,
        borderColor: .borderTag,
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
        foregroundColor: .foregroundTag,
        backgroundColor: .workedCompTag,
        borderColor: .borderTag,
        borderWidth: 1,
        padding: .init(
            top: 3,
            leading: 6,
            bottom: 3,
            trailing: 6
        )
    )
}
