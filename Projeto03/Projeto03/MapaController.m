//
//  MapaController.m
//  Projeto03
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 10/03/14.
//  Copyright (c) 2014 ARTHUR HENRIQUE VIEIRA DE OLIVEIRA. All rights reserved.
//

#import "MapaController.h"
#import "ListaRoles.h"
#import "CadastrarRoleControllerViewController.h"

@interface MapaController ()

@end

@implementation MapaController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"verInformacoes"])
    {
        CadastrarRoleControllerViewController *controller = segue.destinationViewController;
        
        controller.veioDeMapa = YES;
        [controller exibirRole:self.roleParaMostrar];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Inicializando o mapa e o colocando na view
    [self setMapa:[[MKMapView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height)]];
    [[self view] addSubview:[self mapa]];
    
    // Mostrando a localização do usuário
    [[self mapa] setShowsUserLocation:true];
    // Colocando o delegate no mapa
    [[self mapa] setDelegate:self];
    
    // Inicializando o endereço
    [self setEndereco:[[UITextField alloc] initWithFrame:CGRectMake(0, 65, 320, 30)]];
    [[self endereco] setBorderStyle:UITextBorderStyleRoundedRect];
    [[self endereco] setDelegate:self];
    [[self view] addSubview:[self endereco]];
    
    self.adicionouRoles = NO;
    
    // Prepara a view dependendo do modo de manipulação de dados
    if(self.modoAtual == MODO_LOCALIZAR_ROLES)
    {
        // Adiciona essa classe como delegate para recebimento de eventos de mudanças de roles
        [[ListaRoles lista] registrarDelegate:self];
    }
    else if(self.modoAtual == MODO_SELECIONAR_LOCAL)
    {
        
        UILongPressGestureRecognizer *segurar = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(colocarPinch:)];
        [segurar setMinimumPressDuration:1.0];  //tempo que tem que ficar com o dedo na tela
        [[self mapa] addGestureRecognizer:segurar];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Remove o delegate
    [[ListaRoles lista] removerDelegate:self];
}

- (void)colocarPinch:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:[self mapa]];
    CLLocationCoordinate2D locCoord = [[self mapa] convertPoint:point toCoordinateFromView:[self mapa]];
    MKPointAnnotation *ponto = [[MKPointAnnotation alloc] init];
    
    [ponto setCoordinate:locCoord];
    
    [[self mapa] addAnnotation:ponto];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in [[self view] subviews])
    {
        [view resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self marcarPosicaoNoMapa];
    
    return true;
}

- (void)atualizarEventosProximos
{
    self.adicionouRoles = YES;
    
    // Remove os pins atuais
    [self.mapa removeAnnotations:self.mapa.annotations];
    
    // Pega os rolês próximos do usuário
    NSArray *roles = [[ListaRoles lista] rolesDistando:10000 doLocal:self.localizacaoAtual];
    
    for(Role *role in roles)
    {
        RoleAnnotation *ponto = [[RoleAnnotation alloc] initWithRole:role];
        
        ponto.coordinate = role.endereco._coord;
        [ponto setTitle:role.endereco._nome];
        
        [self.mapa addAnnotation:ponto];
    }
}

// Metodo para marcar um novo ponto no mapa
- (void)marcarPosicaoNoMapa
{
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo geocodeAddressString:[[self endereco] text] completionHandler:^(NSArray *placemarks, NSError *error)
    {
        for (CLPlacemark *placemark in placemarks)
        {
            // Criando a localização
            CLLocationCoordinate2D local;
            // Criando o ponto
            MKPointAnnotation *ponto = [[MKPointAnnotation alloc] init];
            
            // Criando a latitude e a longitude
            NSString *_latitude = [NSString stringWithFormat:@"%f", [[placemark location] coordinate].latitude];
            NSString *_longitude = [NSString stringWithFormat:@"%f", [[placemark location] coordinate].longitude];
            local.latitude = [_latitude doubleValue];
            local.longitude = [_longitude doubleValue];
            
            // Zoom no ponto
            MKCoordinateRegion regiao;
            regiao.center = local;
            ponto.coordinate = local;
            
            // Define o titulo da marcação
            [ponto setTitle:[[self endereco] text]];
            
            // Adiciona o zoom e a marcação
            [[self mapa] setRegion:regiao];
            [[self mapa] addAnnotation:ponto];
            
            // Limpa o texto
            [[self endereco] setText:@""];
        }
    }];
}

// Metodo para escolher qual o estilo de mapa visualizado
- (IBAction)mudarMapa:(id)sender
{
    if ([sender selectedSegmentIndex] == 0)
    {
        [[self mapa] setMapType:MKMapTypeStandard];
    }
    else if ([sender selectedSegmentIndex] == 2)
    {
        [[self mapa] setMapType:MKMapTypeSatellite];
    }
    else if ([sender selectedSegmentIndex] == 1)
    {
        [[self mapa] setMapType:MKMapTypeHybrid];
    }
}

// Métodos do delegate
- (void)listaRole:(ListaRoles *)lista atualizouEnderecoDe:(Role *)role
{
    [self atualizarEventosProximos];
}

// Centraliza o mapa no usuário
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Centraliza o mapa ao redor da posição atual do usuário
    [[self mapa] setCenterCoordinate:[[userLocation location] coordinate] animated:YES];
    
    // Dá um zoom na região atual do usuário
    self.mapa.region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    
    self.localizacaoAtual = userLocation.location.coordinate;
    
    [self atualizarEventosProximos];
}

// Tentando pegar o Pin
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Caso o tipo de anotação seja um MKUserLocation, nil é retornado para que o controle
    // padrão seja criado
    if([annotation class] == [MKUserLocation class])
    {
        return nil;
    }
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"String"];
    if(!annotationView)
    {
        annotationView = [[RoleAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"String"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.canShowCallout = NO;
    annotationView.centerOffset = CGPointMake(1000, 1000);
    annotationView.enabled = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if(![view.annotation isKindOfClass:[MKUserLocation class]])
    {
        /*
        CGSize  calloutSize = CGSizeMake(100.0, 80.0);
        UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(0, calloutSize.height, calloutSize.width, calloutSize.height)];
        calloutView.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(5.0, 5.0, calloutSize.width - 10.0, calloutSize.height - 10.0);
        [button setTitle:@"OK" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];
        [calloutView addSubview:button];
        [view.superview addSubview:calloutView];
        */
    }
    
    CGPoint point = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    CLLocationCoordinate2D locCoord = [[self mapa] convertPoint:point toCoordinateFromView:[self mapa]];
    
    point = [self.mapa convertCoordinate:[view.annotation coordinate] toPointToView:self.mapa];
    
    CLLocationCoordinate2D locacao = self.mapa.centerCoordinate;
    
    [self.mapa setCenterCoordinate:[view.annotation coordinate]];
    
    CLLocationCoordinate2D coordenada = [self.mapa convertPoint:CGPointMake(self.mapa.frame.size.width / 2, self.mapa.frame.size.height / 1.21f) toCoordinateFromView:self.mapa];
    
//    [self.mapa setCenterCoordinate:coordenada];
    
    [self.mapa setCenterCoordinate:locacao];
    
    [self.mapa setCenterCoordinate:coordenada animated:YES];
    
    // Dá um zoom na região atual do usuário
    //self.mapa.region = MKCoordinateRegionMake([view.annotation coordinate], MKCoordinateSpanMake(0.1, 0.1));
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    RoleAnnotation *annotation = view.annotation;
    
    
    
    self.roleParaMostrar = annotation.role;
    
    [self performSegueWithIdentifier:@"verInformacoes" sender:self];
}

@end


// RoleAnnotation
@implementation RoleAnnotation

- (id)initWithRole:(Role*)role
{
    self = [super init];
    if (self)
    {
        self.role = role;
    }
    return self;
}

@end


// RoleAnnotationView
@implementation RoleAnnotationView



- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        [self criarViewAnotacao];
    }
    
    return self;
}

- (void)criarViewAnotacao
{
    CGPoint tamanho = CGPointMake(250, 300);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-tamanho.x / 2, 40, tamanho.x, tamanho.y)];
    
    view.backgroundColor = [UIColor whiteColor];
    
    self.viewAnotacao = view;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        //Add your custom view to self...
        UIButton *botao = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [botao setFrame:CGRectMake(0, 0, 100, 100)];
        [botao setTitle:@"HEUHEUHEUHE" forState:UIControlStateNormal];
        
        CGPoint tamanho = CGPointMake(250, 300);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-tamanho.x / 2, 40, tamanho.x, tamanho.y)];
        
        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.viewAnotacao];
    }
    else
    {
        //Remove your custom view...
        [self.viewAnotacao removeFromSuperview];
    }
}

@end