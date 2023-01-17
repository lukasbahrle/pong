//
//  PongActivity.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 18/12/22.
//

import Foundation
import GroupActivities

struct PongActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("Pong", comment: "Let´s play pong")
        metadata.type = .generic
        return metadata
    }
}
