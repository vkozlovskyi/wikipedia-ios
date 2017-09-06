@import Foundation;
@import CoreGraphics;

NS_ASSUME_NONNULL_BEGIN

static CGSize const WMFImageTagMinimumSizeForGalleryInclusion = {64, 64};

@interface WMFImageTag : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *attributes;
@property (nonatomic, copy, readonly) NSString *src;
@property (nonatomic, copy, readonly) NSString *imageTagContents;
@property (nonatomic, copy, readonly) NSString *placeholderTagContents;

- (nullable instancetype)initWithAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes baseURL:(nullable NSURL *)baseURL NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithImageTagContents:(NSString *)imageTagContents baseURL:(nullable NSURL *)baseURL;

- (BOOL)isSizeLargeEnoughForGalleryInclusion;

- (void)setValue:(NSString *)value forAttribute:(NSString *)attribute; // don't use this to set any of the attributes that have properties above (src, srcset, alt, etc)

@end

NS_ASSUME_NONNULL_END
