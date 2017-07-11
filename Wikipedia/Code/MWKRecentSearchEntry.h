#import <WMF/MWKSiteDataObject.h>
#import <WMF/MWKList.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWKRecentSearchEntry : MWKSiteDataObject <MWKListObject>

@property (readonly, copy, nonatomic) NSString *searchTerm;
@property (readonly, copy, nonatomic) NSString *displayTitle;

- (instancetype)initWithURL:(NSURL *)url searchTerm:(NSString *)searchTerm displayTitle:(nullable NSString *)displayTitle;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
