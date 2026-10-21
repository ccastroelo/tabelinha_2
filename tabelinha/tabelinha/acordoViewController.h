//
//  acordoViewController.h
//  tabelinha
//
//  Created by claudio on 23/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface acordoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *myCheckBoxButton;
- (IBAction)myCheckboxToggle:(id)sender;
- (IBAction)OkPressionado:(id)sender;
@property (strong, nonatomic) IBOutlet UINavigationItem *titulo;
@property (strong, nonatomic) IBOutlet UILabel *textoAcordo;
@property (strong, nonatomic) IBOutlet UILabel *deAcordo;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end
