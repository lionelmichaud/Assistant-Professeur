//
//  ProgramDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI

struct ProgramDetail: View {
    @ObservedObject
    var program: ProgramEntity

    var body: some View {
        Text("Discipine: \(program.disciplineString)")
    }
}

//struct ProgramDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramDetail()
//    }
//}
