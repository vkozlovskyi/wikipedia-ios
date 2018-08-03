#import "WMFHelpViewController.h"
#import <WMF/MWKDataStore.h>
#import "UIBarButtonItem+WMFButtonConvenience.h"
#import <WMF/WikipediaAppUtils.h>
#import "Wikipedia-Swift.h"
#import "DDLog+WMFLogger.h"

@import MessageUI;

NS_ASSUME_NONNULL_BEGIN

static NSString *const WMFSettingsURLFAQ = @"https://m.mediawiki.org/wiki/Wikimedia_Apps/iOS_FAQ";
static NSString *const WMFSettingsEmailSubject = @"Bug:";

@interface WMFHelpViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *sendEmailToolbarItem;
@property (nonatomic, strong) UIBarButtonItem *dataRecoveryToolbarItem;

@end

@implementation WMFHelpViewController

- (instancetype)initWithDataStore:(MWKDataStore *)dataStore {
    NSURL *faqURL = [NSURL URLWithString:WMFSettingsURLFAQ];
    self = [super initWithArticleURL:faqURL dataStore:dataStore theme:self.theme];
    self.savingOpenArticleTitleEnabled = NO;
    self.addingArticleToHistoryListEnabled = NO;
    self.peekingAllowed = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)webViewController:(WebViewController *)controller didTapOnLinkForArticleURL:(NSURL *)url {
    WMFHelpViewController *articleViewController = [[WMFHelpViewController alloc] initWithArticleURL:url dataStore:self.dataStore theme:self.theme];
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (UIBarButtonItem *)sendEmailToolbarItem {
    if (!_sendEmailToolbarItem) {
        _sendEmailToolbarItem = [[UIBarButtonItem alloc] initWithTitle:WMFLocalizedStringWithDefaultValue(@"button-report-a-bug", nil, nil, @"Report a bug", @"Button text for reporting a bug") style:UIBarButtonItemStylePlain target:self action:@selector(sendEmail)];
        return _sendEmailToolbarItem;
    }
    return _sendEmailToolbarItem;
}

- (UIBarButtonItem *)dataRecoveryToolbarItem {
    if (!_dataRecoveryToolbarItem) {
        _dataRecoveryToolbarItem = [[UIBarButtonItem alloc] initWithTitle:WMFLocalizedStringWithDefaultValue(@"data-recovery-button", nil, nil, @"Data recovery", @"Button text for going to the data recovery screen") style:UIBarButtonItemStylePlain target:self action:@selector(presentDataRecovery)];
        return _dataRecoveryToolbarItem;
    }
    return _dataRecoveryToolbarItem;
}

- (NSArray<UIBarButtonItem *> *)articleToolBarItems {
    return @[
        self.showTableOfContentsToolbarItem,
        [UIBarButtonItem flexibleSpaceToolbarItem],
        self.dataRecoveryToolbarItem,
        self.sendEmailToolbarItem,
        [UIBarButtonItem wmf_barButtonItemOfFixedWidth:8]
    ];
}

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setSubject:[WMFSettingsEmailSubject stringByAppendingString:[WikipediaAppUtils versionedUserAgent]]];
        [vc setToRecipients:@[WMFSupportEmailAddress]];
        [vc setMessageBody:[NSString stringWithFormat:@"\n\n\n\nVersion: %@", [WikipediaAppUtils versionedUserAgent]] isHTML:NO];
        NSData *data = [[DDLog wmf_currentLogFile] dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [vc addAttachmentData:data mimeType:@"text/plain" fileName:@"Log Data.txt"];
        }
        vc.mailComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        [[WMFAlertManager sharedInstance] showNoEmailAccountAlert];
    }
}

- (void)presentDataRecovery {
    MWKDataStore *dataStore = self.dataStore;
    if (!dataStore) {
        return;
    }
    DataRecoveryViewController *vc = [[DataRecoveryViewController alloc] initWithNibName:@"DataRecoveryViewController" bundle:nil];
    vc.title = self.dataRecoveryToolbarItem.title;
    [vc applyTheme:self.theme];
    vc.dataStore = dataStore;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end

NS_ASSUME_NONNULL_END
