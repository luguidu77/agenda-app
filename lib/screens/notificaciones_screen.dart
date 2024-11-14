import 'dart:convert';

import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/providers/buttom_nav_notificaciones_provider.dart';
import 'package:agendacitas/providers/tab_notificaciones_screen_provider.dart';
import 'package:agendacitas/widgets/botones/boton_leido_notif_administrador.dart';
import 'package:agendacitas/widgets/no_hay_coincidencias.dart';
import 'package:agendacitas/widgets/tarjeta_noticias.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/notificacion_model.dart';
import '../providers/providers.dart';
import '../widgets/botones/boton_ledido.dart';
import 'package:badges/badges.dart' as badges;

class PaginaNotificacionesScreen extends StatefulWidget {
  const PaginaNotificacionesScreen({super.key});

  @override
  State<PaginaNotificacionesScreen> createState() =>
      _PaginaNotificacionesScreenState();
}

class _PaginaNotificacionesScreenState extends State<PaginaNotificacionesScreen>
    with SingleTickerProviderStateMixin {
  late String _emailSesionUsuario;
  late TabController _tabController;

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  @override
  void initState() {
    inicializacion();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: context.read<TabNotifiacionesScreenProvider>().getTap,
    ); // Índice del tab inicial); // Inicializamos TabController con 3 pestañas

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TabNotifiacionesScreenProvider>().getTap;
    final contadorNotificaciones =
        context.watch<ButtomNavNotificacionesProvider>();
    int contNotifRecordatorios =
        contadorNotificaciones.contadorNotificacionesRecordatorio;
    int contNotifCitaWeb = contadorNotificaciones.contadorNotificacionesCitaweb;
    int contNotifAdministrador =
        contadorNotificaciones.contadorNotificacionesAdministrador;
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Text('NOTIFICACIONES'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'borrar_leidas') {
                _eliminaLedidas(
                    _emailSesionUsuario); // Ejecuta la acción "Borrar leídas"
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'borrar_leidas',
                child: Text('Borrar leídas'),
              ),
              // Otras opciones que desees agregar
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors
              .white, // Color del texto cuando la pestaña está seleccionada
          unselectedLabelColor: Colors
              .grey.shade600, // Color cuando la pestaña no está seleccionada
          indicator: BoxDecoration(
            color: Colors.blue, // Color del fondo del indicador
            borderRadius: BorderRadius.circular(
                20), // Bordes redondeados para el indicador
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // sombra hacia abajo
              ),
            ],
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.bold, // Mayor peso para el texto de las pestañas
          ),
          tabs: [
            Tab(
              icon: _icono(contNotifRecordatorios, Icons.notifications),
              text: "Recordatorios",
            ),
            Tab(
              icon: _icono(contNotifCitaWeb, Icons.cloud_done),
              text: "Cita Web",
            ),
            Tab(
              icon: _icono(contNotifAdministrador, Icons.newspaper),
              text: "Noticias",
            ),
          ],
          indicatorSize:
              TabBarIndicatorSize.tab, // Indicador del tamaño del tab completo
          indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 10.0, vertical: 5), // Ajuste del tamaño del indicador
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Asignamos el controlador al TabBarView
        children: [
          _buildNotificacionesCategoria('recordatorio'),
          _buildNotificacionesCategoria('citaweb'),
          _buildNotificacionesCategoria('administrador'),
        ],
      ),
    );
  }

  Center _icono(int contNotifRecordatorios, IconData icono) {
    return Center(
      child: badges.Badge(
        /* badgeContent */
        badgeStyle: badges.BadgeStyle(
          badgeColor: contNotifRecordatorios != 0
              ? Colors.red
              : Colors.transparent, // Color del fondo del número
        ),
        child: Icon(
          icono, // El ícono sobre el que se coloca el número
          size: 25.0,
        ),
      ),
    );
  }

  Widget _buildNotificacionesCategoria(String categoria) {
    return FutureBuilder(
      future: getTodasLasNotificaciones(_emailSesionUsuario),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                width: 30, height: 30, child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          final List<dynamic> notificaciones = snapshot.data
              .where((notificacion) => notificacion['categoria'] == categoria)
              .toList(); // Filtramos por categoría

          return Column(
            children: [
              (notificaciones.isEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 58.0),
                      child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child:
                              NoNotificationsContainer()), // Image.asset('assets/images/caja-vacia.png')),
                    )
                  : categoria == 'administrador'
                      ? TarjetaNoticias(
                          notificaciones: notificaciones,
                          emailSesionUsuario: _emailSesionUsuario,
                        )
                      : Expanded(
                          child: ListView.separated(
                            itemCount: notificaciones.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final notificacion = notificaciones[index];

                              final notificacionModelo = NotificacionModel(
                                id: notificacion['id'],
                                fechaNotificacion:
                                    notificacion['fechaNotificacion'],
                                iconoCategoria: notificacion['categoria'],
                                visto: notificacion['visto'],
                                data: notificacion['data'],
                                vistoPor: notificacion['vistoPor'],
                                texto: notificacion['texto'],
                                link: notificacion['link'],
                              );

                              String fechaNotificacion = _formateaFecha(
                                  notificacionModelo.fechaNotificacion);

                              String fechacita = '';
                              String horacita = '';
                              String nombreCliente = '';
                              String telefonoCliente = '';
                              String emailCliente = '';
                              String servicio = '';

                              if (notificacion['categoria'] == 'citaweb' ||
                                  notificacion['categoria'] == 'cita' ||
                                  notificacion['categoria'] == 'recordatorio') {
                                Map<String, dynamic> data =
                                    jsonDecode(notificacionModelo.data);
                                final (:nombre, :telefono, :email) =
                                    _obtieneCliente(data);
                                final (:fecha, :hora) = _obtieneCita(data);
                                final (:serv) = _obtieneServicio(data);
                                fechacita = fecha;
                                horacita = hora;
                                nombreCliente = nombre;
                                telefonoCliente = telefono;
                                emailCliente = email;
                                servicio = serv;
                              }

                              return dialogoDescripcionNotificacion(
                                context,
                                fechaNotificacion,
                                notificacion,
                                fechacita,
                                horacita,
                                nombreCliente,
                                telefonoCliente,
                                _emailSesionUsuario,
                                emailCliente,
                                servicio,
                                notificacionModelo.data,
                              );
                            },
                          ),
                        ),
            ],
          );
        } else {
          return const Center(
            child: Text('No hay notificaciones disponibles'),
          );
        }
      },
    );
  }

  GestureDetector dialogoDescripcionNotificacion(
      BuildContext context,
      String fechaNotificacion,
      notificacion,
      String fechacita,
      String horacita,
      String nombreCliente,
      String telefonoCliente,
      String emailSesionUsuario,
      String emailCliente,
      String servicio,
      data) {
    return GestureDetector(
      onTap: () async {
        // setState(() {});
        // Cambiar estado en Firebase

        print(emailSesionUsuario);
        print(notificacion['id']);
        // final categoria = _obtieneTextoCategoria(notificacion['categoria'], 12);
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fechaNotificacion,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _obtieneIcono(notificacion['categoria']),
                                      const SizedBox(width: 8),
                                      _obtieneTextoCategoria(
                                          notificacion['categoria'], 16),
                                    ],
                                  ),
                                ],
                              ),
                              notificacion['categoria'] == 'administrador'
                                  ? Container()
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.redAccent,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        _eliminaNotificacion(
                                            _emailSesionUsuario,
                                            notificacion['id']);
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    switch (notificacion['categoria']) {
                      'citaweb' ||
                      'cita' ||
                      'recordatorio' =>
                        _tarjetaDescripcionCitas(
                            fechacita,
                            horacita,
                            nombreCliente,
                            telefonoCliente,
                            emailCliente,
                            servicio),
                      _ => Container()
                    }

                    /*  MenuConfigCliente(
                                              cliente: listaClientes[index]), */

                    //_opciones(context, cliente)
                  ],
                ),
              ),
            );
          },
        ).then((value) async {
          if (notificacion['categoria'] == 'administrador') {
            if (!notificacion['vistoPor'].contains(emailSesionUsuario)) {
              await FirebaseProvider().cambiarEstadoVistoNotifAdministrador(
                  emailSesionUsuario, notificacion['id']);
              await contadorNotificacionesCitasNoLeidas(
                  context, _emailSesionUsuario);
            }
          } else {
            if (!notificacion['visto']) {
              await FirebaseProvider().cambiarEstadoVisto(
                  emailSesionUsuario, notificacion['id'], false);
              await contadorNotificacionesCitasNoLeidas(
                  context, _emailSesionUsuario);
            }
          }

          //setState(() {});
        });
      },
      child: _tarjetasNotificaciones(_emailSesionUsuario, fechaNotificacion,
          notificacion, fechacita, horacita, nombreCliente, telefonoCliente),
    );
  }

  // NOTIFICACION DE CITAS Y RECORDATORIOS ////////////////////////////////////
  Padding _tarjetaDescripcionCitas(
      String fechacita,
      String horacita,
      String nombreCliente,
      String telefonoCliente,
      String emailCliente,
      String servicio) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4, // Sombra para dar efecto de profundidad
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes redondeados
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today,
                    color: Colors.blue), // Icono para la fecha
                title: const Text(
                  'Fecha de la Cita',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  fechacita,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time,
                    color: Colors.green), // Icono para la hora
                title: const Text(
                  'Hora de la Cita',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  horacita,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person,
                    color: Colors.orange), // Icono para el cliente
                title: const Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  nombreCliente,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone,
                    color: Colors.purple), // Icono para el teléfono
                title: const Text(
                  'Teléfono',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  telefonoCliente,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email,
                    color: Colors.red), // Icono para el email
                title: const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  emailCliente,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.work,
                    color: Colors.teal), // Icono para el servicio
                title: const Text(
                  'Servicio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  servicio,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String categoriaNotificacion = '';
  // *** tarjetas de las notificaciones ***************************************
  Widget _tarjetasNotificaciones(
      emailSesionUsuario,
      String fechaNotificacion,
      Map<String, dynamic> notificacion,
      String fecha,
      String hora,
      String nombre,
      String telefono) {
    //** diferenciar segun CATEGORIA de la notificacion********************************** */
    // citaweb, administrador

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () async {}, // Aquí puedes agregar la acción deseada
          child: Text(fechaNotificacion),
        ),
        ListTile(
            // Contenido de la tarjeta de notificación
            leading: Column(
              children: [
                _obtieneIcono(notificacion['categoria']),
                _obtieneTextoCategoria(notificacion['categoria'], 8)
              ],
            ),
            title: _obtieneTextoTitulo(
                notificacion['categoria'], notificacion['data'], 12),
            // subtitulo si se trata de una cita para agregar fecha cita y telefono cliente
            subtitle: switch (notificacion['categoria']) {
              'cita' || 'citaweb' || 'recordatorio' => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$fecha  $hora"),
                    Text(nombre),
                  ],
                ),
              _ => const Text(''),
            },
            trailing: switch (notificacion['categoria']) {
              'administrador' => BotoLeidoNotifAdministrador(
                  notificacion: notificacion,
                  emailSesionUsuario: emailSesionUsuario),
              _ => BotonLedido(
                  notificacion: notificacion,
                  emailSesionUsuario: emailSesionUsuario),
            })
      ],
    );
  }

  // ***************************************************************************

  String _formateaFecha(Timestamp fechaNotificacion) {
    Timestamp timestamp = fechaNotificacion;

    // Convertir el Timestamp a DateTime
    DateTime dateTime = timestamp.toDate();

    // Formatear el DateTime según el formato deseado
    String fechaFormateada = DateFormat('dd/MM/yy HH:mm').format(dateTime);
    print("Fecha formateada: $fechaFormateada");
    return fechaFormateada;
  }

  _eliminaLedidas(emailSesionUsuario) async {
    await eliminaLeidas(emailSesionUsuario);
    setState(() {});
  }

  _eliminaNotificacion(emailSesionUsuario, id) async {
    await eliminaNotificacion(emailSesionUsuario, id);
    contadorNotificacionesCitasNoLeidas(context, emailSesionUsuario);
    Navigator.pop(context);
    setState(() {});
  }
}

Icon _obtieneIcono(String categoria) {
  return switch (categoria) {
    'recordatorio' => const Icon(Icons.notification_important),
    'cita' => const Icon(Icons.offline_share_outlined),
    'citaweb' => const Icon(Icons.cloud_done),
    'administrador' => const Icon(Icons.admin_panel_settings_sharp),
    _ => const Icon(Icons.data_array_rounded),
  };
}

Text _obtieneTextoCategoria(String categoria, double size) {
  return switch (categoria) {
    'recordatorio' => Text('RECORDATORIO', style: TextStyle(fontSize: size)),
    'cita' => Text('CITA', style: TextStyle(fontSize: size)),
    'citaweb' => Text('CITA', style: TextStyle(fontSize: size)),
    'administrador' => Text('ADMIN', style: TextStyle(fontSize: size)),
    _ => Text('N/A', style: TextStyle(fontSize: size)),
  };
}

Text _obtieneTextoTitulo(String categoria, String data, double size) {
  String servicios = '';
  if (categoria != 'administrador') {
    // Decodificar el texto JSON en un mapa
    Map<String, dynamic> parsedJson = json.decode(data);
    // Acceder al campo 'servicio'
    servicios = parsedJson['servicio'];
  }
  String truncarTexto(String texto, int maxCaracteres) {
    if (texto.length > maxCaracteres) {
      return '${texto.substring(0, maxCaracteres)}...';
    } else {
      return texto;
    }
  }

  return switch (categoria) {
    'recordatorio' => Text('RECORDATORIO', style: TextStyle(fontSize: size)),
    'cita' =>
      Text(truncarTexto(servicios, 25), style: TextStyle(fontSize: size)),
    'citaweb' =>
      Text(truncarTexto(servicios, 25), style: TextStyle(fontSize: size)),
    'administrador' =>
      Text(truncarTexto(data, 25), style: TextStyle(fontSize: size)),
    _ => Text('N/A', style: TextStyle(fontSize: size)),
  };
}

({String fecha, String hora}) _obtieneCita(data) {
  String fechaCita = data['fechaCita']['fechaFormateada'];
  String horaCita = data['fechaCita']['horaFormateada'];

  return (fecha: fechaCita, hora: horaCita);
}

({String nombre, String telefono, String email}) _obtieneCliente(data) {
  String nombreCliente = data['cliente']['nombre'];
  String telefonoCliente = data['cliente']['telefono'];
  String emailCliente = data['cliente']['email'];

  return (
    nombre: nombreCliente,
    telefono: telefonoCliente,
    email: emailCliente
  );
}

({String serv}) _obtieneServicio(data) {
  String servicio = data['servicio'];
  return (serv: servicio,);
}
