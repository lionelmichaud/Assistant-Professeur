//
//  Group+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/12/2022.
//

import CoreData
import SwiftUI

/// Une classe d'élève
extension GroupEntity {
    // MARK: - Computed properties

    /// Wrapper of `number`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewNumber: Int {
        get {
            Int(self.number)
        }
        set {
            self.number = Int16(newValue)
            try? GroupEntity.saveIfContextHasChanged()
        }
    }

    var isEmpty: Bool {
        eleves == nil || elevesCount == 0
    }

    var nbOfEleves: Int {
        Int(elevesCount)
    }

    var displayString: String {
        if number == 0 {
            return "Sans groupe"
        } else {
            return "Groupe \(number.formatted())"
        }
    }
}

// MARK: - Extension Core Data

extension GroupEntity {
    // MARK: - Type Computed Properties

    static var byClasseThenNumberNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \GroupEntity.classe?.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \GroupEntity.classe?.school?.name,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \GroupEntity.classe?.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \GroupEntity.classe?.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \GroupEntity.classe?.segpa,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \GroupEntity.number,
                ascending: true
            )
        ]

    /// Requête pour tous les groupes triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'école
    ///   2. Nom de l'école
    ///   3. Niveau de la Classe
    ///   4. Numéro de la Classe
    ///   5. Classe SGPA ou non
    ///   6. Numéro de groupe
    static var requestAllSortedByClasseThenNumber: NSFetchRequest<GroupEntity> {
        let request = GroupEntity.fetchRequest()
        request.sortDescriptors = GroupEntity.byClasseThenNumberNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    @discardableResult
    static func create(
        numero: Int16,
        dans classe: ClasseEntity?
    ) -> GroupEntity {
        let groupe = GroupEntity.create()
        // Classe d'appartenance.
        // mandatory
        groupe.classe = classe
        groupe.number = numero

        try? GroupEntity.saveIfContextHasChanged()
        return groupe
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { groupe in
            if groupe.classe == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try groupe.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: groupe.displayString,
                            id: groupe.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: groupe.displayString,
                        id: groupe.id
                    ))
                }
            }

            if groupe.viewNumber.isNegative {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: groupe.displayString,
                    attribute: "number",
                    id: groupe.id
                ))
            }
        }
    }

    // MARK: - Computed Properties

    /// Liste des élèves du groupe non triées
    var allEleves: [EleveEntity] {
        if let eleves {
            return (eleves.allObjects as! [EleveEntity])
        } else {
            return []
        }
    }

    /// Liste des élèves du groupe triés par nom.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    var elevesSortedByName: [EleveEntity] {
        filteredElevesSortedByName(searchString: "")
    }

    // MARK: - Methods

    /// Retourne la liste des élèves du groupe satisfaisant *au moins à l'un des critères* définis en paramètre.
    /// Les élèves trouvés sont triés par nom.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    ///
    /// - Parameters:
    ///   - searchString: caractères à rechercher dnas les noms/prénom ou nombre à rechercher dans le n° de groupe
    /// - Returns: Liste des élèves du groupe satisfaisant *au moins à l'un des critères* définis en paramètre
    func filteredElevesSortedByName(searchString: String) -> [EleveEntity] {
        let sortComparators = UserPrefEntity.shared.nameSortOrderEnum == .nomPrenom ?
            [
                SortDescriptor(\EleveEntity.familyName, order: .forward),
                SortDescriptor(\EleveEntity.givenName, order: .forward)
            ] :
            [
                SortDescriptor(\EleveEntity.givenName, order: .forward),
                SortDescriptor(\EleveEntity.familyName, order: .forward)
            ]

        if searchString.isEmpty {
            return allEleves
                .sorted(using: sortComparators)

        } else {
            return allEleves
                .filter { eleve in
                    eleve.satisfiesTo(searchString: searchString)
                }
                .sorted(using: sortComparators)
        }
    }

    /// Retourne la liste des élèves du groupe dont les nom ou prénom contiennent `searchString`.
    ///
    /// Les élèves trouvés sont triés en utilisant `sortOrder`.
    func filteredSortedEleves(
        searchString: String,
        sortOrder: [KeyPathComparator<EleveEntity>]
    ) -> [EleveEntity] {
        guard searchString.isNotEmpty else {
            return allEleves.sorted(using: sortOrder)
        }

        return allEleves
            .filter { eleve in
                eleve.satisfiesTo(searchString: searchString)
            }
            .sorted(using: sortOrder)
    }
}

// MARK: - Extension Debug

public extension GroupEntity {
    override var description: String {
        """

        GROUPE: \(number)
           ID        : \(String(describing: id))
           Classe    : \(String(describing: classe?.displayString))
           Nb élèves : \(elevesCount)
        """
    }
}
