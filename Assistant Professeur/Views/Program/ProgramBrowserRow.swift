//
//  ProgramBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI

struct ProgramBrowserRow: View {
    @ObservedObject
    var program: ProgramEntity

    var body: some View {
        HStack {
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(program.levelEnum.color)
            Text(program.levelEnum.pickerString + (program.segpa ? " Segpa" : ""))
                .fontWeight(.bold)
        }
    }
}

//struct ProgramBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramBrowserRow()
//    }
//}
