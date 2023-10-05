//
//  RoomPlan.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/10/2022.
//

import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "RoomPlanEditView"
)

public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

/// Editeur de plan des places de salle de classe
struct RoomPlanEditView: View {
    @ObservedObject
    var room: RoomEntity

    // MARK: - Computd Properties

    private var imageSize: CGSize? {
        room.imageSize
    }

    var body: some View {
        if let imageSize {
            ZStack(alignment: .topLeading) {
                GeometryReader { viewGeometry in
                    // Image du plan de la salle
                    room.viewImage
                        .resizable()
                        .elevTrombineStyling()

                    // Symboles des places des élèves dans la salle
                    if room.nbSeatPositionned > 0 {
                        ForEach(room.allSeats, id: \.objectID) { seat in
                            DraggableSeatLabel(
                                seat: seat,
                                viewGeometrySize: viewGeometry.size,
                                imageSize: imageSize
                            )
                        }
                    }
                }
            }

        } else {
            LoadRoomPlanView(room: room)
        }
    }
}

// struct RoomPlan_Previews: PreviewProvider {
//    static var room: Room = {
//        var r = Room(name: "TECHNO-2", capacity: 12)
//        r.addSeatToPlan(Seat(x: 0.0, y: 0.0))
//        r.addSeatToPlan(Seat(x: 0.25, y: 0.25))
//        r.addSeatToPlan(Seat(x: 0.5, y: 0.5))
//        r.addSeatToPlan(Seat(x: 0.75, y: 0.75))
//        r.addSeatToPlan(Seat(x: 0.98, y: 0.98))
//        return r
//    }()
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                RoomPlanEditView(room  : .constant(room),
//                                 school: TestEnvir.schoolStore.items.first!)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                RoomPlanEditView(room  : .constant(room),
//                                 school: TestEnvir.schoolStore.items.first!)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
