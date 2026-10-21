//
//  PersistencyManager.h
//  ouvidoria
//
//  Created by Claudio on 22/07/15.
//  Copyright © 2015 MPT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Periodo.h"
@interface PersistencyManager : NSObject

- (NSArray *)getPeriodos;
- (void)addPeriodo:(Periodo *)periodo atIndex:(int)index;
- (void)savePeriodos;
- (void)deletePeriodo:(Periodo *)periodo;
- (void)deletePeriodoWithInd:(NSInteger)ind;

@end
