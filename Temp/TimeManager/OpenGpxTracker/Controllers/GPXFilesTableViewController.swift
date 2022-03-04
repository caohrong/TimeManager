//
//  GPXFilesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 14/09/14.
//

import CoreGPX
import Foundation
import MessageUI
import UIKit
import WatchConnectivity

/// Text displayed when there are no GPX files in the folder.
let kNoFiles = "No gpx files"

///
/// TableViewController that displays the list of files that have been saved in previous sessions.
///
/// This view controller allows users to manage their GPX Files.
///
/// Currently the following actions with a file are supported
///
/// 1. Send it by email
/// 2. Load in the map
/// 3. Delete the file
///
/// It also displays a button "Done" in the navigation bar to return to the map.
///
class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate {
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]

    /// Is there any GPX file in the directory?
    var gpxFilesFound = false

    /// Temporary variable to manage
    var selectedRowIndex = -1

    ///
    weak var delegate: GPXFilesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
        tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: view.frame.width, height:
            view.frame.height - navBarFrame.height)

        title = "Your GPX Files"

        // Button to return to the map
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))

        navigationItem.rightBarButtonItems = [shareItem]

        // Get gpx files
        let list: [FileDetailInfo] = GPXFileManager.fileList
        if list.count != 0 {
            fileList.removeAllObjects()
            fileList.addObjects(from: list)
            gpxFilesFound = true
        }

        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.path
        print(filePath!)
    }

    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
        dismiss(animated: true, completion: { () in
        })
    }

    override func viewDidAppear(_: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table view data source

    override func numberOfSections(in _: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }

    /// Returns the number of files in the section.
    override func tableView(_: UITableView?, numberOfRowsInSection _: Int) -> Int {
        return fileList.count
    }

    /// Allow edit rows? Returns true only if there are files.
    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return gpxFilesFound
    }

    /// Displays the delete button.
    override func tableView(_: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }

    /// Displays the name of the cell
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        if gpxFilesFound {
            let cell: UITableViewCell = .init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            // cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            // cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            let gpxFileInfo = fileList.object(at: (indexPath as NSIndexPath).row) as! FileDetailInfo
            cell.textLabel?.text = gpxFileInfo.fileName
            cell.detailTextLabel?.text =
                "last saved \(gpxFileInfo.modifiedDatetimeAgo) (\(gpxFileInfo.fileSizeHumanised))"
            cell.detailTextLabel?.textColor = UIColor.darkGray
            return cell
        } else {
            let cell: UITableViewCell = .init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            return cell
        }
    }

    /// Displays an action sheet with the actions for that file (Send it by email, Load in map and Delete)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheet = UIAlertController(title: nil, message: "Select option", preferredStyle: .actionSheet)
        let mapOption = UIAlertAction(title: "Load in Map", style: .default) { _ in
            self.actionLoadFileAtIndex(indexPath.row)
        }

        let shareOption = UIAlertAction(title: "Share", style: .default) { _ in
            self.actionShareFileAtIndex(indexPath.row, tableView: tableView, indexPath: indexPath)
        }

        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.actionSheetCancel(sheet)
        }

        let deleteOption = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.actionDeleteFileAtIndex(indexPath.row)
        }

        sheet.addAction(mapOption)
        sheet.addAction(shareOption)
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        sheet.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!

        present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
    }

    // MARK: UITableView delegate methods

    /// Only highlight rows if there are files.
    override func tableView(_: UITableView,
                            shouldHighlightRowAt _: IndexPath) -> Bool
    {
        return gpxFilesFound
    }

    internal func fileListObjectTitle(_ rowIndex: Int) -> String {
        return (fileList.object(at: rowIndex) as! FileDetailInfo).fileName
    }

    internal func actionSheetCancel(_: UIAlertController) {
        print("ActionSheet cancel")
    }

    /// Deletes from the disk storage the file of `fileList` at `rowIndex`
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? FileDetailInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionDeleteFileAtIndex: failed to get fileURL")
            return
        }
        GPXFileManager.removeFileFromURL(fileURL)

        // Delete from list and Table
        fileList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }

    /// Loads the GPX file that corresponds to rowIndex in fileList in the map.
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        guard let gpxFileInfo: FileDetailInfo = (fileList.object(at: rowIndex) as? FileDetailInfo) else {
            print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to get fileURL")
            return
        }
        print("Load gpx File: \(gpxFileInfo.fileName)")
        guard let gpx = GPXParser(withURL: gpxFileInfo.fileURL)?.parsedData() else {
            print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to parse GPX file")
            return
        }
        delegate?.didLoadGPXFileWithName(gpxFileInfo.fileName, gpxRoot: gpx)
        dismiss(animated: true, completion: nil)
    }

    /// Shares file at `rowIndex`
    internal func actionShareFileAtIndex(_ rowIndex: Int, tableView: UITableView, indexPath: IndexPath) {
        guard let gpxFileInfo: FileDetailInfo = (fileList.object(at: rowIndex) as? FileDetailInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        print("GPXTableViewController: actionShareFileAtIndex")

        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        activityViewController.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
        activityViewController.completionWithItemsHandler = { (_: UIActivity.ActivityType?, completed: Bool, _: [Any]?, _: Error?) in
            if !completed {
                // User canceled
                print("actionShareAtIndex: Cancelled")
                return
            }
            // User completed activity
            print("actionShareFileAtIndex: User completed activity")
        }
        present(activityViewController, animated: true, completion: nil)
    }
}
