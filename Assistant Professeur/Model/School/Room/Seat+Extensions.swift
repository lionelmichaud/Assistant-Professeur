//
//  SeatEntity.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/01/2023.
//

import Foundation

extension SeatEntity {
    // MARK: - Computed Properties

    /// Position de la place assise à l'intérieur de la classe en % [0.0, 1.0]
    var locInRoom: CGPoint {
        get {
            CGPoint(x: x, y: y)
        }
        set {
            x = newValue.x
            y = newValue.y
            try? SeatEntity.saveIfContextHasChanged()
        }
    }

    var viewNumber: Int {
        Int(numero)
    }
}

// MARK: - Extension Core Data

extension SeatEntity {
    // MARK: - Computed Properties

    /// Liste des élèves de toutes les classe assi à cette place
    var allEleves: [EleveEntity] {
        if let eleves {
            return (eleves.allObjects as! [EleveEntity])
        } else {
            return []
        }
    }

    // MARK: - Type Methods

    /// Créer une nouvelle place assise et l'ajouter à la salle de classe `room`
    /// - Parameters:
    ///   - x: position horizontale de la place dans la salle en % [0.0, 1.0]
    ///   - y: position verticale de la place dans la salle en % [0.0, 1.0]
    ///   - room: La salle dans laquelle ajouter la place assise
    /// - Returns: La nouvelle place
    @discardableResult
    static func create(
        //        numero    : Int,
        x: Double = 0.5,
        y: Double = 0.5,
        dans room: RoomEntity
    ) -> SeatEntity {
        let seat = SeatEntity.create()
        // salle d'appartenance.
        // mandatory
        seat.room = room

        seat.x = x
        seat.y = y
        seat.numero = Int16(Self.all().count + 1)
        //        seat.numero = Int16(numero)

        try? SeatEntity.saveIfContextHasChanged()

        return seat
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    /// Créer une nouvelle place assise et l'ajouter à la salle de classe `room`
    /// - Parameters:
    ///   - locInRoom: positions horizontale et verticale de la place dans la salle en % [0.0, 1.0]
    ///   - room: La salle dans laquelle ajouter la place assise
    /// - Returns: La nouvelle place
    @discardableResult
    static func create(
        //        numero    : Int,
        locInRoom: CGPoint = CGPoint(x: 0.5, y: 0.5),
        dans room: RoomEntity
    ) -> SeatEntity {
        return create(x: locInRoom.x, y: locInRoom.y, dans: room)
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { seat in
            if seat.room == nil {
                errorList.append(DataBaseError.noOwner(
                    entity: Self.entity().name!,
                    name: String(seat.viewNumber),
                    id: seat.id
                ))
            }
        }
    }
}

// MARK: - Extension Debug

public extension SeatEntity {
    override var description: String {
        """

        PLACE ASSISE : n°\(numero)
           Occupée par: \(allEleves.count) élèves
        """
    }
}
