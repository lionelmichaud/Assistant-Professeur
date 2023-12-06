//
//  ProgramNavigationRoute.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/12/2023.
//

import SwiftUI

enum ProgramNavigationRoute: Hashable, Codable {
    case activityDetail(ActivityEntity.ID)
    case sequenceSteps(SequenceEntity.ID)
    case programSteps(ProgramEntity.ID)

    func destination() -> some View {
        var errorView: Text {
            Text("Erreur de routage")
                .font(.largeTitle)
        }

        return Group {
            switch self {
                case let .activityDetail(activityId):
                    if let activity = ActivityEntity.byId(id: activityId!) {
                        ActivityDetail()
                    } else {
                        errorView
                    }

                case let .sequenceSteps(sequenceId):
                    if let sequence = SequenceEntity.byId(id: sequenceId!) {
                        SequenceTimeLine()
                    } else {
                        errorView
                    }

                case let .programSteps(programId):
                    if let program = ProgramEntity.byId(id: programId!) {
                        ProgramTimeLine()
                    } else {
                        errorView
                    }
            }
        }
    }
}
