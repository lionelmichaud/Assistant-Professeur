//
//  ClasseSidebarView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ClasseSplitView"
)

struct ClasseSplitView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            // 1ère colonne
            ClasseSidebarView()
                .navigationSplitViewColumnWidth(
                    min: 250,
                    ideal: 350,
                    max: 500
                )

        } detail: {
            // Détail dans la 2ième colonne
            NavigationStack(path: $navig.classPath) {
                ClasseEditor()
                    .navigationDestination(for: ClasseNavigationRoute.self) { route in
                        route.destination(horizontalSizeClass: horizontalSizeClass)
                    }
            }
        }
        // Deep Link
        .onOpenURL { incomingURL in
            customLog.log(level: .info, "App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
    }
}

// MARK: - Methods

extension ClasseSplitView {
    /// Gérer un deep link entrant
    private func handleIncomingURL(_ url: URL) {
        guard let scheme = url.scheme else {
            customLog.log(level: .debug, "No scheme detected in incoming URL: \(url)")
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            customLog.log(level: .debug, "Invalid URL: \(url)")
            return
        }

        guard let action = components.host else {
            customLog.log(level: .debug, "Unknown URL, we can't handle this one!: \(url)")
            return
        }

        switch action {
            case "update-progress":
                guard let classeName = components.queryItems?.first(where: { $0.name == "classe" })?.value else {
                    customLog.log(level: .debug, "Classe name not found: \(url)")
                    return
                }

                print("scheme = \(scheme) - action = \(action) - queryItem = \(classeName)")
                handleUpdateProgress(ofClasseName: classeName)

            default:
                customLog.log(level: .debug, "Action unknown: \(action)")
        }

        // openedRecipeName = recipeName
    }

    /// Deep link issu d'un Widget ou d'une Live Activity
    private func handleUpdateProgress(ofClasseName classeName: String) {
        if let classe =
            ClasseEntity.all()
                .filter({ classeObject in
                    classeName == classeObject.displayString
                })
                .first {
            // Naviger jusqu'à l'actualisation de la progression de la classe
            navig.selectedClasseMngObjId =
                ClasseEntity.managedObjectID(id: classe.id)
            navig.classPath = [.progress(classe.id)]
        }
    }
}

struct ClasseSplitView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseSplitView()
                .padding()
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
