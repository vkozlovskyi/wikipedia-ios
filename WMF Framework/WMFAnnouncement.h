#import <Mantle/Mantle.h>

@interface WMFAnnouncement : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSDate *startTime;
@property (nonatomic, copy, readonly) NSDate *endTime;
@property (nonatomic, copy, readonly) NSArray<NSString *> *platforms;
@property (nonatomic, copy, readonly) NSArray<NSString *> *countries;

@property (nonatomic, copy, readonly) NSURL *imageURL;

@property (nonatomic, copy, readonly) NSString *text;

@property (nonatomic, copy, readonly) NSString *minVersion;
@property (nonatomic, copy, readonly) NSString *maxVersion;

@property (nonatomic, readonly) BOOL beta;
@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) BOOL readingListSyncEnabled;

@property (nonatomic, copy, readonly) NSString *actionTitle;
@property (nonatomic, copy, readonly) NSString *negativeText;
@property (nonatomic, copy, readonly) NSURL *actionURL;

@property (nonatomic, copy, readonly) NSString *captionHTML;
@property (nonatomic, copy, readonly) NSAttributedString *caption;

@end
