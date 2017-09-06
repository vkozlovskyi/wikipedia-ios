#import <WMF/WMFImageTag.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMFImageTag ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *mutableAttributes;

@end

@implementation WMFImageTag

- (nullable instancetype)initWithAttributes:(nullable NSDictionary<NSString *, NSString *> *)attributes baseURL:(nullable NSURL *)baseURL {

    NSString *src = attributes[@"src"];
    NSParameterAssert(src);
    if (!src) {
        return nil;
    }
    if ([[src stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return nil;
    }

    NSURLComponents *srcURLComponents = [NSURLComponents componentsWithString:src];
    if (srcURLComponents == nil) {
        return nil;
    }

    // remove scheme for consistency.
    if (srcURLComponents.scheme != nil) {
        srcURLComponents.scheme = nil;
    }

    if (srcURLComponents.host == nil) {
        if (![src hasPrefix:@"/"]) {
            srcURLComponents.path = [baseURL.path stringByAppendingPathComponent:src];
        }
        srcURLComponents.host = baseURL.host;
    }

    src = srcURLComponents.URL.absoluteString;
    if (src == nil) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.mutableAttributes = [attributes mutableCopy];
    }
    return self;
}

- (nullable instancetype)initWithImageTagContents:(NSString *)imageTagContents baseURL:(nullable NSURL *)baseURL {
    static NSRegularExpression *attributeRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *attributePattern = @"([a-zA-Z-]+)(?:=\")([^\"]+)(?:\")";
        attributeRegex = [NSRegularExpression regularExpressionWithPattern:attributePattern options:NSRegularExpressionCaseInsensitive error:nil];
    });

    NSMutableDictionary *attributes = [NSMutableDictionary new];
    NSInteger attributeOffset = 0;
    [attributeRegex enumerateMatchesInString:imageTagContents
                                     options:0
                                       range:NSMakeRange(0, imageTagContents.length)
                                  usingBlock:^(NSTextCheckingResult *_Nullable attributeResult, NSMatchingFlags flags, BOOL *_Nonnull stop) {
                                      NSString *attributeName = [[attributeRegex replacementStringForResult:attributeResult inString:imageTagContents offset:attributeOffset template:@"$1"] lowercaseString];
                                      NSString *attributeValue = [attributeRegex replacementStringForResult:attributeResult inString:imageTagContents offset:attributeOffset template:@"$2"];
                                      if (!attributeValue || !attributeName) {
                                          return;
                                      }
                                      attributes[attributeName] = attributeValue;
                                  }];

    //Don't continue initialization if we have invalid src
    if ([attributes[@"src"] length] == 0) {
        return nil;
    }

    return [self initWithAttributes:attributes baseURL:baseURL];
}

- (NSInteger)integerValueForAttribute:(nonnull NSString *)attribute {
    if (!attribute) {
        return 0;
    }
    id value = self.attributes[attribute];
    if (![value respondsToSelector:@selector(integerValue)]) {
        return 0;
    }
    return [value integerValue];
}

- (NSString *)src {
    return self.attributes[@"src"];
}

- (NSDictionary *)attributes {
    return [self.mutableAttributes copy];
}

- (BOOL)isSizeLargeEnoughForGalleryInclusion {

    return
        // Ensure images which are just used as tiny icons are not included in gallery.
        [self integerValueForAttribute:@"width"] >= WMFImageTagMinimumSizeForGalleryInclusion.width &&
        [self integerValueForAttribute:@"height"] >= WMFImageTagMinimumSizeForGalleryInclusion.height &&
        // Also make sure we only try to show them in the gallery if their canonical size is of sufficient resolution.
        [self integerValueForAttribute:@"data-file-width"] >= WMFImageTagMinimumSizeForGalleryInclusion.width &&
        [self integerValueForAttribute:@"data-file-height"] >= WMFImageTagMinimumSizeForGalleryInclusion.height;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", _mutableAttributes];
}

- (NSString *)imageTagContents {
    NSString *newImageTagContents = @"";
    NSDictionary *attributes = [self.attributes copy];
    for (NSString *attribute in attributes) {
        NSString *value = attributes[attribute];
        if (value) {
            NSString *attributeString = [@[@" ", attribute, @"=\"", value, @"\""] componentsJoinedByString:@""];
            newImageTagContents = [newImageTagContents stringByAppendingString:attributeString];
        }
    }
    return newImageTagContents;
}

- (NSString *)placeholderTagContents {
    NSString *newImageTagContents = @"";
    NSDictionary *attributes = [self.attributes copy];

    for (NSString *attribute in attributes) {
        NSString *value = attributes[attribute];
        if (value) {
            NSString *attributeString = [@[@" data-", attribute, @"=\"", value, @"\""] componentsJoinedByString:@""];
            newImageTagContents = [newImageTagContents stringByAppendingString:attributeString];
        }
    }

    NSString *width = attributes[@"width"];
    if (width) {
        NSString *attributeString = [@[@" style=\"width:", width, @"px;\""] componentsJoinedByString:@""];
        newImageTagContents = [newImageTagContents stringByAppendingString:attributeString];
    }
    newImageTagContents = [newImageTagContents stringByAppendingString:@" class=\"pagelib_lazy_load_placeholder pagelib_lazy_load_placeholder_pending\""];

    return newImageTagContents;
}

- (void)setValue:(NSString *)value forAttribute:(NSString *)attribute {
    if (!value || !attribute) {
        return;
    }
    _mutableAttributes[attribute] = value;
}

@end

NS_ASSUME_NONNULL_END
