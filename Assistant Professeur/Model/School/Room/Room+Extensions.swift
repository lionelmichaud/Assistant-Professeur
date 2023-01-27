//
//  Room+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import os
import CoreData
import UIKit
import SwiftUI

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "RoomEntity")
/// Une salle de classe
extension RoomEntity {

    // MARK: - Type Properties

    static let defaultPlanUIImage : UIImage = UIImage(systemName: "questionmark.app.dashed")!
    static let defaultPlanImage   : Image = Image(systemName: "questionmark.app.dashed")

    // MARK: - Computed Properties

    /// Wrapper of `capacity`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewCapacity: Int {
        get {
            Int(self.capacity)
        }
        set {
            self.capacity = Int16(newValue)
            try? RoomEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `name`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
            try? RoomEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `image`
    /// - Important: *Saves the context to the store after modification is done*
    var viewUIImage: UIImage {
        get {
            if let image {
                return UIImage(data: image) ?? RoomEntity.defaultPlanUIImage
            } else {
                return RoomEntity.defaultPlanUIImage
            }
        }
        set {
            self.image = newValue.pngData()
            try? RoomEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `image`
    /// - Important: *Saves the context to the store after modification is done*
    var viewImage: Image {
        get {
            if let image, let uiImage = UIImage(data: image) {
                return Image(uiImage: uiImage)
            } else {
                return RoomEntity.defaultPlanImage
            }
        }
    }

    var planExists: Bool {
        image != nil
    }

    /// Nombre de places positionnées sur le plan de la salle de classe
    var nbSeatPositionned: Int {
        Int(seatsCount)
    }

    /// Nombre de places non encore positionnées sur le plan de la salle de classe
    var nbSeatUnpositionned: Int {
        viewCapacity - nbSeatPositionned
    }

    var fileName: String {
        "Plan " + viewName + ".png"
    }

    /// Retourne les dimensions de l'image
    var imageSize : CGSize? {
        if let image,
           let imageSource = CGImageSourceCreateWithData(image as CFData, nil),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
            let pixelWidth  = imageProperties[kCGImagePropertyPixelWidth] as! Int
            let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! Int
            //print("Width: \(pixelWidth), Height: \(pixelHeight)")
            return CGSize(width: pixelWidth, height: pixelHeight)
        }
        return nil
    }

    // MARK: - Methods

    /// Augmenter la capacité de la salle de classe
    /// - Parameter increment: Nobre de places à ajouter
    ///
    /// Si `increment`est ≤ 0, alors ne fait rien
    func incrementCapacity(increment: Int = 1) {
        guard increment.isPositive else {
            return
        }
        capacity += Int16(increment)
    }

    /// Réduire la capacité de la salle de classe
    /// - Parameter decrement: Nombre de places à supprimer (>0)
    ///
    /// Si `decrement`est ≤ 0, alors ne fait rien
    func decrementCapacity(decrement: Int = 1) {
        guard decrement.isPositive else {
            return
        }
        setCapacity(to: viewCapacity - decrement)
    }
}

// MARK: - Extension Core Data

extension RoomEntity: ModelEntityP {

    // MARK: - Computed Properties

    /// Liste des sièges de la salle de classe non triés
    var allSeats: [SeatEntity] {
        if let seats {
            return (seats.allObjects as! [SeatEntity])
        } else {
            return [ ]
        }
    }

    // MARK: - Type Methods

    @discardableResult static func create(
        withName     : String = "",
        withCapacity : Int    = 1,
        dans school  : SchoolEntity
    ) -> RoomEntity {
        let room = RoomEntity.create()
        // établissement d'appartenance.
        // mandatory
        room.school = school

        room.name     = withName
        room.capacity = Int16(withCapacity)

        try? RoomEntity.saveIfContextHasChanged()

        return room
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { room in
            guard room.school != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Methods

    /// Positionner un siège supplémentaires `seat` sur le plan de la salle de classe.
    /// - Parameters:
    ///   - x: position horizontale de la place dans la salle en % [0.0, 1.0]
    ///   - y: position verticale de la place dans la salle en % [0.0, 1.0]
    ///
    /// Si le nombre de place déjà positionnées est égale à la capacité max de la salle de classe,
    /// alors ne fait rien.
    func addSeatToPlan(
        x : Double = 0.5,
        y : Double = 0.5
    ) {
        guard nbSeatUnpositionned.isPositive else {
            return
        }
        SeatEntity.create(x: x, y: y, dans: self)
    }

    /// Redéfinit la capacité de la salle de classe.
    ///
    /// Si la nouvelle capacité est > aux nombre d'élèves déjà placés,
    /// Annule le placement du nombre d'élèves nécessaire.
    /// - Parameters:
    ///   - newCapacity: Nouvelle capacité de la salle de classe.
    func setCapacity(to newCapacity: Int) {
        if newCapacity < nbSeatPositionned {
            var seats = allSeats
            var removedSeats = 0
            for _ in newCapacity ... (nbSeatPositionned - 1) {
                do {
                    let seat = seats.last
                    if let seat {
                        try seat.delete()
                        seats = seats.dropLast(1)
                        removedSeats += 1
                    }
                } catch {
                    customLog.log(level: .error,
                                  "Echec de la tentative de retirer une place assise d'une salle de classe.")
                }
            }
            viewCapacity -= removedSeats

        } else {
            viewCapacity = newCapacity
        }
    }

    /// Supprimer tous les sièges positionnés sur le plan de la salle de classe.
    ///
    /// Tous les sièges seront libérés des élèves assis dessus dans l'ensemble des classes.
    func removeAllSeatsFromPlan() {
        self.allSeats.forEach { seat in
            try? seat.delete()
        }
    }

    /// Supprime le plan de salle de classe `room`.
    ///
    /// Supprimera tous les sièges positionnés sur le plan de la salle de classe `room`.
    ///
    /// Tous les sièges seront libérés des élèves assis dessus dans l'ensemble des classes.
    func deleteRoomPlan() {
        image = nil
        removeAllSeatsFromPlan()
        
        try? RoomEntity.saveIfContextHasChanged()
    }
}

// MARK: - Extension Debug

extension RoomEntity {
    public override var description: String {
        """

        SALLE DE CLASSE : \(viewName)
           Capacité de la salle : \(capacity)
           Places: \(String(describing: seats).withPrefixedSplittedLines("     "))
        """
    }
}
