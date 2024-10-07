import 'package:flutter/material.dart';

// DIAS QUE ESTARA LA APP EN TIEMPO DE PRUEBA GRATUITA
const perido_de_prueba = Duration(days: 30);

// NO HAY FOTO ( ESTA GUARDADA EN STORAGE DE FIREBASE )

const String no_hay_foto =
    'https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/agendadecitas%2FNOHAYFOTO%2Fnofoto.jpg?alt=media&token=f8d771d4-461e-4bdf-8a31-85d7a2f0238f&_gl=1*3nxe18*_ga*NzYzMTA2NzgwLjE2NjIxNDM3NTA.*_ga_CW55HF8NVT*MTY4NTYzNDkyOS41Ni4xLjE2ODU2MzYwODYuMC4wLjA.';

BuildContext? globalContext;

// REGISTRAR EL RouterObserver como navegacion
//https://www.youtube.com/watch?v=jQVY4ZoieVE
final RouteObserver<ModalRoute<void>> mRouteObserver =
    RouteObserver<ModalRoute<void>>();


// configurar las transiciones de paginas
