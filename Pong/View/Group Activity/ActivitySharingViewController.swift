//
//  ActivitySharingViewController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 30/12/22.
//

import SwiftUI
import UIKit
import GroupActivities

struct ActivitySharingViewController: UIViewControllerRepresentable {
    var activity = PongActivity()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivitySharingViewController>) -> GroupActivitySharingController {
        return try! GroupActivitySharingController(activity)
    }
    
    func updateUIViewController(_ uiViewController: GroupActivitySharingController, context: UIViewControllerRepresentableContext<ActivitySharingViewController>) {}
}
