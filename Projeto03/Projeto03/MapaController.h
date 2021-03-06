//
//  MapaController.h
//  Projeto03
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 10/03/14.
//  Copyright (c) 2014 ARTHUR HENRIQUE VIEIRA DE OLIVEIRA. All rights reserved.
//

#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "MenuPrincipalController.h"
#import "ListaRolesDelegate.h"
#import "Role.h"

#define MODO_LOCALIZAR_ROLES 0
#define MODO_SELECIONAR_LOCAL 1

@class MapaController;

@interface AnotacaoDeMapa : MKPointAnnotation

@property NSString *endereco;

@end

// RoleAnnotation
@interface RoleAnnotation : AnotacaoDeMapa

@property Role *role;

- (id)initWithRole:(Role*)role;

@end

// PontoDeinterece
@interface PontoDeInteresse : AnotacaoDeMapa

@end

// RoleAnnotationView
@interface RoleAnnotationView : MKPinAnnotationView

@property (weak) MapaController *mapa;

@end

// MapaController
@interface MapaController : UIViewController <MKMapViewDelegate, UITextFieldDelegate, ListaRolesDelegate>
{
    CGPoint coordinates;
}

@property (strong, nonatomic) MKMapView *mapa;
//@property (strong, nonatomic) UITextField *endereco;
@property (weak, nonatomic) IBOutlet UITextField *endereco;
@property (strong, nonatomic) MKMapItem *inicio;
@property (strong, nonatomic) MKMapItem *destino;
@property (strong, nonatomic) MKPolylineRenderer *renderer;
@property (weak, nonatomic) IBOutlet UIView *mapaView;
@property (strong, nonatomic) NSMutableArray *matchItens;

@property RoleAnnotation *ultimoPin;

@property NSInteger corPin;
@property NSString *descricaoDoRole;

@property BOOL achou;

@property UIView *viewAnotacao;

@property bool adicionouRoles;
@property CLLocationCoordinate2D localizacaoAtual;
@property int modoAtual;

@property (weak) Role *roleParaMostrar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *tiposMapa;

- (IBAction)mudarMapa:(id)sender;

@end