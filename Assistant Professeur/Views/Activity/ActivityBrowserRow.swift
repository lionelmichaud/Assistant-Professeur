//
//  ActivityBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct ActivityBrowserRow: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        HStack {
            Label(activity.viewName,
                  systemImage: "\(activity.viewNumber).circle")
        }
    }
}

//struct ActivityBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityBrowserRow()
//    }
//}
