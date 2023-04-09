//
//  LoadRoomPlanView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/02/2023.
//

import HelpersView
import SwiftUI

struct LoadRoomPlanView: View {
    @ObservedObject
    var room: RoomEntity

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var isImportingImageFile = false

    var body: some View {
        VStack {
            Text("Pas de plan disponible pour la salle \"\(room.viewName)\".")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding()

            Text("Déposer ici un fichier 'PNG' ou 'JPEG'")
                .padding(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .background(.tertiary)
                )
                .dropDestination(for: Data.self) { items, _ in
                    guard let item = items.first else {
                        return false
                    }
                    if let image = NativeImage(data: item) {
                        room.viewNativeImage = image
                        return true
                    } else {
                        return false
                    }
                }

            Text("ou")

            // Télécharger un plan au format PNG
            Button {
                isImportingImageFile.toggle()
            } label: {
                Label(
                    "Importer un plan au format 'PNG' ou 'JPEG'",
                    systemImage: "square.and.arrow.down"
                )
            }
            .buttonStyle(.borderedProminent)
            // Importer un fichier PNG ou JPEG
            .fileImporter(
                isPresented: $isImportingImageFile,
                allowedContentTypes: [.png, .jpeg],
                allowsMultipleSelection: false
            ) { result in
                withAnimation {
                    var image: NativeImage?
                    (
                        image,
                        alertTitle,
                        alertMessage,
                        alertIsPresented
                    ) = ImageImportExportMng.importImage(result: result)
                    if let image {
                        room.viewNativeImage = image
                    }
                }
            }
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {},
                message: { Text(alertMessage) }
            )
        }
    }
}

// struct LoadRoomPlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadRoomPlanView()
//    }
// }
