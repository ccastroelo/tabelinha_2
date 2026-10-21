//
//  tabCell.m
//  tabelinha
//
//  Created by claudio on 16/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import "tabCell.h"

@implementation tabCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)setTelaMaior:(BOOL)telaMaior
{
/*    _telaMaior = telaMaior;
    CGRect frameEsq = self.imgCellEsq.frame;
    CGRect frameDir = self.imgCellDir.frame;
    CGRect frameCenter = self.imgCell.frame;
    CGRect frameIcon = self.imgCellIcon.frame;
    CGRect frameLabel = self.labelCell.frame;
    if (_telaMaior) {
            frameEsq.origin.y = 9;
            frameDir.origin.y = 9;
            frameCenter.origin.y = 9;
            frameLabel.origin.y = 4;
            frameIcon.origin.y = 5;
//        frameEsq.origin.y = 8;
//        frameDir.origin.y = 8;
//        frameCenter.origin.y = 8;
//        frameLabel.origin.y = 3;
//        frameIcon.origin.y = 4;
        
    }else{
            frameEsq.origin.y = 5;
            frameDir.origin.y = 5;
            frameCenter.origin.y = 5;
            frameLabel.origin.y = 0;
            frameIcon.origin.y = 2;
    }
    
    // celula das bordas sao maiores
    frameEsq.origin.x = 0;
    frameCenter.origin.x = 10;
    frameCenter.size.width = 25;
    frameDir.origin.x = 35;
    if (self.frame.size.width == 48) {
        frameEsq.origin.x = 0;
        frameCenter.origin.x = 10;
        frameCenter.size.width = 28;
        frameDir.origin.x = 38;
    }
    if (self.frame.size.width == 47) {
        frameEsq.origin.x = 0;
        frameCenter.origin.x = 10;
        frameCenter.size.width = 27;
        frameDir.origin.x = 37;
    }

    self.imgCellEsq.frame = frameEsq;
    self.imgCellDir.frame = frameDir;
    self.imgCell.frame = frameCenter;
    self.imgCellIcon.frame = frameIcon;
    self.labelCell.frame = frameLabel;
*/
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
