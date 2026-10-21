//
//  ajudaViewController.m
//  tabelinha
//
//  Created by claudio on 11/02/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import "ajudaViewController.h"
#import "Flurry.h"
#import "iRate.h"

@interface ajudaViewController ()

@end

@implementation ajudaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Carregou help"];
    self.title = NSLocalizedString(@"Ajuda",nil);
    self.txtHelp.text = NSLocalizedString(@"Texto Ajuda",nil);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
/*    UIBarButtonItem * btnBack = [[UIBarButtonItem alloc]init];
    btnBack.title = @"";
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"Btn_Voltar"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"Btn_Voltar"];
    self.navigationItem.backBarButtonItem = btnBack;
  */  
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)voltar:(id)sender {
            [self.navigationController popViewControllerAnimated:YES];
//            [[iRate sharedInstance] promptIfAllCriteriaMet];
}
@end
