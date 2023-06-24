//
//  SequenceBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceBrowserRow: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        HStack {
            Image(systemName: "\(sequence.viewNumber).circle")
                .imageScale(.large)

            VStack(alignment: .leading) {
                Text(sequence.viewName)
                Text(sequence.viewAnnotation)
                    .foregroundColor(.secondary)

                HStack {
                    DurationSquareView(
                        duration: sequence.durationWithoutMargin,
                        withMargin: true
                    )
                    Spacer()
                    WebsiteView(url: sequence.url)
                }
            }
        }
        .font(hClass == .compact ? .callout : .body)
    }
}

 struct SequenceBrowserRow_Previews: PreviewProvider {
     static func initialize() {
         DataBaseManager.populateWithMockData(storeType: .inMemory)
     }

     static var previews: some View {
         initialize()
         return Group {
             SequenceBrowserRow(sequence: SequenceEntity.all().first!)
                 .padding()
                 .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                 .environment(\.managedObjectContext, CoreDataManager.shared.context)
                 .previewDevice("iPad mini (6th generation)")
             SequenceBrowserRow(sequence: SequenceEntity.all().first!)
                 .padding()
                 .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                 .environment(\.managedObjectContext, CoreDataManager.shared.context)
                 .previewDevice("iPhone 13")
         }
     }
 }
