//
//  WCompBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import SwiftUI

struct WCompBrowserRow: View {
    @ObservedObject
    var workedComp: WCompEntity

    var body: some View {
        Label(
            title: {
                Text(workedComp.viewAcronym)
                    .fontWeight(.bold)
                Text(workedComp.viewDescription)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            },
            icon: {
                Image(systemName: WCompEntity.defaultImageName)
            }
        )
    }
}

//struct WorkedCompBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompBrowserRow()
//    }
//}
