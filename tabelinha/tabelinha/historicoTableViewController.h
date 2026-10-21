//
//  historicoTableViewController.h
//  tabelinha
//
//  Created by Claudio on 19/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "periodo.h"
#import "historicoTableViewCell.h"

@interface historicoTableViewController : UITableViewController <cellDelegate>

- (void) addPeriodo1:(NSDate *)inicio1 fim1:(NSDate *)fim1 inicio2:(NSDate *)inicio2 fim2:(NSDate *)fim2 refMes:(NSString *)refMes refAno:(NSString *)refAno;



@end
