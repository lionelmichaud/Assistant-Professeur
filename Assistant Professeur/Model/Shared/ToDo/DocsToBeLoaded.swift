//
//  DocsToBeLoaded.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/11/2023.
//

import Foundation

struct BatchOfDocsToBeLoaded: Identifiable {
    var id = UUID()
    var classeLevel: LevelClasse
    var activity: ActivityEntity
    var documents: [DocumentEntity]
    var beforeDate: Date
}
