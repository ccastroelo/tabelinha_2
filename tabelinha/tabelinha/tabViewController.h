//
//  tabViewController.h
//  tabelinha
//
//  Created by claudio on 16/01/13.
//  Copyright (c) 2013 claudio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface tabViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

- (IBAction)abrePicker:(UIButton *)sender;
- (IBAction)avancaMes:(id)sender;
- (IBAction)retrocedeMes:(id)sender;
// - (IBAction)hoje:(id)sender;
- (IBAction)somaDuracao:(id)sender;
- (IBAction)subtraiDuracao:(id)sender;
- (IBAction)salvar:(UIButton *)sender;
- (IBAction)cancelar:(UIButton *)sender;
- (IBAction)share:(id)sender;
- (IBAction)somaPeriodo:(id)sender;
- (IBAction)subtraiPeriodo:(id)sender;


@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerViewIOS7;
@property (strong, nonatomic) IBOutlet UIView *viewDeslizante;
@property (weak, nonatomic) IBOutlet UILabel *labelMes;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *txtInicioCiclo;
@property (weak, nonatomic) IBOutlet UILabel *txtDuracaoCiclo;
@property (weak, nonatomic) IBOutlet UILabel *txtDuracaoPeriodo;
@property (weak, nonatomic) IBOutlet UIView *viewLegenda;
@property (strong, nonatomic) IBOutlet UIView *viewGrupo;
@property (strong, nonatomic) IBOutlet UIImageView *imagemBarra;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewCalendarioDistanciaFromBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *alturaColletion;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewLegendaDistanciaFromBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewLegendaAlturaConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bolaLegendaDistanciaFromBottomConstraint;


@property (strong, nonatomic) IBOutlet UILabel *lblDuracao;
@property (strong, nonatomic) IBOutlet UILabel *lblInicio;
@property (strong, nonatomic) IBOutlet UILabel *lblMenstruacao;
@property (strong, nonatomic) IBOutlet UILabel *lblPeriodo;
@property (strong, nonatomic) IBOutlet UILabel *lblOvulacao;
@property (strong, nonatomic) IBOutlet UILabel *lblHoje;
@property (strong, nonatomic) IBOutlet UIButton *btCancelar;
@property (strong, nonatomic) IBOutlet UIButton *btOk;
@property (strong, nonatomic) IBOutlet UILabel *lblPick;
@property (strong, nonatomic) IBOutlet UILabel *lblTopMenstruacao;





@end




