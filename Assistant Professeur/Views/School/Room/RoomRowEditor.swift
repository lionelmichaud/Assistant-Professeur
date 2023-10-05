//
//  RoomEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/10/2022.
//

import SwiftUI

struct RoomRowEditor: View {
    @ObservedObject
    var room: RoomEntity

    @Environment(\.horizontalSizeClass)
    var hClass

    @State
    private var isPlacing = false

    var nameView: some View {
        HStack {
            Image(systemName: "door.left.hand.open")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            TextField("Nom de la salle", text: $room.viewName)
                .textFieldStyle(.roundedBorder)
        }
    }

    var nbPlacesView: some View {
        Stepper {
            HStack {
                Text(hClass == .regular ? "Nombre de places" : "Nombre de places")
                Spacer()
                Text("\(room.capacity)")
                    .foregroundColor(.secondary)
            }
        } onIncrement: {
            room.incrementCapacity()
        } onDecrement: {
            room.decrementCapacity()
        }
    }

    private var compactView: some View {
        VStack {
            HStack {
                nameView
                Button("Plan") {
                    isPlacing.toggle()
                }
                .buttonStyle(.bordered)
            }
            nbPlacesView
        }
    }

    private var largeView: some View {
        HStack {
            nameView
                .padding(.trailing)
            nbPlacesView
                .frame(maxWidth: 275)
                .padding(.trailing)
            Button("Plan") {
                isPlacing.toggle()
            }
            .buttonStyle(.bordered)
        }
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            largeView
            compactView
        }
        // Modal: Définition du layout d'une nouvelle salle de classe
        .sheet(isPresented: $isPlacing) {
            NavigationStack {
                RoomLayoutEditor(room: room)
                    .presentationDetents([.large])
            }
        }
    }
}

// struct RoomCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                RoomCreator(room: .constant(Room(name: "TECHNO-2",
//                                                 capacity: 12)),
//                            school: TestEnvir.schoolStore.items.first!)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//        }
//    }
// }
