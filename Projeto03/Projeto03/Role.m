//
//  Roles.m
//  Projeto03
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 11/03/14.
//  Copyright (c) 2014 ARTHUR HENRIQUE VIEIRA DE OLIVEIRA. All rights reserved.
//

#import "Role.h"

@implementation Role

- (id)init
{
    self = [super init];
    if (self) {
        self.convidados = [[NSMutableArray alloc] init];
    }
    return self;
}

- (Role*)clonar
{
    Role *novoRole = [[Role alloc] init];
    
    novoRole.dono = self.dono;
    novoRole.descricao = self.descricao;
    novoRole.endereco = self.endereco;
    novoRole.data = self.data;
    novoRole.convidados = self.convidados;
    novoRole.publico = self.publico;
    novoRole._id = self._id;
    
    return novoRole;
}

- (void)copiarCamposDe:(Role*)role
{
    self.dono = role.dono;
    self.descricao = role.descricao;
    self.endereco = role.endereco;
    self.data = role.data;
    self.convidados = role.convidados;
    self.publico = role.publico;
    self._id = role._id;
}

@end