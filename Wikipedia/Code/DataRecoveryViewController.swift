import UIKit
import WMF
import MessageUI

fileprivate struct DataRecoveryOption {
    let name: String
    let fileURL: URL
    let isRestoreable: Bool
    let fileSize: Int
}

class DataRecoveryCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@objc class DataRecoveryViewController: UIViewController, Themeable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet var borderViews: [UIView]!
    var theme: Theme = Theme.standard
    fileprivate var options: [DataRecoveryOption] = []
    @objc public var dataStore: MWKDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.text = WMFLocalizedString("data-recovery-instructions", value: "Select a file from the list to restore or send in for support", comment: "Instructs the user to select a file from the list to attempt to recover or send in for spport")
        emptyViewLabel.text = WMFLocalizedString("data-recovery-empty", value: "No files available", comment: "Label for the empty state showing that no files are available for recovery")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.register(DataRecoveryCell.self, forCellReuseIdentifier: DataRecoveryCell.identifier)
        apply(theme: self.theme)
        options = dataStore.fileURLsAvailableForDataRecovery().compactMap({ (fileURL) -> DataRecoveryOption? in
            let resourceValues = try? fileURL.resourceValues(forKeys: [URLResourceKey.fileSizeKey])
            let fileSize = resourceValues?.fileSize ?? 0
            return DataRecoveryOption(name: fileURL.lastPathComponent, fileURL: fileURL, isRestoreable: dataStore.isFileURLRestoreable(fileURL), fileSize: fileSize)
        })
        reloadData()
    }
    
    private func reloadData() {
        tableView.reloadData()
        emptyView.isHidden = options.count > 0
    }
    
    fileprivate func deselectAll() {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func send(fileURL: URL) {
        guard MFMailComposeViewController.canSendMail() else {
            WMFAlertManager.sharedInstance.showNoEmailAccountAlert()
            return
        }
        
        guard let data = try? Data(contentsOf: fileURL) else {
            WMFAlertManager.sharedInstance.showErrorAlertWithMessage(WMFLocalizedString("data-recovery-unable-to-read-file", value: "Unable to read the file. Please try again or try a different file", comment: "Error message shown to the user when the file cannot be read for data recovery"), sticky: false, dismissPreviousAlerts: false, tapCallBack: nil)
            return
        }
        
        let vc = MFMailComposeViewController()
        vc.setSubject("Data recovery: \(WikipediaAppUtils.versionedUserAgent())")
        vc.setToRecipients([WMFSupportEmailAddress])
        vc.addAttachmentData(data, mimeType: "application/x-sqlite3", fileName: fileURL.lastPathComponent)
        vc.mailComposeDelegate = self
        present(vc, animated: true)
    }
    
    @objc(applyTheme:)
    func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        view.backgroundColor = theme.colors.paperBackground
        view.tintColor = theme.colors.link
        instructionsLabel.textColor = theme.colors.primaryText
        emptyViewLabel.textColor = theme.colors.secondaryText
        tableView.backgroundColor = theme.colors.paperBackground
        emptyView.backgroundColor = theme.colors.midBackground
        for view in borderViews {
            view.backgroundColor = theme.colors.border
        }
    }
}

extension DataRecoveryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DataRecoveryCell.identifier, for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option.name
        cell.textLabel?.textColor = theme.colors.primaryText
        cell.detailTextLabel?.textColor = theme.colors.secondaryText
        cell.detailTextLabel?.text = ByteCountFormatter.string(fromByteCount: Int64(option.fileSize), countStyle: .file)
        cell.backgroundColor = theme.colors.paperBackground
        cell.tintColor = theme.colors.link
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
//        if selectedOption.isRestoreable {
//            let restoreButtonTitle = WMFLocalizedString("data-recovery-restore", value: "Restore", comment: "Title for the button that will attempt to restore the selected file")
//            let restoreAction = UIAlertAction(title: restoreButtonTitle, style: .default) { (action) in
//                // TODO: implement
//                self.deselectAll()
//            }
//            alertController.addAction(restoreAction)
//        }
        
        let sendButtonTitle = WMFLocalizedString("data-recovery-send", value: "Send to support", comment: "Title for the button that will send the selected file to support")
        let sendAction = UIAlertAction(title: sendButtonTitle, style: .default) { (action) in
            self.deselectAll()
            self.send(fileURL: selectedOption.fileURL)
        }
        alertController.addAction(sendAction)
        
        let cancelAction = UIAlertAction(title: CommonStrings.cancelActionTitle, style: .cancel) { (action) in
            self.deselectAll()
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}


extension DataRecoveryViewController: UITableViewDelegate {
    
}

extension DataRecoveryViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
