//
//  RoomSeatManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/01/2023.
//

import Foundation

struct RoomSeatManager {
    
    /// Retourne l'élève de la `classe` assis à la place `seat`
    /// - Parameters:
    ///   - classe: classe d'appartenance de l'élève
    ///   - seat: place assise de la salle de classe
    /// - Returns: Elève de la `classe` assis à la place `seat` s'il y en a un, `nil` sinon
    static func eleve(from classe: ClasseEntity,
                      seatedOn seat: SeatEntity) -> EleveEntity? {
        seat.allEleves
            .first { eleve in
                eleve.classe == classe
            }
    }
}
