//
//  ClassCurrentActivityView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

/// Activité en cours pour une classe donnée
struct ClassCurrentActivityView: View {
    @ObservedObject
    var classe: ClasseEntity

    var body: some View {
        VStack {
            if let activity = classe.currentActivity,
               let sequence = activity.sequence {
                Text("Sequence \(sequence.viewNumber)")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                SequenceDetailGroupBox(sequence: sequence)
                
                Text("Activité \(activity.viewNumber)")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                ActivityDetailGroupBox(activity: activity)
                    .horizontallyAligned(.leading)
            } else {
                Text("Aucune activité en cours ni à venir")
            }
        }
        .verticallyAligned(.top)
        #if os(iOS)
        .navigationTitle("Activité en cours")
        #endif
        .navigationBarTitleDisplayModeInline()
    }

}

// struct ClassCurrentActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassCurrentActivityView()
//    }
// }
