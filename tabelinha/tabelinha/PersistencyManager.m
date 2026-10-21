//
//  PersistencyManager.m
//  ouvidoria
//
//  Created by Claudio on 22/07/15.
//  Copyright © 2015 MPT. All rights reserved.
//

#import "PersistencyManager.h"

@implementation PersistencyManager

NSMutableArray * periodos;

- (id)init{
    self = [super init];
    if (self) {
        NSData *dataPeriodos = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/periodos.bin"]];
        periodos = [NSKeyedUnarchiver unarchiveObjectWithData:dataPeriodos];
        if (periodos == nil) {
            periodos = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)getPeriodos{
    return periodos;
}

- (void)addPeriodo:(Periodo *)periodo atIndex:(int)index{
//    if (periodos.count >= index){
//        [periodos insertObject:periodo atIndex:index];
//    }else{
    NSInteger ind;
    if ([periodos count] == 0) {
        ind = 1;
    }else{
        ind = [[[periodos lastObject] ind] integerValue]+1;
    }
    periodo.ind = [NSNumber numberWithInteger:ind];
    [periodos addObject:periodo];
//    }
}

- (void)deletePeriodo:(Periodo *)periodo{
    [periodos removeObject:periodo];
}

- (void)deletePeriodoWithInd:(NSInteger)ind{
    int index = 0;
    for (Periodo *periodo in periodos) {
        if ([periodo.ind integerValue] == ind) {
            [periodos removeObjectAtIndex:index];
            break;
        }
        index++;
    }
}

- (void)savePeriodos{
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/periodos.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:periodos];
    [data writeToFile:filename atomically:YES];
}

@end
