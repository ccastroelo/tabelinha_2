//
//  detailViewController.m
//  tabelinha
//
//  Created by Claudio on 25/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import "detailViewController.h"
#import "LibraryAPI.h"

@interface detailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet UILabel *periodo;
@property (weak, nonatomic) IBOutlet UILabel *duracao;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faixa;
@property (strong, nonatomic) IBOutlet UITextView *obs;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *formatoBrasileiro;


- (IBAction)cancelar:(id)sender;
- (IBAction)gravar:(id)sender;

@end

@implementation detailViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar = [NSCalendar currentCalendar];
    [self.calendar setTimeZone: [NSTimeZone systemTimeZone]];
    [self.calendar setLocale:[NSLocale currentLocale]];
    self.formatoBrasileiro = [[NSDateFormatter alloc] init];
    [self.formatoBrasileiro setDateStyle: NSDateFormatterShortStyle];
    [self.formatoBrasileiro setTimeZone:[NSTimeZone systemTimeZone]];
    
    self.title =  NSLocalizedString(@"Anotacoes",nil);
    
    self.obs.layer.borderWidth = .5f;
    self.obs.layer.borderColor = [[UIColor lightGrayColor] CGColor];


    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    self.obs.text = self.periodoSel.obs;
    int duracao = [self duracao:[self.periodoSel inicio] data:[self.periodoSel fim]];
    self.duracao.text = [NSString stringWithFormat:@"%d %@", duracao , NSLocalizedString(@"Dias",nil) ];
    
    self.periodo.text = [NSString stringWithFormat:@"%@ %@    -    %@",NSLocalizedString(@"PeriodoReg",nil), [self.formatoBrasileiro stringFromDate:[self.periodoSel inicio]], [self.formatoBrasileiro stringFromDate:[self.periodoSel fim]]];
    
    self.titulo.text = [NSString stringWithFormat:@"%@-%@", NSLocalizedString([self.periodoSel refMes],nil), [self.periodoSel refAno] ];
    
    int diasMaximos = 8;
    int larguraMinima = 100;
    int larguraMaxima = 300;
    int largura = larguraMinima+((larguraMaxima-larguraMinima)/diasMaximos * duracao);
    
    
    self.faixa.constant = largura;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.obs becomeFirstResponder];
}


- (IBAction)cancelar:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gravar:(id)sender{
    self.periodoSel.obs = self.obs.text;
    [[LibraryAPI sharedInstance] savePeriodos];
    [self.navigationController popViewControllerAnimated:YES];
}

-(int)duracao:(NSDate *)data1 data:(NSDate *)data2
{
    
    NSInteger startDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                                inUnit: NSEraCalendarUnit forDate:data1];
    NSInteger endDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                              inUnit: NSEraCalendarUnit forDate:data2];
    
    
    return (int)(endDay-startDay)+1;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
