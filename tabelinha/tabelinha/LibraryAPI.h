//
//  LibraryAPI.h
//  ouvidoria
//
//  Created by Claudio on 22/07/15.
//  Copyright © 2015 MPT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Periodo.h"

@interface LibraryAPI : NSObject

+ (LibraryAPI *)sharedInstance;
- (NSArray *)getPeriodos;
- (void)addPeriodo:(Periodo *)periodo atIndex:(int)index;
- (void)deletePeriodo:(Periodo *)periodo;
- (void)deletePeriodoWithInd:(NSInteger)ind;
- (void)savePeriodos;

@end
