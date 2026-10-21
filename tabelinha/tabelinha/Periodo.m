//
//  periodo.m
//  tabelinha
//
//  Created by Claudio on 23/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import "Periodo.h"

@implementation Periodo

- (id)initWithInicio:(NSDate *)inicio fim:(NSDate *)fim refMes:(NSString *)refMes refAno:(NSString *)refAno{
    self = [super init];
    if(self){
        _inicio = inicio;
        _fim = fim;
        _refMes = refMes;
        _refAno = refAno;
        _ind = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.inicio    forKey:@"inicio"];
    [aCoder encodeObject:self.fim       forKey:@"fim"];
    [aCoder encodeObject:self.refMes    forKey:@"refMes"];
    [aCoder encodeObject:self.refAno    forKey:@"refAno"];
    [aCoder encodeObject:self.ind       forKey:@"ind"];
    [aCoder encodeObject:self.obs       forKey:@"obs"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _inicio = [aDecoder decodeObjectForKey:@"inicio"];
        _fim    = [aDecoder decodeObjectForKey:@"fim"];
        _refAno = [aDecoder decodeObjectForKey:@"refAno"];
        _refMes = [aDecoder decodeObjectForKey:@"refMes"];
        _ind    = [aDecoder decodeObjectForKey:@"ind"];
        _obs    = [aDecoder decodeObjectForKey:@"obs"];
    }
    return  self;
}


@end
