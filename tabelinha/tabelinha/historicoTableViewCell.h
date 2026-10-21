//
//  historicoTableViewCell.h
//  tabelinha
//
//  Created by Claudio on 19/10/15.
//  Copyright © 2015 claudio. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol cellDelegate

@required

- (void)abreObservacao:(UIButton *)sender;

@end

@interface historicoTableViewCell : UITableViewCell{
    id <cellDelegate> _delegate;

}
@property (weak, nonatomic) IBOutlet UILabel *lblMenstruacao;
@property (weak, nonatomic) IBOutlet UILabel *lblMenstruacaoInicioFim;
@property (weak, nonatomic) IBOutlet UILabel *lblTitulo;
@property (weak, nonatomic) IBOutlet UIImageView *faixa;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lauguraFaixa;
@property (weak, nonatomic) IBOutlet UIButton *btObservacao;
@property (nonatomic,strong) id delegate;

- (IBAction)clicouObservacao:(UIButton *)sender;

@end
