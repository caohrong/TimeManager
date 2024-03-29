//
//  MailerManager.swift
//  OpenGpxTracker
//
//  Created by merlos on 21/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

class MailerManager: NSObject, MFMailComposeViewControllerDelegate {
    var composer: MFMailComposeViewController!
    var controller: UIViewController

    init(controller: UIViewController) {
        self.controller = controller
        super.init()
    }

    func send(filepath: String) {
        composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self

        // set the subject
        composer.setSubject("[Open GPX tracker] Gpx File")
        // Add some text to the message body
        var body = "Open GPX Tracker \n is an open source app for Apple devices. Create GPS tracks and export them to GPX files."
        composer.setMessageBody(body, isHTML: true)
        let fileData = try! NSData(contentsOf: URL(fileURLWithPath: filepath), options: NSData.ReadingOptions.mappedIfSafe)
        composer.addAttachmentData(fileData as Data, mimeType: "application/gpx+xml", fileName: URL(fileURLWithPath: filepath).lastPathComponent)

        // Display the comopser view controller
        controller.present(composer, animated: true, completion: nil)
    }

    func mailComposeController(controller: MFMailComposeViewController!,
                               didFinishWithResult _: MFMailComposeResult,
                               error _: NSError!)
    {
//            switch result.rawValue {
//            case MFMailComposeResult.RawValue: break
        ////                println("Email sent")
//
//            default: break
        ////                println("Whoops")
//            }

        controller.dismiss(animated: true, completion: nil)
    }
}
