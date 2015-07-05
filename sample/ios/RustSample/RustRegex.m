#import "RustSample-Bridging-Header.h"
#include "rust_regex.h"

@implementation RustRegex {
    Regex* _regex;
}

-(instancetype)initWithRegex:(NSString *)regex {
    if ((self = [super init])) {
        _regex = rust_regex_create([regex UTF8String]);
    }
    return self;
}

-(void)dealloc {
    if (_regex) {
        rust_regex_destroy(_regex);
        _regex = NULL;
    }
}

-(int)find:(NSString*)text {
    if (_regex) {
        return rust_regex_find(_regex, [text UTF8String]);
    } else {
        return -1;
    }
}

@end
