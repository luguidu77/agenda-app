import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/empleados_screen.dart';
import 'package:agendacitas/screens/servicios_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class MenuAplicacion extends StatefulWidget {
  const MenuAplicacion({Key? key}) : super(key: key);

  @override
  State<MenuAplicacion> createState() => _MenuAplicacionState();
}

class _MenuAplicacionState extends State<MenuAplicacion> {
  String _emailSesionUsuario = '';
  String _emailAdministrador = '';
  final String _estadopago = '';
  TextStyle estilo = const TextStyle(color: Colors.black);
  final bool _iniciadaSesionUsuario = false;
  String versionApp = '';
  bool versionPlayS = false;
  String comentarioVersion = '';
  bool enviosugerencia = false;
  bool necesitaActualizar = false;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    emailUsuario();
    imagenUrl();
    version();
  }

  version() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionApp = packageInfo.version;
    double verApp = double.parse(versionApp);

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    final db = FirebaseFirestore.instance;
    final docRefVersion =
        db.collection("versionPlayStore").doc("Izdf1IB8WIfq3s8GbYuK");
    var data = await docRefVersion.get().then((doc) => doc.data());
    versionPlayS = data!['version'];
    comentarioVersion = data['comentario'];
    if (versionPlayS) {
      necesitaActualizar = true;
    }
    setState(() {});
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EmailUsuarioAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    final contextoEmailAdmin = context.read<EmailAdministradorAppProvider>();
    _emailAdministrador = contextoEmailAdmin.emailAdministradorApp;
  }

  Future<String> obtenerImagenDesdeFirebase() async {
    final contextoRoles = context.read<RolUsuarioProvider>();
    if (contextoRoles.rol == RolEmpleado.administrador) {
      final perfil =
          await FirebaseProvider().cargarPerfilFB(_emailAdministrador);
      return perfil.foto.toString();
    } else {
      final perfil = await FirebaseProvider()
          .cargarPerfilEmpleado(_emailAdministrador, _emailSesionUsuario);
      return perfil.foto.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contextoRoles = context.read<RolUsuarioProvider>();
    bool esAdmin = contextoRoles.rol == RolEmpleado.administrador;
    bool esGerente = contextoRoles.rol == RolEmpleado.gerente;
    // Lista de opciones del menú
    final List<MenuOpcion> opciones = [
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.home_repair_service_outlined,
          texto: 'Tus servicios',
          onTap: () {
            // Navegar a la pantalla de servicios
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServiciosScreen()),
            );
          },
        ),
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.person,
          texto: 'Gestión de personal',
          onTap: () {
            // Navegar a la pantalla de gestión de personal
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmpleadosScreen()),
            );
          },
        ),
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.settings,
          texto: 'Configuración',
          onTap: () {
            // Navegar a la pantalla de configuración
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ConfigPersonalizar()),
            );
          },
        ),
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.beach_access,
          texto: 'Disponibilidad Semanal',
          onTap: () {
            // Navegar a la pantalla de disponibilidad semanal
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DisponibilidadSemanalScreen()),
            );
          },
        ),
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.bar_chart_rounded,
          texto: 'Informes',
          onTap: () {
            // Navegar a la pantalla de informes
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InformesScreen()),
            );
          },
        ),
      MenuOpcion(
        icono: Icons.notification_important_outlined,
        texto: 'Notificaciones',
        onTap: () {
          // Navegar a la pantalla de notificaciones
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(index: 1, myBnB: 1)),
          );
        },
      ),
      if (esAdmin || esGerente)
        MenuOpcion(
          icono: Icons.email,
          texto: 'Reportes/sugerencias',
          onTap: () {
            // Acción para reportes y sugerencias
            Comunicaciones.enviaEmailConAsunto(
                'Reporte y/o sugerencias para Agenda de Citas');
          },
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo casi blanco
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _cabeceraConSesion(context),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos columnas
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: opciones.length,
                  itemBuilder: (context, index) {
                    return _TarjetaOpcion(opcion: opciones[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabeceraConSesion(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Fondo de color azul
          Container(
            height: 180,
            color: Colors.blue, // Fondo azul
          ),
          // Contenido del encabezado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              accountEmail: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del negocio en blanco
                    denominacionNegocio(_emailAdministrador),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Indicador de versión de prueba
                          _estadopago == 'PRUEBA_ACTIVA'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'versión de prueba',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          // Versión de la aplicación
                          Text(
                            'versión $versionApp',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              accountName: const Text(''),
              // Imagen de perfil
              currentAccountPicture: CircleAvatar(
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage("assets/images/nofoto.jpg")
                        as ImageProvider,
              ),
              // Ícono de edición moderno
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(
                      Icons.edit_outlined), // Ícono de edición más elegante
                  color: Colors.white,
                  onPressed: () => context.read<RolUsuarioProvider>().rol ==
                          RolEmpleado.administrador
                      ? Navigator.pushNamed(context, 'ConfigPerfilAdminstrador')
                      : Navigator.pushNamed(context, 'ConfigPerfilUsuario'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  imagenUrl() async {
    imageUrl = await obtenerImagenDesdeFirebase();
    setState(() {});
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final MenuOpcion opcion;

  const _TarjetaOpcion({Key? key, required this.opcion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: opcion.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(opcion.icono, size: 35, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              opcion.texto,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuOpcion {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  MenuOpcion({
    required this.icono,
    required this.texto,
    required this.onTap,
  });
}
