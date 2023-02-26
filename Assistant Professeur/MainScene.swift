//
//  MainScene.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/11/2022.
//

import SwiftUI

/// Defines the main scene of the App
struct MainScene: Scene {

    // MARK: - Environment Properties

    @Environment(\.scenePhase) var scenePhase

    // MARK: - Properties

    /// object that you want to use throughout your views and that will be specific to each scene
    //@StateObject private var uiState = UIState()
    let coreDataController: CoreDataController

    var body: some Scene {
        WindowGroup {
            /// defines the views hierachy of the scene
            ContentView()
                .environment(\.managedObjectContext, coreDataController.viewContext)
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
        }
        .onChange(of: scenePhase) { scenePhase in
            // The final step is optional, but recommended:
            // when your app moves to the background,
            // you should call the save() method so that Core Data saves your changes permanently.

            switch scenePhase {
                case .active:
                    // An app or custom scene in this phase contains at least one active scene instance.
                    break
                    //                    print("Scene Phase = .active")

                case .inactive:
                    // An app or custom scene in this phase contains no scene instances in the ScenePhase.active phase.
                    break
                    //                    print("Scene Phase = .inactive")

                case .background:
                    // Expect an app that enters the background phase to terminate.
                    try? coreDataController.saveIfContextHasChanged()
                    //                    print("Scene Phase = .background")

                @unknown default:
                    fatalError()
            }
        }
        #if os(macOS)
        .commands {
            SidebarCommands()
        }
        #endif
    }
}
