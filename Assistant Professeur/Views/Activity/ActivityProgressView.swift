//
//  ActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/02/2023.
//

import SwiftUI

struct ActivityProgressView: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        ForEach(ProgramManager.classesAssociatedTo(thisActivity: activity)) { classe in
            Text("**\(classe.school!.displayString)**: \(classe.displayString)")
        }
    }
}

// struct ActivityProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityProgressView()
//    }
// }
