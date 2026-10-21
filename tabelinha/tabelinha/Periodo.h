//
//  periodo.h
//  tabelinha
//
//  Created by Claudio on 23/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Periodo : NSObject

@property (nonatomic, strong) NSNumber *ind;

@property (nonatomic, strong) NSDate *inicio;
@property (nonatomic, strong) NSDate *fim;

@property (nonatomic, strong) NSString *refMes;
@property (nonatomic, strong) NSString *refAno;

@property (nonatomic, strong) NSString *obs;



- (id)initWithInicio:(NSDate *)inicio fim:(NSDate *)fim refMes:(NSString *)refMes refAno:(NSString *)refAno;
    
@end
