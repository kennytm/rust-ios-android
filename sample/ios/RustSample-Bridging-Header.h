#import <Foundation/Foundation.h>

@interface RustRegex : NSObject
-(instancetype)initWithRegex:(NSString*)regex;
-(void)dealloc;
-(int)find:(NSString*)text;
@end