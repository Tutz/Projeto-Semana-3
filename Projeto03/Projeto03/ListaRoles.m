//
//  ListaRoles.m
//  Projeto03
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 11/03/14.
//  Copyright (c) 2014 ARTHUR HENRIQUE VIEIRA DE OLIVEIRA. All rights reserved.
//

#import "ListaRoles.h"
#import "Endereco.h"

@implementation ListaRoles

+ (ListaRoles *)lista
{
    static ListaRoles *lista = nil;
    if (!lista)
    {
        lista = [[super allocWithZone:nil] init];
    }
    
    return lista;
}

+ (id)allocWithZone: (struct _NSZone *)zone
{
    return [self lista];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Cria o geocoder
        self.geocoder = [[CLGeocoder alloc] init];
        
        listaDeUsuarios = [[NSMutableArray alloc] init];
        listaDeRoles = [[NSMutableArray alloc] init];
        listaDeDelegates = [[NSMutableArray alloc] init];
        _idUsuarios = 0;
        _idRoles = 0;
        
        
        // Cria uns cadastros aleatórios q
        Usuario *joao = [self getUsuarioPorId:[self adicionarUsuario:@"João" avatar:nil]];
        Usuario *maria = [self getUsuarioPorId:[self adicionarUsuario:@"Maria" avatar:nil]];
        
        [self adicionarRoleDo:joao noEndereco:@"Av Engenheiro Eusébio Stevaux, 823, São Paulo, SP" comDescricao:@"Rolê dos bródê" naData:[NSDate date] comConvidados:nil sendoPublico:false];
        [self adicionarRoleDo:maria noEndereco:@"Rua Manuel FIgueiredo Landim, 600, São Paulo, SP" comDescricao:@"Rolê das mina rçrssrçs" naData:[NSDate date] comConvidados:nil sendoPublico:false];
    }
    return self;
}

- (void)removeEndereco: (Role *)r
{
    [listaDeRoles removeObjectIdenticalTo:r];
}

// Gerenciamento de Usuários
- (int)adicionarUsuario:(NSString*)nome avatar:(UIImage*)avatar
{
    Usuario *user = [[Usuario alloc] init];
    user._nome = nome;
    user._avatar = avatar;
    user._id = _idUsuarios++;
    
    [listaDeUsuarios addObject:user];
    
    return _idUsuarios;
}
- (bool)removerUsuario:(int)idUsuario
{
    Usuario *user = [self getUsuarioPorId:idUsuario];
    
    if(user != nil)
    {
        [listaDeUsuarios removeObjectIdenticalTo:user];
        return true;
    }
    
    return false;
}
- (Usuario*)getUsuarioPorId:(int)idUsuario
{
    for(Usuario *usuario in listaDeUsuarios)
    {
        if(usuario._id == idUsuario)
        {
            return usuario;
        }
    }
    
    return nil;
}
- (int)atualizarUsuario:(Usuario*)usuario
{
    Usuario *usuarioAtual = [self getUsuarioPorId:usuario._id];
    
    if(usuarioAtual == nil)
    {
        return -1;
    }
    
    [usuarioAtual copiarCamposDe:usuario];
    
    return 0;
}


// Gerenciamento de Roles
- (int)adicionarRoleDo:(Usuario *)dono noEndereco:(NSString *)endereco comDescricao:(NSString *)descricao naData:(NSDate *)data comConvidados:(NSMutableArray *)convidados sendoPublico:(BOOL)publico
{
    Role *novoRole = [[Role alloc] init];
    
    Endereco *end = [[Endereco alloc] init];
    
    end._nome = endereco;
    
    // Acha as coordenadas e atualiza o endereço
    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder geocodeAddressString:endereco completionHandler:^(NSArray *placemarks, NSError *error)
     {
         for (CLPlacemark *placemark in placemarks)
         {
             end._coord = placemark.location.coordinate;
             end._inicializado = YES;
         }
         
         NSLog(@"Descobri as coordenadas do endereço %@!", end._nome);
         
         // Notifica os delegates
         for(id<ListaRolesDelegate> del in listaDeDelegates)
         {
             if([del respondsToSelector:@selector(listaRole:atualizouEnderecoDe:)])
             {
                 [del listaRole:self atualizouEnderecoDe:novoRole];
             }
         }
     }];
    
    
    novoRole.dono = dono;
    
    novoRole.endereco = end;
    novoRole.descricao = descricao;
    novoRole.data = data;
    novoRole.convidados = convidados;
    novoRole.publico = publico;
    novoRole._id = _idRoles++;
    
    [listaDeRoles addObject:novoRole];
    
    // Notifica os delegates
    for(id<ListaRolesDelegate> del in listaDeDelegates)
    {
        if([del respondsToSelector:@selector(listaRole:adicionouRole:)])
        {
            [del listaRole:self adicionouRole:novoRole];
        }
    }
    
    return novoRole._id;
}

- (bool)removerRole:(int)idRole
{
    Role *role = [self getRolePorId:idRole];
    
    if(role != nil)
    {
        [listaDeRoles removeObjectIdenticalTo:role];
        return true;
    }
    
    return false;
}

- (Role*)getRolePorId:(int)idRole
{
    for(Role *role in listaDeRoles)
    {
        if(role._id == idRole)
        {
            return [role clonar];
        }
    }
    
    return nil;
}

- (int)atualizarRole:(Role*)role
{
    Role *roleAtual = [self getRolePorId:role._id];
    
    if(roleAtual == nil)
    {
        return -1;
    }
    
    [roleAtual copiarCamposDe:role];
    
    return 0;
}

- (NSArray *)rolesDistando:(double)metros doLocal:(CLLocationCoordinate2D)origem
{
    NSMutableArray *roles = [[NSMutableArray alloc] init];
    
    for (Role *role in listaDeRoles)
    {
        CLLocation *localA = [[CLLocation alloc] initWithLatitude:origem.latitude longitude:origem.longitude];
        CLLocation *localB = [[CLLocation alloc] initWithLatitude:[role.endereco _coord].latitude longitude:[role.endereco _coord].longitude];
        CLLocationDistance distancia = [localA distanceFromLocation:localB];
        
        if (distancia <= metros)
            [roles addObject:role];
    }
    
    return roles;
}

- (NSArray*)todosOsRoles
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(Role *role in listaDeRoles)
    {
        [array addObject:[role clonar]];
    }
    
    return array;
}

// Gerenciamento de delegates
- (void)registrarDelegate:(id<ListaRolesDelegate>)delegate
{
    [listaDeDelegates addObject:delegate];
}

- (void)removerDelegate:(id<ListaRolesDelegate>)delegate
{
    [listaDeDelegates removeObjectIdenticalTo:delegate];
}

@end
