import 'package:agendacitas/config/mantenimientos/mantenimientos.dart';
import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../config/config.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'creacion_citas/provider/creacion_cita_provider.dart';

class CalendarioCitasScreen extends StatefulWidget {
  const CalendarioCitasScreen({Key? key}) : super(key: key);

  @override
  State<CalendarioCitasScreen> createState() => _CalendarioCitasScreenState();
}

class _CalendarioCitasScreenState extends State<CalendarioCitasScreen>
    with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late CreacionCitaProvider contextoCreacionCita;
  bool _iniciadaSesionUsuario =
      false; // ?  VARIABLE PARA VERIFICAR SI HAY USUARIO CON INCIO DE SESION
  Color colorBotonFlecha = Colors.blueGrey;
  String _emailSesionUsuario = '';
  String _estadoPagadaApp = '';

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  double preciototal = 0;
  bool ocultarPrecios = true;
  Image? reloj;

  bool hayservicios = true;
  bool enviosugerencia = false;

  DateFormat formatMes = DateFormat.MMMM('es_ES');
  DateFormat formatSemana = DateFormat.EEEE('es_ES');
  DateFormat formatDia = DateFormat.d('es_ES');
  DateFormat formatAno = DateFormat.y('es_ES');

  //DateFormat('EEE dd-MM', 'es_ES');
  DateTime fechaElegida = DateTime.now();
  String fechaTextoAno = '';
  String fechaTextoMes = '';
  String fechaTextoSemana = '';
  String fechaTextoDia = '';
  // tarjeta de novedades
  String novedad = '';
  bool novedadActivo = false;
  Color colorNovedad = Colors.black;
  IconData iconoNovedad = Icons.info;

  String noImagen = './assets/icon/icon.png';

  bool visibleCalendario = false;

  // DIAS DISPONIBILIDAD SEMANAL
  Set<int> diasNoDisponibles =
      {}; //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7

  String calen = '';

  String filter = 'none';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    mRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  @override
  void initState() {
    fechaTextoAno = formatAno.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoMes = formatMes.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoSemana =
        formatSemana.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoDia = formatDia.format(DateTime.parse(fechaElegida.toString()));

    inicializacion();

    novedades();

    // Publicidad.publicidad(_iniciadaSesionUsuario);
    super.initState();
  }

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    _estadoPagadaApp = estadoPagoProvider.estadoPagoApp;

    // ESCUCHA DE NOTIFICACIONES DE FIREBASE MESSAGING
    await NotificacionesFirebaseMessaging().setupFlutterNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;
    //* HERRAMIENTA PARA AGREGAR Y MODIFICAR DATOS FIREBASE PARA CORRECION DE ERRORES
    // FirebaseProvider().modificaEstructura();

    // LLEE MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    // al cancelar, limpiamos el contexto de los servicios
    contextoCreacionCita.getServiciosElegidos.clear();

    // LLEE CONTEXTO ESTADO DE PAGO
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();

    _estadoPagadaApp = estadoPagoProvider.estadoPagoApp;

    if (_estadoPagadaApp == 'PRUEBA_CADUCADA' && mounted) {
      Future.delayed(const Duration(seconds: 10), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FinalizacionPrueba(
                    usuarioAPP: _emailSesionUsuario,
                  )),
        );
      });
    }
    // DISPONIBILIDAD SEMANAL PROVIDER
    final provider = context.watch<DispoSemanalProvider>();
    diasNoDisponibles = provider.diasNoDisponibles;
    debugPrint(
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ${diasNoDisponibles.toString()}');

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
        child: Container(
          color: Colors.white.withOpacity(0.95), // Tono blanquecino
          child: Column(
            children: [
              // TARJETA DE NOVEDADES O MENSAJES A LOS USUARIOS
              /*   Expanded(
                flex: 3,
                child: tarjetaNodades(),
              ), */
              // ---------------agrego tarjeta de alerta Señala indisponibilidad cuando se ha pulsado del boton del boton_speed_dial.dart No Disponibles -----------------
              Visibility(
                visible: leerEstadoBotonIndisponibilidad,
                child: Card(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Señala horario no disponible',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                              child: const Text('descartar'),
                              onPressed: () {
                                setState(() {});
                                Provider.of<BotonAgregarIndisponibilidadProvider>(
                                        context,
                                        listen: false)
                                    .setBotonPulsadoIndisponibilidad(false);
                              })
                        ],
                      ),
                    )),
              ),
              //****  activacion de mantenimientos ********* */
              Visibility(
                visible: true,
                child: Mantenimientos(
                  emailSesionUsuario: _emailSesionUsuario,
                ),
              ),

              Expanded(
                flex: 1,
                child: Visibility(
                    visible: !visibleCalendario,
                    child: selecionFechas(calendarioProvider)),
              ),
              Visibility(
                  visible: visibleCalendario,
                  child: Expanded(flex: 10, child: calendario())),

              Visibility(
                  visible: !visibleCalendario,
                  child: _iniciadaSesionUsuario
                      ? const SizedBox(
                          height: 10,
                          // child: _fotoPerfil(),
                        )
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
                        )),

              Visibility(
                visible: !visibleCalendario,
                child: Expanded(
                  flex: 8,
                  child: diasNoDisponibles.contains(fechaElegida.weekday)
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            const Text('DIA NO DISPONIBLE PARA CITAR '),
                            const SizedBox(
                              height: 50,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DisponibilidadSemanalScreen(),
                                  )),
                              child: Image.asset(
                                ('./assets/icon/beach.png'),
                                width: MediaQuery.of(context).size.width - 200,
                              ),
                            ),
                          ],
                        )
                      : ListaCitas(
                          emailusuario: _emailSesionUsuario,
                          fechaElegida: fechaElegida,
                          iniciadaSesionUsuario: _iniciadaSesionUsuario,
                          filter: filter, // envia 'TODAS' O 'PENDIENTES'
                        ),

                  /* BackdropFilterCitas(
                            backLayer: Container()
                            /*  EnviosRecordatorios( 
                              usuarioAPP: _emailSesionUsuario,
                              fechaElegida: fechaElegida
          
                             
                            ) */
                            ,
                            frontLayer: // ListaCitasNuevo(),
          
                                ListaCitas(
                              emailusuario: _emailSesionUsuario,
                              fechaElegida: fechaElegida,
                              iniciadaSesionUsuario: _iniciadaSesionUsuario,
                              filter: filter, // envia 'TODAS' O 'PENDIENTES'
                            ),
                            backTitle: const Text(
                              'RECORDATOIOS',
                              style: TextStyle(fontSize: 14),
                            ),
                            frontTitle: Text(
                              'Citas para ${_emailSesionUsuario.toString().split('@')[0]}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            usuarioAPP: _emailSesionUsuario,
                          )  */ //_vercitas(usuarioAPP)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _fotoPerfil() {
    try {
      return FutureBuilder(
          future: FirebaseProvider().cargarPerfilFB(
              _emailSesionUsuario), //todo: cargar todos los empleados no solo el perfil
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

  calendario() {
    return const Calendario();
  }

  tarjetaNodades() {
    return Visibility(
      visible: novedadActivo,
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
    );
  }

  selecionFechas(calendarioProvider) {
    // DAR FORMATO A LA FECHA ELEGIDA (sabado 18 de febrero 2023)
    fechaTextoAno = formatAno.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoMes = formatMes.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoSemana =
        formatSemana.format(DateTime.parse(fechaElegida.toString()));
    fechaTextoDia = formatDia.format(DateTime.parse(fechaElegida.toString()));

    return calendarioProvider.visibleCalendario
        // FECHA ELEGIDA CON SELECTORES AUMENTO/DECREMENTO DIAS(VISIBLE CUANDO NO SE VE EL CALENDARIO)
        ? Container()
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
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
            ),
          );
  }

  _tarjetadelafechaelegida() {
    // Convierte ambas fechas a la misma zona horaria (UTC) para comparar solo las fechas
    DateTime fechaEspecificaSoloFecha =
        DateTime.utc(fechaElegida.year, fechaElegida.month, fechaElegida.day);
    DateTime fechaActualSoloFecha = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return SizedBox(
      // width: MediaQuery.of(context).size.width - 120,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fecha(),
            const SizedBox(
              width: 5,
            ),
            fechaActualSoloFecha.isAtSameMomentAs(fechaEspecificaSoloFecha)
                ? const Icon(Icons.today)
                : const Icon(Icons.calendar_month),
          ],
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
          fechaTextoAno =
              formatAno.format(fechaElegida.add(const Duration(days: 1)));
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
      iconSize: 50,
      color: colorBotonFlecha,
    );
  }

  _botonAnteriorDia(calendarioProvider) {
    return IconButton(
      onPressed: () => {
        setState(() {
          calendarioProvider.setFechaSeleccionada =
              fechaElegida.subtract(const Duration(days: 1));
          fechaTextoAno =
              formatAno.format(fechaElegida.subtract(const Duration(days: 1)));
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
      iconSize: 50,
      color: colorBotonFlecha,
    );
  }

  listaEmpleados(data) {
    String foto = data.foto == '' ? no_hay_foto : data!.foto.toString();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1, // TODO:  Nº DE EMPLEADOS
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                                placeholder:
                                    './assets/icon/galeria-de-fotos.gif',
                                image: foto,
                                fit: BoxFit.cover,
                                width: 100),
                          )),
                      denominacionNegocio(_emailSesionUsuario,
                          color: Colors.black, size: 12.0),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  _fecha() {
    return Text(
      '$fechaTextoSemana $fechaTextoDia $fechaTextoMes $fechaTextoAno',
      style: const TextStyle(
          fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
