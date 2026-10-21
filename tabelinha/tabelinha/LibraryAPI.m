//
//  LibraryAPI.m
//  ouvidoria
//
//  Created by Claudio on 22/07/15.
//  Copyright © 2015 MPT. All rights reserved.
//

#import "LibraryAPI.h"
#import "PersistencyManager.h"


@interface LibraryAPI () {
    PersistencyManager *persistencyManager;
}
@end

@implementation LibraryAPI 

- (id)init{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
    }
    return self;
}

- (NSArray *)getPeriodos{
    return [persistencyManager getPeriodos];
}

- (void)addPeriodo:(Periodo *)periodo atIndex:(int)index{
    [persistencyManager addPeriodo:periodo atIndex:index];
}

- (void)deletePeriodo:(Periodo *)periodo {
    [persistencyManager deletePeriodo:periodo];
}

- (void)savePeriodos{
    [persistencyManager savePeriodos];
}

- (void)deletePeriodoWithInd:(NSInteger)ind{
    [persistencyManager deletePeriodoWithInd:ind];
}


+(LibraryAPI *) sharedInstance{
    static LibraryAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    return _sharedInstance;
}



@end
