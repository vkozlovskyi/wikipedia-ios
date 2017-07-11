#import <WMF/MWKRecentSearchEntry.h>
#import <WMF/WMFComparison.h>
#import <WMF/NSURL+WMFLinkParsing.h>
#import <WMF/WMFHashing.h>

@interface MWKRecentSearchEntry ()

@property (readwrite, copy, nonatomic) NSString *searchTerm;
@property (readwrite, copy, nonatomic) NSString *displayTitle;

@end

@implementation MWKRecentSearchEntry

- (instancetype)initWithURL:(NSURL *)url searchTerm:(NSString *)searchTerm displayTitle:(nullable NSString *)displayTitle {
    url = [NSURL wmf_desktopURLForURL:url];
    NSParameterAssert(url);
    NSParameterAssert(searchTerm);
    self = [self initWithURL:url];
    if (self) {
        self.searchTerm = searchTerm;
        self.displayTitle = displayTitle;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    NSString *urlString = dict[@"url"];
    NSString *domain = dict[@"domain"];
    NSString *language = dict[@"language"];

    NSURL *url;

    if ([urlString length]) {
        url = [NSURL URLWithString:urlString];
    } else if (domain && language) {
        url = [NSURL wmf_URLWithDomain:domain language:language];
    } else {
        return nil;
    }

    NSString *searchTerm = dict[@"searchTerm"];
    NSString *displayTitle = dict[@"displayTitle"];
    self = [self initWithURL:url searchTerm:searchTerm displayTitle:displayTitle];
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", [super description], self.searchTerm, self.displayTitle ?: @""];
}

WMF_SYNTHESIZE_IS_EQUAL(MWKRecentSearchEntry, isEqualToRecentSearch:)

- (BOOL)isEqualToRecentSearch:(MWKRecentSearchEntry *)rhs {
    return WMF_RHS_PROP_EQUAL(url, isEqual:) && WMF_RHS_PROP_EQUAL(searchTerm, isEqualToString:);
}

- (NSUInteger)hash {
    return self.searchTerm.hash ^ flipBitsWithAdditionalRotation(self.url.hash, 1);
}

#pragma mark - MWKListObject

- (id<NSCopying>)listIndex {
    return self.searchTerm;
}

- (id)dataExport {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setValue:[self.url absoluteString] forKey:@"url"];
    [dictionary setValue:self.searchTerm forKey:@"searchTerm"];
    [dictionary setValue:self.displayTitle forKey:@"displayTitle"];
    return dictionary;
}

@end
