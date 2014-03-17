//
//  InfoDeRoleController.h
//  Projeto03
//
//  Created by Arthur Henrique Vieira de Oliveira on 11/03/14.
//  Copyright (c) 2014 ARTHUR HENRIQUE VIEIRA DE OLIVEIRA. All rights reserved.
//

#import "MenuPrincipalController.h"
#import "Role.h"

@interface InfoDeRoleController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imagemAvatar;
@property (weak, nonatomic) IBOutlet UITextView *textoDescricao;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataRole;
@property (weak, nonatomic) IBOutlet UITableView *tabelaConvidados;
@property (weak, nonatomic) IBOutlet UIButton *btnVerNoMapa;

@property (weak) Role *roleAtual;

@property BOOL veioDeMapa;

- (void)mostrarRole:(Role*)role;

@end