import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/perfil_model.dart';
import '../providers/calendario_provider.dart';
import '../../widgets/calendario/calendario.dart';
import '../../widgets/filtros/backdrop_citas.dart';
import '../../widgets/filtros/items_filter_citas.dart';
import '../widgets/lista_de_citas.dart';
import '../providers/Firebase/firebase_provider.dart';
import '../providers/comprueba_pago.dart';
import '../providers/dispo_semanal_provider.dart';
import '../providers/pago_provider.dart';
import '../utils/disponibilidadSemanal.dart';
import '../widgets/botones/boton_speed_dial.dart';

import 'config/config.dart';

class CalendarioCitasScreen extends StatefulWidget {
  const CalendarioCitasScreen({Key? key}) : super(key: key);

  @override
  State<CalendarioCitasScreen> createState() => _CalendarioCitasScreenState();
}

class _CalendarioCitasScreenState extends State<CalendarioCitasScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool iniciadaSesionUsuario =
      false; // ?  VARIABLE PARA VERIFICAR SI HAY USUARIO CON INCIO DE SESION
  Color colorBotonFlecha = Colors.blueGrey;
  String usuarioAPP = '';

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  int preciototal = 0;
  bool ocultarPrecios = true;
  Image? reloj;

  bool hayservicios = true;
  bool enviosugerencia = false;

  DateFormat formatMes = DateFormat.MMMM('es_ES');
  DateFormat formatSemana = DateFormat.EEEE('es_ES');
  DateFormat formatDia = DateFormat.d('es_ES');

  //DateFormat('EEE dd-MM', 'es_ES');
  DateTime fechaElegida = DateTime.now();
  String fechaTextoMes = '';
  String fechaTextoSemana = '';
  String fechaTextoDia = '';
  // tarjeta de novedades
  String novedad = '';
  bool novedadActivo = false;
  Color colorNovedad = Colors.black;
  IconData iconoNovedad = Icons.info;

  String noImagen = './assets/icon/icon.png';

  //contenedor de calendario

  bool visibleCalendario = false;

  //contenedor seleccion de fechas
  int flexContenedorCitas = 9;

  // event

  var diasDisp;
  List diasNoDisponibles =
      []; //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
  String calen = '';

  String filter = 'none';

  @override
  void initState() {
    //fechaTexto = formatDay.format(fechaElegida);
    fechaTextoMes = formatMes.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoSemana =
        formatSemana.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoDia = formatDia.format(DateTime.parse(fechaElegida.toString()));

    inicializacion();

    novedades();

    super.initState();
  }

  inicializacion() async {
    //?comprueba pago en dispositivo
    final pago = await CompruebaPago().compruebaPago();
    debugPrint('datos gardados en tabla Pago (calendarioScreen.dart) $pago');

    //? guardo en variables los datos de pago-> pago y email
    String emailusuario = pago['email'];
    usuarioAPP =
        emailusuario; // usuarioAPP se usa en eliminar cita de Firebase //todo Quitar cuando sea online todas las gestiones

    //? SI LA APP NO HA SIDO COMPRADA => VERIFICA LA FECHA DE REGISTRO DEL USUARIO PARA SABER SI HA CADUCADO EL PERIODO DE PRUEBA
    if (!pago['pago']) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          DateTime now = DateTime.now();
          DateTime fecha =
              DateTime.parse(user.metadata.creationTime.toString());
          debugPrint(
              '################   LOS DIAS DE PRUEBA LOS CONFIGURO AQUI EN .configuracions.dart ###########');
          Duration diasDePrueba = perido_de_prueba;

          if (now.subtract(diasDePrueba).isAfter(fecha)) {
            debugPrint('fecha cumplida prueba caducada');
            //
            Navigator.pushReplacementNamed(context, 'finalizacionPruebaScreen',
                arguments: {
                  'usuarioAPP': user.email.toString(),
                });
          } else {
            debugPrint('en tiempo prueba gratuita');
          }
        }
      });
    }

    //? compruebo si hay email para saber si hay sesion iniciada
    iniciadaSesionUsuario = emailusuario != '' ? true : false;
    //todo: hasta aqui se ejecuta por duplicado en el main traer provider

    //? seteo el Provider para tener pago e emailusuario en toda la aplicacion
    final providerPagoUsuarioAPP = await pagoProvider();
    providerPagoUsuarioAPP.pagado = pago;

    //?  si hay usuario disponible, seteo en provider la disponibilidad semanal para el servicio
    iniciadaSesionUsuario
        // ignore: use_build_context_synchronously
        ? diasNoDisponibles = await DisponibilidadSemanal.disponibilidadSemanal(
            context,
            emailusuario) // diasNoDisponibles desde la carpeta utils    //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
        : debugPrint('NO HAY USURIO LOGEADO!!!!');
    if (mounted) {
      setState(() => {});
    }

    //?I ES APP DE PAGO SINCRONIZA CON FIREBASE ----------------------------------------------------------
    //if (pagado) SincronizarFirebase().sincronizaSubeFB(emailusuario);
  }

  @override
  Widget build(BuildContext context) {
    var calendarioProvider =
        Provider.of<CalendarioProvider>(context, listen: true);
    fechaElegida = calendarioProvider.fechaSeleccionada;
    visibleCalendario = calendarioProvider.visibleCalendario;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: const BotonSpeedDial(),
      key: _scaffoldKey,
      //drawer: const MenuDrawer(),
      onDrawerChanged: (isOpened) {
        //listener left drawer
        debugPrint('abierto menu drawer desde calendarioScreen.dart');

        if (!isOpened) {
          debugPrint('cerrado');
          //  initState();
        }
      },

      body: SafeArea(
        child: Column(
          children: [
            // TARJETA DE NOVEDADES O MENSAJES A LOS USUARIOS
            tarjetaNodades(),
            selecionFechas(calendarioProvider),

            Visibility(visible: visibleCalendario, child: calendario()),
            Expanded(
                flex: 1,
                child: Visibility(
                    visible: !visibleCalendario,
                    child: iniciadaSesionUsuario
                        ? _fotoPerfil()
                        : Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.asset(
                                      './assets/icon/icon.png',
                                    ),
                                  )),
                              const Text(
                                'agendadecitas',
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ))),
            Visibility(
              visible: !visibleCalendario,
              child: Expanded(
                  flex: flexContenedorCitas,
                  child: diasNoDisponibles.contains(fechaElegida.weekday)
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            const Text('Día de la semana no disponible'),
                            const SizedBox(
                              height: 50,
                            ),
                            Image.asset(
                              './assets/images/noDisponible.png',
                              width: MediaQuery.of(context).size.width - 200,
                            ),
                          ],
                        )
                      : BackdropFilterCitas(
                          backLayer: ItemsFiltersCitas(
                            onFilterChange: (f) {
                              setState(() {
                                filter = f;
                              });
                            },
                          ),
                          frontLayer: ListaCitas(
                            emailusuario: usuarioAPP,
                            fechaElegida: fechaElegida,
                            iniciadaSesionUsuario: iniciadaSesionUsuario,
                            filter: filter, // envia 'TODAS' O 'PENDIENTES'
                          ),
                          backTitle: const Text(
                            'FILTRAR',
                            style: TextStyle(fontSize: 14),
                          ),
                          frontTitle: Text(
                            iniciadaSesionUsuario
                                ? 'Citas para ${usuarioAPP.split('@')[0]}'
                                : 'Citas para agendadecitas', // todo: foto o nombre de empleado
                            style: const TextStyle(fontSize: 14),
                          ),
                          usuarioAPP: usuarioAPP,
                        ) //_vercitas(usuarioAPP)),
                  ),
            )
          ],
        ),
      ),
    );
  }

  _fotoPerfil() {
    try {
      return FutureBuilder(
          future: FirebaseProvider().cargarPerfilFB(
              usuarioAPP), //todo: cargar todos los empleados no solo el perfil
          builder: (BuildContext context, AsyncSnapshot<PerfilModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            width: 35,
                            height: 35,
                            borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            width: 35,
                            height: 35,
                            borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            width: 35,
                            height: 35,
                            borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // foto y nombre usuario empleados
                return listaEmpleados(snapshot.data);
              }
            }

            return const CircleAvatar();
          });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  dispoProvider() {
    return Provider.of<DispoSemanalProvider>(context, listen: false);
  }

  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  toColor(String color) {
    // color definido en firebase Novedad
    // tabla de colores hexadecimal https://htmlcolorcodes.com/es/tabla-de-colores/
    var hexColor = color.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return hexColor;
  }

  novedades() async {
//? COMPRUEBA NOVEDADES EN FIREBASE

    if (kIsWeb) {
      // La aplicación se está ejecutando en un navegador web (escritorio)
    } else {
      // La aplicación se está ejecutando en un dispositivo móvil

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      final db = FirebaseFirestore.instance;

// creo una referencia al documento que contiene la version
      final docRefVersion =
          db.collection("novedades").doc("7JAa1HMGRDSk0z9WKjk3");

      var data = await docRefVersion.get().then(
            (doc) => doc.data(),
          );

      bool activo = data!['activo'];
      novedad = data['novedad'];
      String color = data['color'];
      colorNovedad = toColor(color);
      //  String iconoAux = data['icono'];
      // iconoNovedad =;

      if (activo) {
        novedadActivo = true;

        setState(() {});
      }
    }
  }

  calendario() {
    return const Calendario();
  }

  tarjetaNodades() {
    return Visibility(
      visible: novedadActivo,
      child: Expanded(
        flex: 3,
        child: Column(
          children: [
            Card(
                clipBehavior: Clip.antiAlias,
                color: colorNovedad,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          novedad.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  novedadActivo = false;
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.check_outlined,
                                  color: Colors.white,
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  selecionFechas(calendarioProvider) {
    // DAR FORMATO A LA FECHA ELEGIDA (sabado 18 de febrero)
    fechaTextoMes = formatMes.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoSemana =
        formatSemana.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoDia = formatDia.format(DateTime.parse(fechaElegida.toString()));

    return calendarioProvider.visibleCalendario
        // FECHA ELEGIDA CON SELECTORES AUMENTO/DECREMENTO DIAS(VISIBLE CUANDO NO SE VE EL CALENDARIO)
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BOTON DEL DIA ANTERIOR
              _botonAnteriorDia(calendarioProvider),
              // TARJETA PARA VER LA FECHA
              GestureDetector(
                onTap: () => setState(() {
                  calendarioProvider.setVisibleCalendario = true;
                }),
                child: _tarjetadelafechaelegida(),
              ),
              // BOTON SIGUIENTE DIA

              _botonSiguienteDia(calendarioProvider),
            ],
          );
  }

  _tarjetadelafechaelegida() {
    return Card(
      color: (fechaElegida.day == DateTime.now().day)
          ? const Color.fromARGB(255, 201, 223, 245)
          : fechaElegida.weekday == DateTime.sunday ||
                  fechaElegida.weekday == DateTime.saturday
              ? const Color.fromARGB(255, 241, 184, 180)
              : Colors.white,
      elevation: 8.0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                fechaTextoSemana,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                fechaTextoDia,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                'de',
                style: TextStyle(
                    color: Color.fromARGB(176, 96, 125, 139),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Text(
                fechaTextoMes,
                style: const TextStyle(
                    color: Color.fromARGB(176, 96, 125, 139),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Icon(Icons.calendar_month_sharp)
            ],
          ),
        ),
      ),
    );
  }

  _botonSiguienteDia(calendarioProvider) {
    return IconButton(
      onPressed: () => {
        setState(() {
          calendarioProvider.setFechaSeleccionada =
              fechaElegida.add(const Duration(days: 1));
          fechaTextoMes =
              formatMes.format(fechaElegida.add(const Duration(days: 1)));
          fechaTextoSemana =
              formatSemana.format(fechaElegida.add(const Duration(days: 1)));
          fechaTextoDia =
              formatDia.format(fechaElegida.add(const Duration(days: 1)));
          fechaElegida = fechaElegida.add(const Duration(days: 1));
        }),
      },
      icon: const Icon(Icons.arrow_right_outlined),
      iconSize: 55,
      color: colorBotonFlecha,
    );
  }

  _botonAnteriorDia(calendarioProvider) {
    return IconButton(
      onPressed: () => {
        setState(() {
          calendarioProvider.setFechaSeleccionada =
              fechaElegida.subtract(const Duration(days: 1));
          fechaTextoMes =
              formatMes.format(fechaElegida.subtract(const Duration(days: 1)));
          fechaTextoSemana = formatSemana
              .format(fechaElegida.subtract(const Duration(days: 1)));
          fechaTextoDia =
              formatDia.format(fechaElegida.subtract(const Duration(days: 1)));
          fechaElegida = fechaElegida.subtract(const Duration(days: 1));
        }),
      },
      icon: const Icon(Icons.arrow_left_outlined),
      iconSize: 55,
      color: colorBotonFlecha,
    );
  }

  listaEmpleados(data) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Center(
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1,
            itemBuilder: (BuildContext context, index) {
              return Column(
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                            placeholder: './assets/icon/galeria-de-fotos.gif',
                            image:
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Imagen_no_disponible.svg/300px-Imagen_no_disponible.svg.png',
                            // data!.foto.toString(),
                            fit: BoxFit.cover,
                            width: 100),
                      )),
                  Text(
                    usuarioAPP.split('@')[0],
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              );
            }),
      ),
    );
  }
}
