//
//  historicoTableViewCell.m
//  tabelinha
//
//  Created by Claudio on 19/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import "historicoTableViewCell.h"

@implementation historicoTableViewCell

- (IBAction)clicouObservacao:(UIButton *)sender{
    [self.delegate abreObservacao:sender];
}

@end
