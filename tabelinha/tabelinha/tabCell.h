//
//  tabCell.h
//  tabelinha
//
//  Created by claudio on 16/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tabCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelCell;
@property (weak, nonatomic) IBOutlet UIImageView *imgCell;
@property (weak, nonatomic) IBOutlet UIImageView *imgCellEsq;
@property (weak, nonatomic) IBOutlet UIImageView *imgCellDir;
@property (weak, nonatomic) IBOutlet UIImageView *imgCellIcon;
@property (nonatomic) BOOL telaMaior;

@end
