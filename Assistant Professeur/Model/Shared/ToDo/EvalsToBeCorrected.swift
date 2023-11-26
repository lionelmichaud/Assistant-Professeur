//
//  BatchOfEvalsToBeCorrected.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/11/2023.
//

import Foundation

struct BatchOfEvalsToBeCorrected: Identifiable {
    var id = UUID()
    var classe: ClasseEntity
    var activity: ActivityEntity
    var progress: ActivityProgressEntity
    var documents: [DocumentEntity]
}
