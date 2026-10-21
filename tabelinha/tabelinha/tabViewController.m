//
//  tabViewController.m
//  tabelinha
//
//  Created by claudio on 16/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import "tabViewController.h"
#import "tabCell.h"
#import "acordoViewController.h"
#import "Flurry.h"
#import "PickerAlertView.h"
#import "Periodo.h"
#import "historicoTableViewController.h"



@interface tabViewController ()
{
    int duracaoCiclo;
    int duracaoPeriodo;
    int fonteFator;
}

@property (strong, nonatomic) NSMutableArray *arrayLabel;
@property (strong, nonatomic) NSMutableArray *arrayCor;
@property (strong, nonatomic) NSMutableArray *arrayImg;
@property (strong, nonatomic) NSDate *dataDoCalendario;
@property (strong, nonatomic) NSDate *inicioCiclo;
@property (strong, nonatomic) NSDate *dataAtual;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *formatoBrasileiro;
@property (strong, nonatomic) Periodo *periodo;

@property (strong, nonatomic) NSDate *mesInicio1;
@property (strong, nonatomic) NSDate *mesInicio2;
@property (strong, nonatomic) NSDate *mesFim1;
@property (strong, nonatomic) NSDate *mesFim2;
@property (strong, nonatomic) NSString *refMes;
@property (strong, nonatomic) NSString *refAno;


@end

@implementation tabViewController


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(CGFloat) altura{
    return self.view.frame.size.height;
}
-(CGFloat) largura{
    return self.view.frame.size.width;
}

-(BOOL)isDataIguais:(NSDate *)data1 outraData:(NSDate *)data2{
    return ([[self formatoMeioDia:data1] compare:[self formatoMeioDia:data2]] == NSOrderedSame);
}

-(NSDate *)formatoMeioDia:(NSDate *)date_
{
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date_];
    
    // Set the time components manually
    [dateComps setHour:11];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *dataFormatada = [self.calendar dateFromComponents:dateComps];
    
    return dataFormatada;
}

-(NSDate *)strParaFormatoMeioDia:(NSString *)string_
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSString *dataEHora = [NSString stringWithFormat:@"%@ 11:00", string_];
    NSDate *dataBruta = [dateFormatter dateFromString:dataEHora];
 
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:dataBruta];
    
    // Set the time components manually
    [dateComps setHour:11];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *dataFormatada = [self.calendar dateFromComponents:dateComps];
  
    return dataFormatada;
}




-(NSString *)mesPorExtenso:(NSDate *)date_
{
    int mes = [self getMonth:date_];
    NSArray *arrayMes = [[NSMutableArray alloc] initWithObjects: @"M01", @"M02", @"M03", @"M04", @"M05", @"M06", @"M07", @"M08", @"M09", @"M10", @"M11", @"M12", nil];
    
    return [arrayMes objectAtIndex:mes-1];
}

-(int)getMonth:(NSDate *)date_
{
    NSDateComponents *dateComps = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date_];
    
    // Set the time components manually
    int month = (int)dateComps.month;
    
    return month;
    
}

-(NSDate *)primeiroDiaDoMes:(NSDate *)date_
{
    
    
    NSDateComponents *dateComps = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date_];
    
    // Set the time components manually
    [dateComps setDay:1];
    [dateComps setHour:12];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *dataFormatada = [self.calendar dateFromComponents:dateComps];
    
    return dataFormatada;
    
}

-(int)getWeekDay:(NSDate*)date_
{
    NSDate *inicioMes = [self primeiroDiaDoMes:date_];
 
    NSDateComponents *comps = [self.calendar components:NSWeekdayCalendarUnit fromDate:inicioMes];
    int weekday = (int)[comps weekday];
    
    return weekday;
    
}

-(int)numberOfDayInAMonth:(NSDate *)date_
{
    NSRange rng = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date_];
    NSUInteger numberOfDaysInMonth = rng.length;
    return (int)numberOfDaysInMonth;
}

-(NSString *)anoPorExtenso:(NSDate *)date_
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *ano;
    ano = [formatter stringFromDate:date_];
    return ano;
}

-(void)preencheCalendario:(NSDate *)date_
{
    self.mesInicio1 = nil;
    self.mesFim1 = nil;
    self.mesInicio2 = nil;
    self.mesFim2 = nil;
    self.refMes = nil;
    self.refAno = nil;
    
    self.dataDoCalendario = date_;
    [[self labelMes] setText: NSLocalizedString([self mesPorExtenso:date_], @"Titulo default do botao")];
    
    //    [[self labelAno] setText:[self anoPorExtenso:date_]];
    int diaSemana = [self getWeekDay:date_];
    
    [self.arrayLabel removeAllObjects];
    [self.arrayImg removeAllObjects];
    [self.arrayCor removeAllObjects];
    
    NSArray *arrayDiaSemana = [[NSArray alloc] initWithObjects: @"D1", @"D2", @"D3", @"D4", @"D5", @"D6", @"D7", nil];
    for (int j = 0; j <= 6; j++)
    {
        [self.arrayImg insertObject:@"" atIndex:j];
        [self.arrayLabel insertObject:NSLocalizedString([arrayDiaSemana objectAtIndex:j],nil) atIndex:j];
        [self.arrayCor insertObject:[NSNumber numberWithInt:0] atIndex:j];
    }
    
    
    
    
    int diasNoMes = [self numberOfDayInAMonth:date_];
    bool cicloIniciado = NO;
    bool inicio = NO;
    
    NSDate *mesInicio;
    NSDate *mesFim;
    
    int statusDaCelula;
    
    int k = 0;
    for (int i = 0; i <= 41; i++)
    {
        [self.arrayImg insertObject:@"" atIndex:i+7];
        if (i+1 < diaSemana || i+1 >= (diaSemana+diasNoMes)) {
            [self.arrayLabel insertObject:@"" atIndex:i+7];
            [self.arrayCor insertObject:[NSNumber numberWithInt:0] atIndex:i+7];
        } else {
            k++;
            [self.arrayLabel insertObject:[NSString stringWithFormat:@"%i",k] atIndex:i+7];
            if (self.inicioCiclo){
                [self.arrayCor insertObject:[self retornaStatusDaCelula:date_ diaCalendario:k] atIndex:i+7];
                statusDaCelula = [[self retornaStatusDaCelula:date_ diaCalendario:k] intValue];
            }else{
                [self.arrayCor insertObject:[NSNumber numberWithInt:0] atIndex:i+7];
                statusDaCelula = 0;
            }
            if ([self diferencaEntreDatas:date_ diaParaAReferencia:k dataParaCalculo:self.dataAtual] == 0) {
                [self.arrayImg replaceObjectAtIndex:i+7 withObject:[NSNumber numberWithInt:1]];
            }
            
            // pega o primeiro dia do ciclo e calcula a data final com base na duracao do periodo
            // depois pega o ultimo dia do ciclo e checa se do inicio ate o fim a quantidade de dias
            // é a mesma da duracao
            // se for ok, se não for e o inicio é o primeiro dia do mës, é pq o inicio real é no mês anterior
            
            
            if (!inicio && statusDaCelula == 1 && !cicloIniciado){
                inicio = YES;
                mesInicio = [self strParaFormatoMeioDia:[NSString stringWithFormat:@"%@-%d-%d", [self anoPorExtenso:date_],  [self getMonth:date_], k]];
                mesFim = [self calculaData:mesInicio dias:duracaoPeriodo-1];
                cicloIniciado = YES;
            }
            if (mesInicio && cicloIniciado && (statusDaCelula != 1 || (i+2 >= (diaSemana+diasNoMes)))      ) {
                cicloIniciado = NO;
                if (([self diferencaEntreDatas:date_ diaParaAReferencia:k dataParaCalculo:mesInicio]-duracaoPeriodo < 0) &&  [self isDataIguais:[self primeiroDiaDoMes:date_ ] outraData:mesInicio]) {
                    inicio = NO;
                }else{
                    self.refMes = [self mesPorExtenso:date_];
                    self.refAno = [self anoPorExtenso:date_];
                    if (self.mesInicio1){
                        self.mesInicio2 = [mesInicio copy];
                        self.mesFim2 = [mesFim copy];
                    }else{
                        self.mesInicio1 = [mesInicio copy];
                        self.mesFim1 = [mesFim copy];
                        inicio = NO;
                        mesInicio = nil;
                        mesFim = nil;
                        
                    }
                }
            }
        }
    }
    [[self myCollectionView ]reloadData];
}

-(NSNumber *)retornaStatusDaCelula:(NSDate *)mesAnoCalendario diaCalendario:(int)diaCalendario
{
    NSNumber *status;
    status = [NSNumber numberWithInt:0];
    int dias = [self diferencaEntreDatas:mesAnoCalendario diaParaAReferencia:diaCalendario dataParaCalculo:self.inicioCiclo];

    
    if(dias >= duracaoCiclo){
        dias = dias % duracaoCiclo;
    }
    
    if(dias < 0){
        NSDate *inicioCicloAnterior = [self calculaData:self.inicioCiclo dias:(-duracaoCiclo)];
        dias = [self diferencaEntreDatas:mesAnoCalendario diaParaAReferencia:diaCalendario dataParaCalculo:inicioCicloAnterior];
    }
    // 1 - menstrucao forte 2 - menstruacao acabando
    // 3 - fertil forte 4 - fertil acabando/iniciando

    if (dias >= 0 && dias < duracaoPeriodo) { // mudado aqui
            status = [NSNumber numberWithInt:1];
    }
    
    if(dias >= duracaoCiclo/2-4 && dias <= duracaoCiclo/2+4){
            status = [NSNumber numberWithInt:3];
    }

    if(dias == duracaoCiclo/2){
            status = [NSNumber numberWithInt:9];
    }
    
    return status;
}

-(int)diferencaEntreDatas:(NSDate *)dataComMesEAnoDeReferencia diaParaAReferencia:(int)diaParaAReferencia dataParaCalculo:(NSDate *)dataParaCalculo
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *mesAnoString = [formatter stringFromDate:dataComMesEAnoDeReferencia];

    
    NSString *inicio = [NSString stringWithFormat:@"%@-%02d", mesAnoString, diaParaAReferencia ];
    
    
    NSDate *dataParaCalculo2 = [self strParaFormatoMeioDia:inicio];
    
    NSInteger startDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                       inUnit: NSEraCalendarUnit forDate:dataParaCalculo];
    NSInteger endDay=[self.calendar ordinalityOfUnit:NSDayCalendarUnit
                                     inUnit: NSEraCalendarUnit forDate:dataParaCalculo2];

        
    return (int)(endDay-startDay);
}

-(NSDate *)calculaData:(NSDate *)date_ dias:(int)numDias
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:numDias];
    NSDate *newDate = [self.calendar dateByAddingComponents:components toDate:date_ options:0];
    return newDate;
}

- (IBAction)abrePicker:(UIButton *)sender {
    [self abreViewDeslizante:YES];
}

-(IBAction)avancaMes:(id)sender
{
    NSDate *dataAuxiliar = [self.dataDoCalendario copy];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:1]; // note that I'm setting it to -1
     self.dataDoCalendario = [self.calendar dateByAddingComponents:offsetComponents toDate:dataAuxiliar options:0];
    [self preencheCalendario:self.dataDoCalendario];
}

-(IBAction)retrocedeMes:(id)sender
{
    NSDate *dataAuxiliar = [self.dataDoCalendario copy];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-1]; // note that I'm setting it to -1
    self.dataDoCalendario = [self.calendar dateByAddingComponents:offsetComponents toDate:dataAuxiliar options:0];
    [self preencheCalendario:self.dataDoCalendario];
}


-(void)hoje:(id)sender
{
    NSDate *now = [self formatoMeioDia:[NSDate date]];
    self.txtInicioCiclo.text = [self.formatoBrasileiro stringFromDate:now];

 
    self.inicioCiclo = now;
    [self preencheCalendario:now];
    [self gravaDados];
}

- (IBAction)somaPeriodo:(id)sender
{
    duracaoPeriodo = [self.txtDuracaoPeriodo.text intValue]+1;
    if (duracaoPeriodo>9) {
        duracaoPeriodo = 9;
    }
    self.txtDuracaoPeriodo.text = [NSString stringWithFormat:@"%i",duracaoPeriodo];
    [self preencheCalendario:self.dataDoCalendario];
    [self gravaDados];
}


- (IBAction)subtraiPeriodo:(id)sender
{
    duracaoPeriodo = [self.txtDuracaoPeriodo.text intValue]-1;
    if (duracaoPeriodo<1) {
        duracaoPeriodo = 1;
    }
    self.txtDuracaoPeriodo.text = [NSString stringWithFormat:@"%i",duracaoPeriodo];
    [self preencheCalendario:self.dataDoCalendario];
    [self gravaDados];
}


-(IBAction)somaDuracao:(id)sender
{
    duracaoCiclo = [self.txtDuracaoCiclo.text intValue]+1;
    if (duracaoCiclo>55) {
        duracaoCiclo = 55;
    }
    self.txtDuracaoCiclo.text = [NSString stringWithFormat:@"%i",duracaoCiclo];
    [self preencheCalendario:self.dataDoCalendario];
    [self gravaDados];
}

-(IBAction)subtraiDuracao:(id)sender;
{
    duracaoCiclo = [self.txtDuracaoCiclo.text intValue]-1;
    if (duracaoCiclo<8) {
        duracaoCiclo = 8;
    }
    self.txtDuracaoCiclo.text = [NSString stringWithFormat:@"%i",duracaoCiclo];
    [self preencheCalendario:self.dataDoCalendario];
    [self gravaDados];
}

- (IBAction)salvar:(UIButton *)sender {
    NSDate *dateSelected = [self formatoMeioDia:self.datePickerViewIOS7.date];
    self.inicioCiclo = dateSelected;
    [self preencheCalendario:dateSelected];
    self.txtInicioCiclo.text = [self.formatoBrasileiro stringFromDate:dateSelected];
    [self gravaDados];
    [self abreViewDeslizante:NO];
}

- (IBAction)cancelar:(UIButton *)sender {
    [self abreViewDeslizante:NO];
}


- (void)carregaAcordo {
    acordoViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"acordoViewController"];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"acordado"]==nil){
        [self carregaAcordo];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([self altura] <= 480) {
    }

    self.dataAtual = [self formatoMeioDia:[NSDate date]];
    // if abaixo necessário para quem já tinha o app antes da atualização
    // não tirar
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"duracaoperiodo"]==nil){
        duracaoPeriodo = 5;
        [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"duracaoperiodo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"iniciociclo"]==nil){
        self.inicioCiclo = nil;
        duracaoCiclo = 28;
        duracaoPeriodo = 5;
    }else{
        self.inicioCiclo = [[NSUserDefaults standardUserDefaults] objectForKey:@"iniciociclo"];
        self.txtDuracaoCiclo.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"duracaociclo"];
        self.txtDuracaoPeriodo.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"duracaoperiodo"];
        duracaoCiclo = [self.txtDuracaoCiclo.text intValue];
        duracaoPeriodo = [self.txtDuracaoPeriodo.text intValue];
        self.txtInicioCiclo.text = [self.formatoBrasileiro stringFromDate:self.inicioCiclo];
    }
    [self preencheCalendario:self.dataAtual];
    if ([self.txtInicioCiclo.text isEqualToString: @"01/01/2000"]) {
        [self hoje:nil];
    }
}


-(void)gravaDados
{
    NSDate *strInicioCiclo;
    NSString *strDuracao;
    NSString *strPeriodo;
    strInicioCiclo = self.inicioCiclo;
    strDuracao = self.txtDuracaoCiclo.text;
    strPeriodo = self.txtDuracaoPeriodo.text;
    [[NSUserDefaults standardUserDefaults] setObject:strInicioCiclo forKey:@"iniciociclo"];
    [[NSUserDefaults standardUserDefaults] setObject:strDuracao forKey:@"duracaociclo"];
    [[NSUserDefaults standardUserDefaults] setObject:strPeriodo forKey:@"duracaoperiodo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)abreViewDeslizante:(BOOL)abrir{
    NSDate *now = [self formatoMeioDia:[NSDate date]];
    CGRect frame = self.viewDeslizante.frame;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        PickerAlertView *pickerAlertView = [[PickerAlertView alloc] initWithTitle:@" " message:@" " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancelar",nil) otherButtonTitles:@"OK", nil];
        [pickerAlertView show];
    }else{
        if (abrir) {
            [self.datePickerViewIOS7 setDate:now];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            self.viewDeslizante.center = CGPointMake(frame.size.width/2, self.altura-(frame.size.height/2));
            [UIView commitAnimations];
        }
        if (!abrir) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            self.viewDeslizante.center = CGPointMake(frame.size.width/2, self.altura+(frame.size.height/2));
            [UIView commitAnimations];
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(PickerAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        NSDate *dateSelected = [self formatoMeioDia:alertView.datePickerView.date];
        self.inicioCiclo = dateSelected;
        [self preencheCalendario:dateSelected];
        self.txtInicioCiclo.text = [self.formatoBrasileiro stringFromDate:dateSelected];
        [self gravaDados];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    fonteFator = 0;
    CGFloat fonte = self.lblDuracao.font.pointSize;
    if ([self altura] >= 667) {
        fonteFator = 2;
    }
    self.lblDuracao.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.lblInicio.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.lblTopMenstruacao.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.txtDuracaoCiclo.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.txtDuracaoPeriodo.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.txtInicioCiclo.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.labelMes.font = [UIFont fontWithName: @"HelveticaNeue-Bold" size:fonte+fonteFator];
    self.btCancelar.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.btOk.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    
    fonte = self.lblMenstruacao.font.pointSize;
    self.lblMenstruacao.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.lblPeriodo.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.lblOvulacao.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    self.lblHoje.font = [UIFont fontWithName: @"HelveticaNeue" size:fonte+fonteFator];
    
    [self.btCancelar setTitle:NSLocalizedString(@"Cancelar",nil) forState:UIControlStateNormal];
    
    
    self.lblDuracao.text = NSLocalizedString(@"Duracao",nil);
    self.lblInicio.text = NSLocalizedString(@"Inicio",nil);
    self.lblPick.text = NSLocalizedString(@"Inicio",nil);
    self.lblMenstruacao.text = NSLocalizedString(@"Menstruacao",nil);
    self.lblTopMenstruacao.text = NSLocalizedString(@"Menstruacao",nil);
    self.lblPeriodo.text = NSLocalizedString(@"Periodo",nil);
    self.lblOvulacao.text = NSLocalizedString(@"Ovulacao",nil);
    self.lblHoje.text = NSLocalizedString(@"Hoje",nil);
    [self.btCancelar setTitle:NSLocalizedString(@"Cancelar",nil) forState:UIControlStateNormal];
    self.title =  NSLocalizedString(@"Tabelinha",nil);
//    self.viewLegenda.backgroundColor = [UIColor redColor];
    
    CGRect frameLegenda = self.viewLegenda.frame;
    CGRect frameGrupo = self.viewGrupo.frame;
    if ([self altura] <= 480) {
//        self.viewGrupo.hidden = YES;
//        self.imagemBarra.hidden = YES;

        self.viewLegendaAlturaConstraint.constant = 52;
        self.bolaLegendaDistanciaFromBottomConstraint.constant = 1;
        self.viewCalendarioDistanciaFromBottomConstraint.constant = -42; //-55; //-20;
//        frameLegenda.origin.y = 410;
//        frameGrupo.origin.y = 157;
    }else{
//        self.viewCalendarioDistanciaFromBottomConstraint.constant = 15;
//        frameLegenda.origin.y = 460;
//        frameLegenda.origin.y = 474;
//        frameGrupo.origin.y = 166;
    }
    if ([self altura] >= 667) {
        self.viewLegendaDistanciaFromBottomConstraint.constant = 20;
        self.alturaColletion.constant = 290;
    }
    if ([self altura] >= 736) {
        self.viewLegendaDistanciaFromBottomConstraint.constant = 30;
        self.viewCalendarioDistanciaFromBottomConstraint.constant = 60;
        self.alturaColletion.constant = 310;
    }
    self.viewLegenda.frame = frameLegenda;
    self.viewGrupo.frame = frameGrupo;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[self myCollectionView] setDelegate:self];
    [[self myCollectionView] setDataSource:self];

    self.calendar = [NSCalendar currentCalendar];
    [self.calendar setTimeZone: [NSTimeZone systemTimeZone]];
    [self.calendar setLocale:[NSLocale currentLocale]];
    self.formatoBrasileiro = [[NSDateFormatter alloc] init];
    [self.formatoBrasileiro setDateStyle: NSDateFormatterShortStyle];
    [self.formatoBrasileiro setTimeZone:[NSTimeZone systemTimeZone]];
    
 
    self.arrayLabel = [[NSMutableArray alloc] init];
    self.arrayImg = [[NSMutableArray alloc] init];
    self.arrayCor = [[NSMutableArray alloc] init];

    self.inicioCiclo = [[NSDate alloc] init];

}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrayLabel count];
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int alt = 35;
    if ([self altura] <= 480) {
        alt = 30;
    }
    if ([self altura] == 736) {
        alt = 45;
    }

    int lag = floor([self largura]/7);
    if(fmod(indexPath.item,7) == 0)
    {
        lag  = floor([self largura]/7)+3;
    }
    if(fmod(indexPath.item,7) == 6)
    {
        lag  = floor([self largura]/7)+([self largura]-((floor([self largura]/7)*7)+3));
    }
    CGSize sz = CGSizeMake(lag, alt);
    return sz;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    
    tabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    [cell setTelaMaior:([self altura] > 480)];
    int fonte = 12+fonteFator;
    
    [[cell labelCell]setText:[self.arrayLabel objectAtIndex:indexPath.item]];
    [[cell labelCell] setFont:[UIFont fontWithName: @"HelveticaNeue" size:fonte]];
    [[cell labelCell] setTextColor:[UIColor colorWithRed:0.21 green:0.22 blue:0.23 alpha:1.0]];
    if (indexPath.item < 7) {
            [[cell labelCell] setTextColor:[UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:1.0]];
    }
    
    UIImage *imgCelula;
    UIImage *imgEsq;
    UIImage *imgDir;
    NSString *imgIcon;
    // 1 - menstrucao forte 2 - menstruacao acabando
    // 3 - fertil forte 4 - fertil acabando/iniciando


    if ([[self.arrayImg objectAtIndex:indexPath.item] intValue] == 1){
        imgIcon = [NSString stringWithFormat:@"%@", @"Icone_Hoje"];
    }
    

    int valorAnterior = -1;
    NSIndexPath *fimFaixa;
    int valor = [[self.arrayCor objectAtIndex:indexPath.item] intValue];
    int ultimo = (int)indexPath.item;
    if (ultimo > 0){
        fimFaixa = [NSIndexPath indexPathForItem:ultimo-1 inSection:0];
        valorAnterior = [[self.arrayCor objectAtIndex:fimFaixa.item] intValue];
    }
    
    tabCell *celula = (tabCell *)[collectionView cellForItemAtIndexPath:fimFaixa];
    switch (valor)
    {
        case 1:
            if (valorAnterior == 0 || valorAnterior == -1){
                imgEsq = [UIImage imageNamed:@"Faixa_Menstruacao_ponta_esq"];
            }else{
                imgEsq = [UIImage imageNamed:@"Faixa_Menstruacao"];
                [[celula imgCellDir] setImage:[UIImage imageNamed:@"Faixa_Menstruacao"]];
            }
            imgCelula = [UIImage imageNamed:@"Faixa_Menstruacao"];
            imgDir = [UIImage imageNamed:@"Faixa_Menstruacao_ponta_dir"];
            break;
            
        case 3:
            if (valorAnterior == 0 || valorAnterior == -1){
                imgEsq = [UIImage imageNamed:@"Faixa_fertil_ponta_esq"];
            }else{
                imgEsq = [UIImage imageNamed:@"Faixa_fertil"];
                [[celula imgCellDir] setImage:[UIImage imageNamed:@"Faixa_fertil"]];
            }
            imgCelula = [UIImage imageNamed:@"Faixa_fertil"];
            imgDir = [UIImage imageNamed:@"Faixa_fertil_ponta_dir"];
            break;
        case 9:
            imgIcon = [NSString stringWithFormat:@"%@", @"Icone_Ovulacao"];
            if (valorAnterior == 0 || valorAnterior == -1){
                imgEsq = [UIImage imageNamed:@"Faixa_fertil_ponta_esq"];
            }else{
                imgEsq = [UIImage imageNamed:@"Faixa_fertil"];
                [[celula imgCellDir] setImage:[UIImage imageNamed:@"Faixa_fertil"]];
            }
            imgCelula = [UIImage imageNamed:@"Faixa_fertil"];
            imgDir = [UIImage imageNamed:@"Faixa_fertil_ponta_dir"];
            break;
        default:
            break;
    }
    
    [[cell imgCellEsq] setImage: imgEsq];
    [[cell imgCell]setImage:imgCelula];
    [[cell imgCellDir] setImage: imgDir];
    if (imgIcon) {
        [[cell imgCellIcon] setImage: [UIImage imageNamed:imgIcon]];
    }else{
        [[cell imgCellIcon] setImage: nil];
    }
    if ([imgIcon isEqualToString:@"Icone_Hoje"]){
        [[cell labelCell] setTextColor:[UIColor colorWithRed:1 green:1 blue:1.0 alpha:1]];
    }
    
    return cell;
}

- (IBAction)share:(id)sender
{
    UIImage *desenho = [self printScreen];
    NSArray *activityItems;
    
    if (desenho != nil) {
        activityItems = @[@"", desenho];
    }
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

-(UIImage *)printScreen {
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != &UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            [[window layer] renderInContext:context];
            CGContextRestoreGState(context);
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Periodo *)periodo{
    if (!_periodo) {
        _periodo = [[Periodo alloc] init];
    }
    return _periodo;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"historico"]) {
        historicoTableViewController *histTableView = segue.destinationViewController;
        [histTableView addPeriodo1:self.mesInicio1 fim1:self.mesFim1 inicio2:self.mesInicio2 fim2:self.mesFim2 refMes:self.refMes refAno:self.refAno];
    }
}

@end
