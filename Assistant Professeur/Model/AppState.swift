//
//  AppState.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 29/10/2022.
//

import SwiftUI
import AppFoundation

struct AppState {
    static var shared = AppState()

    var initError: AppInitError?

    private init() {}
}
