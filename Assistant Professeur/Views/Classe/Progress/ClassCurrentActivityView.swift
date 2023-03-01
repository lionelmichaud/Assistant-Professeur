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

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if let activity = classe.currentActivity,
               let sequence = activity.sequence {
                ClassRailwayProgressView(classe: classe)
                    .padding(.top)
                
                Text("Sequence en cours")
                    .font(.headline)
                    .bold()
                    .padding([.top, .leading])
                    .horizontallyAligned(.leading)
                SequenceDetailGroupBox(sequence: sequence)
                
                Text("Activité en cours")
                    .font(.headline)
                    .bold()
                    .padding([.top, .leading])
                    .horizontallyAligned(.leading)
                ActivityDetailGroupBox(activity: activity)
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
