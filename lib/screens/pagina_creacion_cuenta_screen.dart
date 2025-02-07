import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';

import 'package:agendacitas/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rive/rive.dart' as rive;

import '../providers/providers.dart';

class PaginaIconoAnimado extends StatefulWidget {
  const PaginaIconoAnimado(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;
  @override
  State<PaginaIconoAnimado> createState() => _PaginaIconoAnimadoState();
}

class _PaginaIconoAnimadoState extends State<PaginaIconoAnimado> {
  bool cuentaCreada = false;

  void creaCuentaUsuario() async {
    // EL RESULTADO DE CREACION DE CUENTA ES CORRECTA
    debugPrint('CREANDO NUEVA CUENTA');

    //await PagoProvider().guardaPagado(false, widget.email.toString());
    await configuracionInfoPagoRespaldo(widget.email);

    // ACTUALIZA EL PROVIDER DE CUENTA NUEVA para que en inicio_config_app.dart NO acceda a la pantalla home mientras se crea la cuenta
    context.read<CuentaNuevaProvider>().setCuentaNueva(true);

    // CREA EN FIREBASE UNA CUENTA NUEVA

    final res =
        await creaCuentaUsuarioApp(context, widget.email, widget.password);
    setState(() => cuentaCreada = true);
  }

  @override
  void initState() {
    super.initState();
    creaCuentaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return !cuentaCreada ? const IconoAnimado() : ConfiguracionPersonalizada();
  }

//METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  configuracionInfoPagoRespaldo(email) async {
    try {
      // RESPALDO DATOS EN FIREBASE
      await SincronizarFirebase().sincronizaSubeFB(email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

// pagina principal de personalización de cuenta  -----------------------------------
class ConfiguracionPersonalizada extends StatefulWidget {
  const ConfiguracionPersonalizada({super.key});

  @override
  State<ConfiguracionPersonalizada> createState() =>
      _ConfiguracionPersonalizadaState();
}

class _ConfiguracionPersonalizadaState
    extends State<ConfiguracionPersonalizada> {
  final PageController _pageController = PageController(initialPage: 0);
  List<Widget> paginasPersonalizacion = [];
  int _paginaActual = 0;

  void paginaSiguiente() {
    if (_paginaActual >= 0 && _paginaActual < paginasPersonalizacion.length) {
      //  _paginaActual++;
      _pageController
          .animateToPage(
            _paginaActual,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => debugPrint("Cambiada a página: $_paginaActual"));
    } else {
      _paginaActual = 0;

      // ir a la pantalla de inicio
      debugPrint("No hay más páginas.");
    }
  }

  /*  void paginaAnterior() {
    _pageController
        .animateToPage(
          _paginaActual--,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) => debugPrint("Cambiada a página: $_paginaActual"));

    if (_paginaActual < paginasPersonalizacion.length) {
      // Actualiza según el número de páginas
    
      _paginaActual++;
    } else {
      debugPrint("No hay más páginas.");
    }
  } */
  @override
  void initState() {
    super.initState();
    final pageViewProvider =
        Provider.of<PaginacionProvider>(context, listen: false);
    pageViewProvider.actualizarPagina(0);
  }

  @override
  Widget build(BuildContext context) {
    final pageViewProvider =
        Provider.of<PaginacionProvider>(context, listen: true);
    _paginaActual = pageViewProvider.paginaActual;
    paginaSiguiente();

    paginasPersonalizacion = [
      const PersonalizaUsuario(),
      const PersonalizaPais(),
      const HorarioApertura(),
      const ResumenPersonalizacion(),
    ];
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Imagen y título
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/personaliza.png',
                            height: 170, // Ajustar el tamaño según el diseño
                          ),
                          const Text(
                            '¡Ya casi lo tenemos!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // PageView widget con Consumer
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: paginasPersonalizacion.length,
                  itemBuilder: (context, index) {
                    return paginasPersonalizacion[index];
                  },
                ),
              ),
              BontonProgreso(
                paginas: paginasPersonalizacion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalizaUsuario extends StatefulWidget {
  const PersonalizaUsuario({super.key});

  @override
  State<PersonalizaUsuario> createState() => _PersonalizaUsuarioState();
}

class _PersonalizaUsuarioState extends State<PersonalizaUsuario> {
  bool personalizadoUsuario = false;
  TextEditingController nombreController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController denominacionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final contextoConfiguracion = context.read<PrimeraConfiguracionProvider>();
    nombreController.text = contextoConfiguracion.nombreUsuario;
    telefonoController.text = contextoConfiguracion.telefonoEmpresa;
    denominacionController.text = contextoConfiguracion.denominacionNegocio;
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Designa la denominación y contacto del negocio, y el usuario que aparecerá en las citas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Form(
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    onChanged: (value) =>
                        contextoConfiguracion.setNombreyTelefono(
                            nombreController.text,
                            telefonoController.text,
                            denominacionController.text),
                    controller:
                        denominacionController, // Controlador para el nombre de usuario
                    decoration: const InputDecoration(
                      hintText: 'Denominación del negocio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onChanged: (value) =>
                        contextoConfiguracion.setNombreyTelefono(
                            nombreController.text,
                            telefonoController.text,
                            denominacionController.text),
                    controller:
                        telefonoController, // Controlador para el teléfono de la empresa
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'teléfono de empresa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Introduce un número válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onChanged: (value) =>
                        contextoConfiguracion.setNombreyTelefono(
                            nombreController.text,
                            telefonoController.text,
                            denominacionController.text),
                    controller:
                        nombreController, // Controlador para el nombre de usuario
                    decoration: const InputDecoration(
                      hintText: 'nombre de usuario',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalizaPais extends StatefulWidget {
  const PersonalizaPais({
    super.key,
  });

  @override
  State<PersonalizaPais> createState() => _PersonalizaPaisState();
}

class _PersonalizaPaisState extends State<PersonalizaPais> {
  bool personalizadoPais = false;
  TextEditingController monedaController = TextEditingController();
  TextEditingController codigoPaisController = TextEditingController();
  late PersonalizaModelFirebase nuevoPersonaliza;

  final List<Map<String, String>> countries = [
    {
      'code': '54',
      'flag': 'assets/flags/ar.png',
      'name': 'Argentina',
      'symbol': 'ARS',
      'icon': '\$'
    },
    {
      'code': '591',
      'flag': 'assets/flags/bo.png',
      'name': 'Bolivia',
      'symbol': 'BOB',
      'icon': 'Bs'
    },
    {
      'code': '56',
      'flag': 'assets/flags/cl.png',
      'name': 'Chile',
      'symbol': 'CLP',
      'icon': '\$'
    },
    {
      'code': '57',
      'flag': 'assets/flags/co.png',
      'name': 'Colombia',
      'symbol': 'COP',
      'icon': '\$'
    },
    {
      'code': '34',
      'flag': 'assets/flags/es.png',
      'name': 'España',
      'symbol': 'EUR',
      'icon': '€'
    },
    /*  {'code': '506', 'flag': 'assets/flags/cr.svg', 'name': 'Costa Rica'},
    {'code': '53', 'flag': 'assets/flags/cu.svg', 'name': 'Cuba'},
    {'code': '593', 'flag': 'assets/flags/ec.svg', 'name': 'Ecuador'},
    {'code': '503', 'flag': 'assets/flags/sv.svg', 'name': 'El Salvador'},
    ,
    {'code': '502', 'flag': 'assets/flags/gt.svg', 'name': 'Guatemala'},
    {'code': '504', 'flag': 'assets/flags/hn.svg', 'name': 'Honduras'},
    {'code': '52', 'flag': 'assets/flags/mx.svg', 'name': 'México'},
    {'code': '505', 'flag': 'assets/flags/ni.svg', 'name': 'Nicaragua'},
    {'code': '507', 'flag': 'assets/flags/pa.svg', 'name': 'Panamá'},
    {'code': '595', 'flag': 'assets/flags/py.svg', 'name': 'Paraguay'},
    {'code': '51', 'flag': 'assets/flags/pe.svg', 'name': 'Perú'},
    {'code': '1-809', 'flag': 'assets/flags/do.svg', 'name': 'Rep. Dominicana'},
    {'code': '598', 'flag': 'assets/flags/uy.svg', 'name': 'Uruguay'},
    {'code': '58', 'flag': 'assets/flags/ve.svg', 'name': 'Venezuela'}, */
  ];
  /*  final List<Map<String, String>> currencies = [
    {'name': 'Peso Argentino', 'symbol': 'ARS', 'icon': '\$'},
    {'name': 'Boliviano', 'symbol': 'BOB', 'icon': 'Bs'},
    {'name': 'Peso Chileno', 'symbol': 'CLP', 'icon': '\$'},
    {'name': 'Peso Colombiano', 'symbol': 'COP', 'icon': '\$'},
    {'name': 'Euro (España)', 'symbol': 'EUR', 'icon': '€'},
     {'name': 'Colón Costarricense', 'symbol': 'CRC', 'icon': '₡'},
    {'name': 'Peso Cubano', 'symbol': 'CUP', 'icon': '\$'},
    {'name': 'Dólar Estadounidense (Ecuador)', 'symbol': 'USD', 'icon': '\$'},
    {'name': 'Bitcoin (El Salvador)', 'symbol': 'BTC', 'icon': '₿'},
   
    {'name': 'Quetzal Guatemalteco', 'symbol': 'GTQ', 'icon': 'Q'},
    {'name': 'Lempira Hondureño', 'symbol': 'HNL', 'icon': 'L'},
    {'name': 'Peso Mexicano', 'symbol': 'MXN', 'icon': '\$'},
    {'name': 'Córdoba Nicaragüense', 'symbol': 'NIO', 'icon': 'C\$'},
    {'name': 'Balboa Panameño', 'symbol': 'PAB', 'icon': 'B/.'},
    {'name': 'Guaraní Paraguayo', 'symbol': 'PYG', 'icon': '₲'},
    {'name': 'Nuevo Sol Peruano', 'symbol': 'PEN', 'icon': 'S/.'},
    {'name': 'Peso Dominicano', 'symbol': 'DOP', 'icon': '\$'},
    {'name': 'Peso Uruguayo', 'symbol': 'UYU', 'icon': '\$'},
    {'name': 'Bolívar Venezolano', 'symbol': 'VES', 'icon': 'Bs.'},
  ]; */

  @override
  Widget build(BuildContext context) {
    final contextoConfiguracion = context.read<PrimeraConfiguracionProvider>();

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            spacing: 30,
            children: [
              Text(
                'Personaliza tu cuenta para ajustarla a tu ubicación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              Form(
                child: Column(
                  spacing: 20,
                  children: [
                    DropdownButtonFormField<String>(
                      value: contextoConfiguracion.codigoPais,
                      decoration: const InputDecoration(
                        labelText: 'País',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        codigoPaisController.text = value!;
                        /*  contextoConfiguracion.setCodPaisyMoneda(
                            value, contextoConfiguracion.moneda); */

                        Map<String, String>? selectedPais =
                            countries.firstWhere(
                          (currency) => currency['code'] == value,
                          orElse: () =>
                              {}, // Opcional: Manejar caso de no encontrar resultado
                        );

                        Map pais = {
                          'codigo': selectedPais['code'],
                          'nombre': selectedPais['name'],
                          'bandera': selectedPais['flag'],
                          'moneda': selectedPais['icon'],
                        };

                        contextoConfiguracion.setCodPaisyMoneda(pais);

                        print('País seleccionado: ${pais}');
                      },
                      items: countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            children: [
                              Image.asset(
                                  height: 25, '${country['flag']}', width: 25),
                              SizedBox(width: 10),
                              Text('${country['name']} '),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HorarioApertura extends StatefulWidget {
  const HorarioApertura({super.key});

  @override
  State<HorarioApertura> createState() => _HorarioAperturaState();
}

class _HorarioAperturaState extends State<HorarioApertura> {
  TimeOfDay apertura = TimeOfDay(hour: 8, minute: 0); // Hora de apertura
  TimeOfDay cierre = TimeOfDay(hour: 22, minute: 0); // Hora de cierre

  // Función para mostrar el selector de hora
  Future<void> _seleccionarHora(bool esApertura) async {
    final contextoConfiguracion = context.read<PrimeraConfiguracionProvider>();
    TimeOfDay horaSeleccionada = esApertura ? apertura : cierre;
    final TimeOfDay? nuevaHora = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada,
    );

    if (nuevaHora != null) {
      setState(() {
        if (esApertura) {
          apertura = nuevaHora;
          final contextoConfiguracion =
              context.read<PrimeraConfiguracionProvider>();
        } else {
          cierre = nuevaHora;
        }
      });
    }
    contextoConfiguracion.setHorario(
        apertura.format(context), cierre.format(context));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Seleccione horario laboral:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),

          // Selección de apertura
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Apertura: ${apertura.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarHora(true),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),
          ),

          // Selección de cierre
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cierre: ${cierre.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarHora(false),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),
          ),

          /*  // Botón para guardar los horarios
          ElevatedButton(
            onPressed: () {
              // Aquí puedes guardar los horarios seleccionados para todos los días
              String horariosSeleccionados =
                  'Apertura: ${apertura.format(context)}\nCierre: ${cierre.format(context)}';

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Horarios Seleccionados'),
                    content: Text(horariosSeleccionados),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Guardar Horarios'),
          ), */
        ],
      ),
    );
  }
}

class ResumenPersonalizacion extends StatefulWidget {
  const ResumenPersonalizacion({super.key});

  @override
  State<ResumenPersonalizacion> createState() => _ResumenPersonalizacionState();
}

class _ResumenPersonalizacionState extends State<ResumenPersonalizacion> {
  @override
  Widget build(BuildContext context) {
    final contextoConfiguracion = context.read<PrimeraConfiguracionProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Resumen de la personalización',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildSummaryItem(
                      title: 'Nombre de Usuario',
                      value: contextoConfiguracion.nombreUsuario,
                      icon: Icons.person_outline,
                    ),
                    _buildDivider(),
                    _buildSummaryItem(
                      title: 'Teléfono de Empresa',
                      value: contextoConfiguracion.telefonoEmpresa,
                      icon: Icons.phone_android_outlined,
                    ),
                    _buildDivider(),
                    _buildSummaryItem(
                      title: 'País',
                      value: contextoConfiguracion.nombrePais,
                      icon: Icons.public_outlined,
                    ),
                    _buildDivider(),
                    _buildSummaryItem(
                      title: 'Horario Laboral',
                      value:
                          'De ${contextoConfiguracion.apertura} a ${contextoConfiguracion.cierre}',
                      icon: Icons.access_time_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Puedes agregar aquí un botón de confirmación si es necesario
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.black12,
    );
  }

  Widget _buildSummaryItem(
      {required String title, required String value, required IconData icon}) {
    final contextoConfiguracion = context.read<PrimeraConfiguracionProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Visibility(
                      visible: icon == Icons.public_outlined,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.asset(contextoConfiguracion.banderaPais,
                            height: 25, width: 25),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*   Visibility(
            visible: personalizadoPais,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 355,
                    height: 355,
                    child: Image(
                        image: AssetImage('assets/images/cuentaCreada.png')),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => RegistroUsuarioScreen(
                                      registroLogin: 'Login',
                                      usuarioAPP: '',
                                    )),
                          ),
                      child: const Text('Ya puedes iniciar sesión')),
                ],
              ),
            ),
          ) */

class IconoAnimado extends StatelessWidget {
  const IconoAnimado({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: rive.RiveAnimation.asset(
                'assets/icon/iconoapp.riv',
                fit: BoxFit.contain,
              ),
            ),
            Text('creando cuenta...'),
          ],
        ),
      ),
    );
  }
}

class PaginacionProvider extends ChangeNotifier {
  int _paginaActual = 0; // Página activa
  int get paginaActual => _paginaActual;

  void actualizarPagina(int index) {
    if (index != _paginaActual) {
      _paginaActual = index;
      notifyListeners();
    }
  }
}

class PrimeraConfiguracionProvider extends ChangeNotifier {
  bool _configuracionCompleta = false;
  bool get configuracionCompleta => _configuracionCompleta;

  String _idEmpleado = '';
  String get idEmpleado => _idEmpleado;
  String _denominacionNegocio = '';
  String get denominacionNegocio => _denominacionNegocio;
  String _nombreUsuario = '';
  String get nombreUsuario => _nombreUsuario;
  String _telefonoEmpresa = '';
  String get telefonoEmpresa => _telefonoEmpresa;

  String _nombrePais = 'España';
  String get nombrePais => _nombrePais;
  String _banderaPais = 'assets/flags/es.png';
  String get banderaPais => _banderaPais;
  String _codigoPais = '34';
  String get codigoPais => _codigoPais;
  String _moneda = '€';
  String get moneda => _moneda;
  String _apertura = '08:00';
  String get apertura => _apertura;
  String _cierre = '22:00';
  String get cierre => _cierre;

  void setIdEmpleado(String id) {
    _idEmpleado = id;
    notifyListeners();
  }

  void setNombreyTelefono(String nombre, String telefono, String denominacion) {
    _nombreUsuario = nombre;
    _telefonoEmpresa = telefono;
    _denominacionNegocio = denominacion;
    notifyListeners();
  }

  void setCodPaisyMoneda(Map pais) {
    _codigoPais = pais['codigo'];
    _moneda = pais['moneda'];
    _nombrePais = pais['nombre'];
    _banderaPais = pais['bandera'];
    notifyListeners();
  }

  void setHorario(String apertura, String cierre) {
    _apertura = apertura;
    _cierre = cierre;
    notifyListeners();
  }
}

class BontonProgreso extends StatefulWidget {
  final List<dynamic> paginas;
  const BontonProgreso({super.key, required this.paginas});

  @override
  State<BontonProgreso> createState() => _BontonProgresoState();
}

class _BontonProgresoState extends State<BontonProgreso> {
  int _paginaActual = 0;
  @override
  Widget build(BuildContext context) {
    final pageViewProvider =
        Provider.of<PaginacionProvider>(context, listen: true);
    _paginaActual = pageViewProvider.paginaActual;
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(width: 120, child: _botonAtras(pageViewProvider)),
          Container(
            width: 150,
            child: _botonContinuar(pageViewProvider),
          ),
        ],
      ),
    );
  }

  /*      nuevoPersonaliza = PersonalizaModelFirebase(
                        moneda: monedaController.text == ''
                            ? '€'
                            : monedaController.text,
                        codpais: codigoPaisController.text == ''
                            ? '34'
                            : codigoPaisController.text,
                        colorTema: '0xFF000000',
                        tiempoRecordatorio: '24:00');

                    // guarda en firebase
                    String email =
                        FirebaseAuth.instance.currentUser!.email.toString();
                    final actualizadoCorrectamente = await FirebaseProvider()
                        .actualizaPersonaliza(context, email, nuevoPersonaliza);

                    if (actualizadoCorrectamente) {
                      // personalizadoPais = true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Error al guardar la configuración de la cuenta'),
                        ),
                      );
                    } */
  _botonAtras(pageViewProvider) {
    return GestureDetector(
      onTap: () {
        /*  if (_paginaActual == 3) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RegistroUsuarioScreen(
                    registroLogin: 'Login',
                    usuarioAPP: '',
                  )));
        } else */
        // paginaSiguiente();

        if (_paginaActual >= 1) {
          _paginaActual--;
          pageViewProvider.actualizarPagina(_paginaActual);
          setState(() {});
        } else {
          print('ir a la pantalla de inicio');
          /*   Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RegistroUsuarioScreen(
                    registroLogin: 'Login',
                    usuarioAPP: '',
                  ))); */
        }
        /* _paginaActual = 0;
        pageViewProvider.actualizarPagina(0); */
        print('paginas: ${widget.paginas.length}');
        print('pagina actual Boton: $_paginaActual');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 44, 43, 92),
              Colors.black
            ], // Gradiente verde
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Atrás',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _botonContinuar(pageViewProvider) {
    final usuarioEmail = FirebaseAuth.instance.currentUser!.email.toString();

    return GestureDetector(
      onTap: () async {
        /*  final contextoConfiguracion =
            context.read<PrimeraConfiguracionProvider>();
        contextoConfiguracion.setCodPaisyMoneda(
            contextoConfiguracion.codigoPais,
            {"name": "Euro (España)", "symbol": "EUR", "icon": "€"}); */
        if (_paginaActual >= 0 && _paginaActual < widget.paginas.length - 1) {
          _paginaActual++;
          pageViewProvider.actualizarPagina(_paginaActual);
          setState(() {});
        } else {
          //guardar en contexto de la app
          final contextoConfiguracion =
              context.read<PrimeraConfiguracionProvider>();

          ///guardar en firebase la configuracion de la cuenta····················
          ///documento configuracion
          final nuevoConfiguracion = PersonalizaModelFirebase(
              moneda: contextoConfiguracion.moneda,
              codpais: contextoConfiguracion.codigoPais,
              colorTema: '0xFF000000',
              tiempoRecordatorio: '24:00');

          await FirebaseProvider()
              .actualizaPersonaliza(context, usuarioEmail, nuevoConfiguracion);

          ///documento empleado
          final edicionEmpleado = EmpleadoModel(
              id: contextoConfiguracion.idEmpleado,
              nombre: contextoConfiguracion.nombreUsuario,
              telefono: contextoConfiguracion.telefonoEmpresa,
              emailUsuarioApp: usuarioEmail,
              disponibilidad: [],
              email: usuarioEmail,
              categoriaServicios: [],
              foto: '',
              color: 4294901760,
              codVerif: 'verificado',
              roles: []);

          await SincronizarFirebase().creaUsuariocomoEmpleado(
            edicionEmpleado,
            contextoConfiguracion.denominacionNegocio,
            contextoConfiguracion.apertura,
            contextoConfiguracion.cierre,
          );

          /// navegar a la pantalla de inicio ····································
          print('ir a la pantalla de inicio sesion');

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => RegistroUsuarioScreen(
                registroLogin: 'Login',
                usuarioAPP: '',
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
        /* _paginaActual = 0;
        pageViewProvider.actualizarPagina(0); */
        print('paginas: ${widget.paginas.length}');
        print('pagina actual Boton: $_paginaActual');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: _paginaActual == widget.paginas.length - 1
                ? const [
                    Color.fromARGB(255, 68, 113, 172),
                    Color.fromARGB(255, 128, 139, 231)
                  ]
                : [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Gradiente verde
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          _paginaActual == widget.paginas.length - 1
              ? 'Finalizar'
              : 'Continuar',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
