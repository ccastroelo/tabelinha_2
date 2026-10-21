//
//  acordoViewController.m
//  tabelinha
//
//  Created by claudio on 23/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import "acordoViewController.h"

@interface acordoViewController ()
{
    UIImage *checkedImaged;
    UIImage *nonCheckedImage;
}
@end

@implementation acordoViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)myCheckboxToggle:(id)sender
{
    _myCheckBoxButton.selected = !_myCheckBoxButton.selected; // toggle the selected property, just a simple BOOL
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        exit(0);
}
- (IBAction)OkPressionado:(id)sender
{
    if (!_myCheckBoxButton.selected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atencao",nil) message:NSLocalizedString(@"Mensagem",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

    } else {
        NSDate *assinadoEm = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:assinadoEm forKey:@"acordado"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    self.titulo.title = NSLocalizedString(@"Atencao",nil);
    self.textoAcordo.text = NSLocalizedString(@"Texto Acordo",nil);
    self.deAcordo.text = NSLocalizedString(@"De Acordo",nil);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
