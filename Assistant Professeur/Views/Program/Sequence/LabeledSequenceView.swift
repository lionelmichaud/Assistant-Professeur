//
//  LabeledSequenceView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct LabeledSequenceView: View {
    @ObservedObject
    var sequence: SequenceEntity

    var body: some View {
        Label {
            Text(sequence.viewName)
                .textSelection(.enabled)
        } icon: {
            Image(systemName: "\(sequence.viewNumber).circle")
                .imageScale(.large)
        }
    }
}

 struct LabeledSequenceView_Previews: PreviewProvider {
     static func initialize() {
         DataBaseManager.populateWithMockData(storeType: .inMemory)
     }

     static var previews: some View {
         initialize()
         return Group {
             LabeledSequenceView(sequence: SequenceEntity.all().first!)
                 .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                 .environment(\.managedObjectContext, CoreDataManager.shared.context)
                 .previewDevice("iPad mini (6th generation)")
             LabeledSequenceView(sequence: SequenceEntity.all().first!)
                 .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                 .environment(\.managedObjectContext, CoreDataManager.shared.context)
                 .previewDevice("iPhone 13")
         }
    }
 }
