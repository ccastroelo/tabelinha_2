//
//  historicoTableViewController.m
//  tabelinha
//
//  Created by Claudio on 19/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import "historicoTableViewController.h"
#import "LibraryAPI.h"
#import "historicoTableViewCell.h"
#import "iRate.h"
#import "detailViewController.h"


@interface historicoTableViewController()

@property (weak, nonatomic) IBOutlet UINavigationItem *Titulo;
@property (strong, nonatomic) NSMutableArray *periodos;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *formatoBrasileiro;
@property (strong, nonatomic) NSSortDescriptor *fim;
@property (strong, nonatomic) NSArray *descriptors;
- (IBAction)voltar:(id)sender;

@end

@implementation historicoTableViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)abreObservacao:(UIButton *)sender{
    [self.periodos objectAtIndex:sender.tag];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: sender.tag inSection: 0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSLog(@"%f",sender.frame.origin.x);
    
    /* levar celula para a primeira posicao
    ter uma imagem triangular branca q vai aparecer embaixo do icone
    abrir uma janela branca embaixo desse triangulo
    com o textview dentro */
}

- (void) viewDidLoad{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.calendar = [NSCalendar currentCalendar];
    [self.calendar setTimeZone: [NSTimeZone systemTimeZone]];
    [self.calendar setLocale:[NSLocale currentLocale]];
    self.formatoBrasileiro = [[NSDateFormatter alloc] init];
    [self.formatoBrasileiro setDateStyle: NSDateFormatterShortStyle];
    [self.formatoBrasileiro setTimeZone:[NSTimeZone systemTimeZone]];
    
    self.fim = [[NSSortDescriptor alloc] initWithKey:@"fim" ascending:NO];
    self.descriptors = [NSArray arrayWithObjects:self.fim, nil];
    
    self.title =  NSLocalizedString(@"Registros",nil);
  
}

-(int)duracao:(NSDate *)data1 data:(NSDate *)data2
{
    
    NSInteger startDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                                inUnit: NSEraCalendarUnit forDate:data1];
    NSInteger endDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                              inUnit: NSEraCalendarUnit forDate:data2];
    
    
    return (int)(endDay-startDay)+1;
}


- (void) addPeriodo1:(NSDate *)inicio1 fim1:(NSDate *)fim1 inicio2:(NSDate *)inicio2 fim2:(NSDate *)fim2 refMes:(NSString *)refMes refAno:(NSString *)refAno{
    
    if (inicio1) {
        Periodo *novoPeriodo1 = [[Periodo alloc] initWithInicio:inicio1 fim:fim1 refMes:refMes refAno:refAno];
        [[LibraryAPI sharedInstance] addPeriodo:novoPeriodo1 atIndex:99999];
        
    }
    if (inicio2) {
        Periodo *novoPeriodo2 = [[Periodo alloc] initWithInicio:inicio2 fim:fim2 refMes:refMes refAno:refAno];
        [[LibraryAPI sharedInstance] addPeriodo:novoPeriodo2 atIndex:99999];
    }
    [[LibraryAPI sharedInstance] savePeriodos];
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated{
    //    NSSortDescriptor *ano = [[NSSortDescriptor alloc] initWithKey:@"refAno" ascending:NO];
    //    NSSortDescriptor *mes = [[NSSortDescriptor alloc] initWithKey:@"refMes" ascending:NO];
    self.periodos = [NSMutableArray arrayWithArray:[[[LibraryAPI sharedInstance] getPeriodos] sortedArrayUsingDescriptors:self.descriptors]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.periodos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    historicoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[historicoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    int duracao = [self duracao:[[self.periodos objectAtIndex:indexPath.row] inicio] data:[[self.periodos objectAtIndex:indexPath.row] fim]];
    cell.lblMenstruacao.text = [NSString stringWithFormat:@"%d %@", duracao , NSLocalizedString(@"Dias",nil) ];

    cell.lblMenstruacaoInicioFim.text = [NSString stringWithFormat:@"%@ %@    -    %@",NSLocalizedString(@"PeriodoReg",nil), [self.formatoBrasileiro stringFromDate:[[self.periodos objectAtIndex:indexPath.row] inicio]], [self.formatoBrasileiro stringFromDate:[[self.periodos objectAtIndex:indexPath.row] fim]]];
    
    cell.lblTitulo.text = [NSString stringWithFormat:@"%@-%@", NSLocalizedString([[self.periodos objectAtIndex:indexPath.row] refMes],nil), [[self.periodos objectAtIndex:indexPath.row] refAno] ];
    
    int diasMaximos = 9;
    int larguraMinima = 100;
    int larguraMaxima = 300;
    int largura = larguraMinima+((larguraMaxima-larguraMinima)/diasMaximos * duracao);
    
    cell.delegate = self;
    
    cell.lauguraFaixa.constant = largura;
    cell.btObservacao.tag = indexPath.row;
    cell.btObservacao.hidden = ([[self.periodos objectAtIndex:indexPath.row] obs] == nil);
    
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
        [[LibraryAPI sharedInstance] deletePeriodoWithInd:[[[self.periodos objectAtIndex:indexPath.row] ind] integerValue]];
        [[LibraryAPI sharedInstance] savePeriodos];
        [self.periodos removeObjectAtIndex:indexPath.row];
        

        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
       // self.periodos = [NSMutableArray arrayWithArray:[[[LibraryAPI sharedInstance] getPeriodos] sortedArrayUsingDescriptors:self.descriptors]];

         [tableView reloadData];
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if([[segue identifier] isEqualToString:@"detalhe"]){
        [[segue destinationViewController] setPeriodoSel:[self.periodos objectAtIndex:indexPath.row]];
    }

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)voltar:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[iRate sharedInstance] promptIfAllCriteriaMet];
    
}
@end
