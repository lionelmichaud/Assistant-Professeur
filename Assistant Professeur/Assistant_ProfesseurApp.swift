//
//  Assistant_ProfesseurApp.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/11/2022.
//

import SwiftUI

@main
struct Assistant_ProfesseurApp: App {

    /// the managed object context for your Core Data container
    let coreDataController = CoreDataController.shared

    var body: some Scene {
        MainScene(coreDataController: coreDataController)
    }
}
