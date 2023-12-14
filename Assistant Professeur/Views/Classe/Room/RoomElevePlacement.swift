//
//  RoomEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/10/2022.
//

import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "RoomElevePlacement"
)

/// Positionnement des élèves d'une classe sur les places assises de la salle de classe
struct RoomElevePlacement: View {
    @ObservedObject
    var classe: ClasseEntity

    @State
    private var isShowingDissociateDialog = false

    // MARK: - ComputedProperties

    private var room: RoomEntity? {
        classe.room
    }

    private var roomName: String {
        room?.name ?? ""
    }

    private var imageSize: CGSize? {
        classe.room?.imageSize
    }

    var body: some View {
        Group {
            if classe.hasAssociatedRoom {
                // TODO: - Gérer ici la mise à jour de la photo par drag and drop
                if let room = classe.room, let imageSize {
                    ZStack(alignment: .topLeading) {
                        GeometryReader { viewGeometry in
                            /// Image du plan de la salle
                            room.viewImage
                                .resizable()
                                .elevTrombineStyling()

                            // Symboles des places des élèves dans la salle
                            if room.nbSeatPositionned > 0 {
                                ForEach(room.allSeats, id:\.objectID) { seat in
                                    EditableSeatLabel(
                                        classe           : classe,
                                        seat             : seat,
                                        viewGeometrySize : viewGeometry.size,
                                        imageSize        : imageSize
                                    )
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("Plan de salle non défini.")
                            .font(.title)
                            .padding(.bottom)
                        Text("Définir un plan pour la salle **'\(classe.room!.viewName)**' dans l'établissement **'\(classe.school!.displayString)'**.")
                            .font(.title3)
                    }
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack {
                    Text("Aucune salle de classe.")
                        .font(.title)
                        .padding(.bottom)
                    Text("Définir une salle de classe.")
                        .font(.title3)
                }
                .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if classe.hasAssociatedRoom {
                    // Dissocier la classe de la salle de classe
                    Button(role: .destructive) {
                        isShowingDissociateDialog.toggle()
                    } label: {
                        Label("Dissocier de cette salle", systemImage: "minus.circle.fill")
                    }
                    .confirmationDialog(
                        "Dissocier la classe de cette salle?",
                        isPresented: $isShowingDissociateDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Dissocier", role: .destructive) {
                            withAnimation {
                                if let room {
                                    // Retirer tous les éléves de la `classe` des sièges de la salle de classe.
                                    room.removeAllSeatsFromPlan()
                                } else {
                                    customLog.log(
                                        level: .fault,
                                        "Dissocier: Le plan associé à la salle de classe n'a pas été trouvé"
                                    )
                                }
                                classe.room = nil
                            }
                        }
                    } message: {
                        Text("La classe de \(classe.displayString) ne sera plus associée à la salle de classe \(room!.viewName).\n") +
                            Text("Cette action ne peut pas être annulée.")
                    }
                } else if classe.school != nil {
                    // associer la classe à une salle de classe
                    AssociateClasseToRoomMenu(classe: classe)
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Salle \(roomName)")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// Menu des salles de classe sélectionnables pour une classe donnée
struct AssociateClasseToRoomMenu : View {
    @ObservedObject
    var classe: ClasseEntity

    var body: some View {
        Menu {
            ForEach(classe.school!.allRooms, id: \.objectID) { room in
                Button(room.viewName) {
                    withAnimation {
                        classe.room = room
                    }
                }
            }
        } label: {
            Label("Associer", systemImage: "plus.circle.fill")
        }

    }
}

// struct RoomEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                RoomElevePlacement(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                RoomElevePlacement(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
