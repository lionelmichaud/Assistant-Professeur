//
//  GroupManager.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 27/09/2022.
//

import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "GroupManager"
)

/// Gestionnaire de groupe d'élèves au sein d'une classe
enum GroupManager {
    /// Affecte un `eleve`au groupe n°`toGroupNumber`de sa classe
    /// - Parameters:
    ///   - toGroupNumber: groupe d'affectation
    /// - Important: The context has changes and **is commited**
    static func assign(
        eleve: EleveEntity,
        toGroupNumber: Int
    ) {
        eleve.group = eleve.classe!.groupe(number: toGroupNumber)
        try? EleveEntity.saveIfContextHasChanged()
    }

    /// Retire un `eleve`de son groupe et le rend non affecté
    /// en l'affectant au grouep 0 des élèves non affectés.
    /// - Important: The context has changes and **is commited**
    static func unassignFromItsGroup(eleve: EleveEntity) {
        eleve.group = eleve.classe!.groupOfUngroupedEleves
        try? EleveEntity.saveIfContextHasChanged()
    }

    /// permuter deux élèves entre leur groupe respectif.
    /// - Parameters:
    ///   - eleve1: Elève à permuter
    ///   - eleve2: Avec cet élève
    /// - Important: The context has changes and **is commited**
    static func permuter(
        thisEleve eleve1: EleveEntity,
        withThisEleve eleve2: EleveEntity
    ) {
        guard eleve1.isGrouped && eleve2.isGrouped else {
            customLog.log(
                level: .error,
                "Tentative de permuter deux élèves dont l'un au moins n'appartient à aucun groupe."
            )
            return
        }
        guard eleve1.classe == eleve2.classe else {
            customLog.log(
                level: .error,
                "Tentative de permuter deux élèves qui n'appartiennent pas à la même classe."
            )
            return
        }
        if let groupe1Number = eleve1.group?.viewNumber,
           let groupe2Number = eleve2.group?.viewNumber {
            eleve1.group = eleve1.classe!.groupe(number: groupe2Number)
            eleve2.group = eleve2.classe!.groupe(number: groupe1Number)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Former les groupes par ordre alphabétique dans la `classe`.
    /// - Parameters:
    ///   - nbEleveParGroupe: nombre d'élève idéal par groupe
    ///   - classe: dans cette classe
    /// - Important: The context has changes and **is commited**
    static func formOrderedGroups(
        nbEleveParGroupe: Int,
        dans classe: ClasseEntity,
        nameSortOrderEnum: NameOrdering
    ) {
        func formRegularGroups(nbOfGroups: Int) {
            for idx in eleves.indices {
                let (q, _) = idx.quotientAndRemainder(dividingBy: nbEleveParGroupe)
                // ajouter l'élève au groupe n°(q+1)
                if q + 1 <= nbOfGroups {
                    let groupe = classe.groupe(number: q + 1)
                    eleves[idx].group = groupe
                }
            }
        }

        let eleves = classe.elevesSortedByName(nameSortOrderEnum)
        let nbEleves = eleves.count
        guard nbEleves > 0 else {
            return
        }
        let (nbGroupes, reste) = nbEleves.quotientAndRemainder(dividingBy: nbEleveParGroupe)
        let distributeRemainder = reste > 0 && (reste.double() < nbEleveParGroupe.double() / 2.0)

        if reste == 0 {
            // nombre entier de groupes complets
            recreate(nbOfGroups: nbGroupes, dans: classe)
            formRegularGroups(nbOfGroups: nbGroupes)

        } else if distributeRemainder {
            // les élèves formant un groupe incomplet sont redistribués sur les derniers groupes complets
            let nbOfRegularGroups = nbGroupes - reste
            let firstRemainEleveIndex = nbOfRegularGroups * nbEleveParGroupe
            recreate(nbOfGroups: nbGroupes, dans: classe)
            formRegularGroups(nbOfGroups: nbGroupes)
            for groupNum in nbOfRegularGroups + 1 ... nbOfRegularGroups + reste {
                for i in 0 ... nbEleveParGroupe {
                    // inclure l'élève dans le groupe numéro `groupNum`
                    eleves[firstRemainEleveIndex + i * (groupNum - nbOfRegularGroups)].group = classe.groupe(number: groupNum)
                }
            }

        } else {
            // le dernier groupe est laissé incomplet
            recreate(nbOfGroups: nbGroupes + 1, dans: classe)
            formRegularGroups(nbOfGroups: nbGroupes)
            for idx in (eleves.endIndex - reste) ... eleves.endIndex - 1 {
                eleves[idx].group = classe.groupe(number: nbGroupes + 1)
            }
        }

        try? EleveEntity.saveIfContextHasChanged()
    }

    /// Former les groupes aléatoirement dans la `classe`.
    /// - Parameters:
    ///   - nbEleveParGroupe: nombre d'élève idéal par groupe
    ///   - classe: dans cette classe
    static func formRandomGroups(
        nbEleveParGroupe: Int,
        dans classe: ClasseEntity,
        nameSortOrderEnum: NameOrdering
    ) {
        func nextGroupe(
            num: inout Int,
            nbOfGroups: Int
        ) {
            if num == nbOfGroups {
                num = 1
            } else {
                num += 1
            }
        }

        func formRandomGroups(nbOfGroups: Int) {
            var numGroupe = 1

            while eleves.isNotEmpty {
                // prendre un élève au hazard dans la classe
                guard let eleve = eleves.randomElement() else {
                    break
                }
                // le retirer de la liste des élèves
                eleves = eleves.filter { $0 != eleve }

                // le ranger dans un groupe
                eleve.group = classe.groupe(number: numGroupe)
                nextGroupe(num: &numGroupe, nbOfGroups: nbOfGroups)
            }
        }

        var eleves = classe.elevesSortedByName(nameSortOrderEnum)
        let nbEleves = eleves.count
        guard nbEleves > 0 else {
            return
        }
        let (nbGroupes, reste) = nbEleves.quotientAndRemainder(dividingBy: nbEleveParGroupe)

        if reste == 0 {
            // nombre entier de groupes complets
            recreate(nbOfGroups: nbGroupes, dans: classe)
            formRandomGroups(nbOfGroups: nbGroupes)
        } else {
            recreate(nbOfGroups: nbGroupes + 1, dans: classe)
            formRandomGroups(nbOfGroups: nbGroupes + 1)
        }
    }

    static func addGroup(dans classe: ClasseEntity) {
        let largestGroupNumber = classe.allGroups.max(\.number)

        GroupEntity.create(
            numero: largestGroupNumber + 1,
            dans: classe
        )
    }

    /// Ajouter `nbOfGroups`au groupe 0 dans la `classe`.
    ///
    /// Supprime au préalable les groupes existants.
    /// - Parameter nbOfGroups: nombre de groupes à ajouter
    /// - Important: The context has changes and **is commited**
    private static func recreate(
        nbOfGroups: Int,
        dans classe: ClasseEntity
    ) {
        // Supprimer au préalable les groupes existants
        disolveGroups(dans: classe)

        guard nbOfGroups > 0 else {
            return
        }

        // Ajouter `nbOfGroups`aux groupe 0 dans la `classe`.
        (1 ... nbOfGroups).forEach { n in
            let groupe = GroupEntity.create()
            groupe.classe = classe
            groupe.number = Int16(n)
        }
        try? GroupEntity.saveIfContextHasChanged()
    }

    /// Dissoudre le `group` et le supprimer.
    ///
    /// Tous les élèves du groupe dissout deviennent "sans groupe".
    /// - Parameter group: groupe à dissoudre et supprimer
    static func disolveAndRemove(group: GroupEntity) {
        // dissoudre le groupe
        group.allEleves.forEach { eleve in
            GroupManager.unassignFromItsGroup(eleve: eleve)
        }

        // supprimer le groupe
        try? group.delete()
        try? GroupEntity.saveIfContextHasChanged()
    }

    /// Dissoudre tous les groupes formés dans la `classe` sauf le groupe zéro.
    /// Affecter tous les élèves au groupe zéro.
    /// - Parameters:
    ///   - classe: dans cette classe
    /// - Important: The context has changes and **is commited**
    static func disolveGroups(dans classe: ClasseEntity) {
        // Affecter tous les élèves au groupe zéro
        let group0 = classe.groupOfUngroupedEleves
        classe.allEleves.forEach { eleve in
            eleve.group = group0
        }

        // Supprimer tous les groupes formés dans la `classe` sauf le groupe zéro
        classe.allGroups.forEach { groupe in
            if groupe.number != 0 {
                do {
                    try groupe.delete()
                } catch {
                    customLog.log(level: .fault, "Echec de la suppression du group d'élève n°\(groupe.number) dans la classe \(classe.displayString):  \(error.localizedDescription)")
                    fatalError()
                }
            }
        }
    }
}
