import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:agendacitas/utils/formatear.dart';
import 'package:agendacitas/utils/verificaDiferenciaHorario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/providers.dart';
import '../creacion_citas/provider/creacion_cita_provider.dart';

class TarjetaIndisponibilidad extends StatefulWidget {
  final dynamic argument;
  const TarjetaIndisponibilidad({super.key, this.argument});

  @override
  State<TarjetaIndisponibilidad> createState() =>
      _TarjetaIndisponibilidadState();
}

class _TarjetaIndisponibilidadState extends State<TarjetaIndisponibilidad> {
  int _selectedIndex = 0; // Variable para almacenar el índice seleccionado
  DateTime? dateTimeElegido;
  Duration? selectedDateTime;
  String? selectedTimeOption;

  late CreacionCitaProvider contextoCreacionCita;
  final _formKey = GlobalKey<FormState>();
  late MyLogicNoDisponible myLogic;
  CitaModel citaInicio = CitaModel();
  CitaModel citaFin = CitaModel();

  String fechaPantalla = '';
  String dia = '';
  String horaInicioPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String horaFinPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String fechaInicio = '';
  String fechaFin = '';
  DateTime? horaInicio;
  DateTime? fechaElegida; // provider fecha elegida
  DateTime? horaFin; // provider hora fin elegida
  String horaInicioTexto = ''; //2024-08-09 13:00:00.000Z'
  String horaFinTexto = ''; //2024-08-09 14:00:00.000Z'

  bool personalizado = true;

  final _asuntoController = TextEditingController();
  bool botonActivado = false;

  late ControladorTarjetasAsuntos _controladorTarjetasAsuntos;
  late PageController _pageController;

  late TextoTituloIndispuesto providerTextoTitulo;

  @override
  void initState() {
    seteafechaElegida();
    reseteaHoraElegida();

    super.initState();

    // Obtén la instancia del ControladorTarjetasAsuntos
    _controladorTarjetasAsuntos =
        Provider.of<ControladorTarjetasAsuntos>(context, listen: false);

    // Asigna el PageController desde el controlador
    _pageController = _controladorTarjetasAsuntos.controller;

    /// inicializa la variable
    providerTextoTitulo =
        Provider.of<TextoTituloIndispuesto>(context, listen: false);

    // Escuchar cambios en el controlador del texto
    /*  _asuntoController.addListener(() {
      _validateField(textoTitulo);
    }); */
  }

  seteafechaElegida() {
    // provider fecha elegida
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
    providerFechaElegida.setFechaElegida(widget.argument);

    // Formatear la fecha  para visualizar en pantalla
  }

  reseteaHoraElegida() {
    final providerHoraFinCarrusel = context.read<HorarioElegidoCarrusel>();
    // hora inicio
    providerHoraFinCarrusel.setHoraInicio(widget.argument);
    // hora fin
    providerHoraFinCarrusel.setHoraFin(widget.argument);
  }

  String textoTitulo = '';
  @override
  Widget build(BuildContext context) {
    // provider del boton Guardar
    final personalizadoProvider =
        Provider.of<BotonGuardarAgregarNoDisponible>(context);
    personalizado =
        personalizadoProvider.forularioVisible; // formulario es visible o no

    // provider FECHA elegida
    final providerFechaElegida = Provider.of<FechaElegida>(context);
    fechaElegida = providerFechaElegida.fechaElegida;
    dia = DateFormat('yyyy-MM-dd') // fecha formateada para FIREBASE
        .format(fechaElegida!);

    // provider HORA elegida
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);

    // hora inicio
    horaInicio = providerHoraFinCarrusel.horaInicio;
    horaInicioPantalla = DateFormat('HH:mm').format(horaInicio!);

    // hora fin
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();
    horaFinPantalla = DateFormat('HH:mm').format(horaFin!);

    print('horaFinTexto para grabar cita -----------------------$horaFinTexto');

    //fecha y hora de inicio elegida
    // dateTimeElegido = widget.argument;

    horaInicioTexto = (fechaElegida).toString();
    horaInicio = fechaElegida;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                ' Agrega horario no disponible',
                style: estiloHorarios,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Tipo de horarios',
                    style: subTituloEstilo,
                  ),
                  const SizedBox(
                    width: 90,
                  ),
                  IconButton.outlined(
                      onPressed: () {
                        if (_pageController.hasClients) {
                          _controladorTarjetasAsuntos.paginaAnterior();
                        }
                      },
                      icon: const Icon(Icons.arrow_left)),
                  IconButton.outlined(
                      onPressed: () {
                        if (_pageController.hasClients) {
                          _controladorTarjetasAsuntos.paginaSiguiente();
                        }
                      },
                      icon: const Icon(Icons.arrow_right)),
                ],
              ),

              // ------------------- ASUNTOS----------------------------
              //_listaAsuntos(context, fechaElegida, providerHoraFinCarrusel),
              TarjetasAsuntos(fechaElegida: fechaElegida),
              const SizedBox(height: 40),
              // -------------------TEXTO PERSONALIZADO ----------------------------

              Visibility(
                visible: personalizado,
                child: const FormularioAsunto(),
              ),
              Visibility(
                  visible: !personalizado, child: _textoAsuntoPredefinido()),

              //Text(providerTextoTitulo.getTitulo)),
              const SizedBox(height: 20),
              // ------------------- PRESENTACION DE FECHA Y HORAS---------
              _presentacionFecha(),
              const SizedBox(height: 20),
              _presentacionHoras(),
              const SizedBox(height: 40),

              const BotonGuardar(),
            ]),
          ),
        ),
      ),
    );
  }

  Column _textoAsuntoPredefinido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Título:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          width: double.infinity, // Ocupa todo el ancho de la pantalla
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
                color: Colors.black,
                width: 1), // Borde para asemejar el outline
          ),
          child: Text(
            providerTextoTitulo.getTitulo,
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  _presentacionFecha() {
    final dia = DateFormat('dd-MM-yyyy') // FECHA FORMATEADA ESPAÑOLA
        .format(fechaElegida!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () => _mostrarTarjeta(context, 'calendario', widget.argument),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dia, style: estiloHorarios),
                const Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ),
      ],
    );
  }

  _presentacionHoras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hora:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () => _mostrarTarjeta(context, 'hora', fechaElegida),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('de'),
                Text(
                  horaInicioPantalla,
                  style: estiloHorarios,
                ),
                const Text('a'),
                Text(horaFinPantalla, style: estiloHorarios),
                const Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ),
      ],
    );
  }

  _mostrarTarjeta(context, tarjeta, fecha) async {
    await showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return tarjeta == 'calendario'
            ? TarjetaCalendario(argument: fecha)
            : TarjetaHora(argument: fecha);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled:
          true, // Si quieres que el modal pueda ser de altura completa
    );
  }

  void cerrar() {
    Navigator.pop(context);
    setState(() {});
  }
}

///////////  TARJETA ASUNTOS    ///////////////////////////////////
class TarjetasAsuntos extends StatefulWidget {
  final DateTime? fechaElegida;
  const TarjetasAsuntos({super.key, this.fechaElegida});

  @override
  State<TarjetasAsuntos> createState() => _TarjetasAsuntosState();
}

class _TarjetasAsuntosState extends State<TarjetasAsuntos> {
  String fechaPantalla = '';
  String dia = '';
  String horaInicioPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String horaFinPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String fechaInicio = '';
  String fechaFin = '';
  DateTime? horaInicio;
  DateTime? fechaElegida; // provider fecha elegida
  DateTime? horaFin; // provider hora fin elegida
  String horaInicioTexto = ''; //2024-08-09 13:00:00.000Z'
  String horaFinTexto = ''; //2024-08-09 14:00:00.000Z'
  String textoTitulo = '';
  bool? personalizado;
  int _selectedIndex = 0; // Variable para almacenar el índice seleccionado
  String _emailSesionUsuario = '';
  late ControladorTarjetasAsuntos _controladorTarjetasAsuntos;
  late BotonGuardarAgregarNoDisponible _personalizadoProvider;

  List<Map<String, Duration>?> _asuntos = [];
  Map<String, Duration>? asunto1;
  Map<String, Duration>? asunto2;
  Map<String, Duration>? asunto3;
  Map<String, Duration>? asunto4;
  Map<String, Duration>? asunto5;
  Future<void> traeAsuntosIndisponibilidad() async {
    // Obtener los asuntos desde Firebase
    final asuntosFB =
        await FirebaseProvider().getAsuntosIndispuestos(_emailSesionUsuario);

    // Imprimir los títulos de los asuntos obtenidos desde Firebase
    for (var element in asuntosFB) {
      print(element['id']);
    }

    // Inicializar los asuntos por defecto : id? lo utilizo para los asuntos de Firebase
    asunto1 = {'✏️ Personalizado id?': const Duration()};
    asunto2 = {'🥣 Descanso id?': const Duration(minutes: 30)};
    asunto3 = {'🤸 Gym id?': const Duration(hours: 1, minutes: 30)};
    asunto4 = {'📅 Reunión id?': const Duration(hours: 1)};
    asunto5 = {'➕ Nuevo asunto id?': const Duration()};

    // Agregar los asuntos por defecto a la lista
    _asuntos = [asunto1, asunto2, asunto3, asunto4];

    // Agregar los asuntos obtenidos desde Firebase a la lista _asuntos
    for (var element in asuntosFB) {
      // Crear un nuevo mapa con el título y la duración desde Firebase
      //? al titulo le agrego el id para  poder editarlo
      final Map<String, Duration> asuntoDesdeFB = {
        element['titulo'] + 'id?' + '${element['id']}': Duration(
          hours: element['horas'],
          minutes: element['minutos'],
        )
      };

      // Agregar el asunto desde Firebase a la lista _asuntos
      _asuntos.add(asuntoDesdeFB);
    }
    if (asuntosFB.length < 3) {}
    _asuntos.add(asunto5);
    // Ahora _asuntos contiene tanto los asuntos por defecto como los de Firebase
  }

  @override
  void initState() {
    super.initState();
    emailUsuario();
    // Obtén la instancia del ControladorTarjetasAsuntos
    _controladorTarjetasAsuntos =
        Provider.of<ControladorTarjetasAsuntos>(context, listen: false);
    traeAsuntosIndisponibilidad();
    _personalizadoProvider =
        Provider.of<BotonGuardarAgregarNoDisponible>(context, listen: false);
    personalizado = _personalizadoProvider.forularioVisible;
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  @override
  Widget build(BuildContext context) {
    final providerTextoTitulo = context.read<TextoTituloIndispuesto>();
    final color = Theme.of(context).primaryColor; // color del tema
    final personalizadoProvider =
        Provider.of<BotonGuardarAgregarNoDisponible>(context);

    // provider FECHA elegida
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
    fechaElegida = providerFechaElegida.fechaElegida;
    dia = DateFormat('yyyy-MM-dd') // fecha formateada para FIREBASE
        .format(fechaElegida!);

    // provider HORA elegida
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);
    // hora inicio
    horaInicio = providerHoraFinCarrusel.horaInicio;
    horaInicioPantalla = DateFormat('HH:mm').format(horaInicio!);

    // hora fin
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();
    horaFinPantalla = DateFormat('HH:mm').format(horaFin!);

    print('horaFinTexto para grabar cita -----------------------$horaFinTexto');

    horaInicioTexto = (fechaElegida).toString();
    horaInicio = fechaElegida;

    return SizedBox(
        height: 130,
        child: FutureBuilder<void>(
          future: traeAsuntosIndisponibilidad(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              // Si hay un error, muestra un mensaje de error
              return const Center(
                child: Text('Error al cargar los asuntos'),
              );
            } else {
              // Si se completó la carga, muestra la lista de asuntos
              return PageView.builder(
                controller: _controladorTarjetasAsuntos.controller,
                itemCount: _asuntos.length,
                itemBuilder: (BuildContext context, int i) {
                  String duracion = formateaDurationString(_asuntos, i);
                  print(_asuntos.length);
                  return InkWell(
                      onTap: () async {
                        _selectedIndex = i; // Guardar el índice seleccionado
                        // Navegar a la página seleccionada
                        if (_controladorTarjetasAsuntos.controller.hasClients) {
                          _controladorTarjetasAsuntos.setea(_selectedIndex);
                        }
                        // VERIFICO EL ULTIMO DE LA LISTA DE ASUSNTOS (+ NUEVO ASUSNTO)
                        if (i != _asuntos.length - 1) {
                          // si el asunto es PERSONALIZADO , visible el form texto personalizado
                          _selectedIndex == 0
                              ? personalizadoProvider.setBotonGuardar(true)
                              : personalizadoProvider.setBotonGuardar(false);

                          // texto del asunto elegido para grabar en firebase
                          providerTextoTitulo
                              .setTitulo(_asuntos[i]!.keys.first.toString());

                          DateTime aux =
                              fechaElegida!.add(_asuntos[i]!.values.first);
                          horaFinTexto = aux.toString();
                          horaFinPantalla = DateFormat('HH:mm').format(aux);
                          // agrega al provider la hora fin
                          providerHoraFinCarrusel.setHoraFin(aux);
                        } else {
                          // ir a tarjeta creacion de asunto

                          await showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TarjetaCreacionAsunto(
                                edicion: false,
                                id: '',
                              );
                            },
                          ).then((shouldReset) {
                            _controladorTarjetasAsuntos
                                .resetPagina(); // Resetea a la página inicial

                            if (shouldReset == true) {
                              _controladorTarjetasAsuntos
                                  .resetPagina(); // Resetea a la página inicial
                            }
                          });
                          // setState(() {});
                        }
                      },
                      child: _asuntos.length > 7 && (i == _asuntos.length - 1)
                          ? Container() // si hay mas de 7 asuntos , la tarjeta de añadir no aparece para que no se añadan mas
                          : Card(
                              color: (i != _asuntos.length - 1)
                                  ? Colors.white
                                  : Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Radio de los bordes
                                side: BorderSide(
                                  style: BorderStyle.solid,
                                  color: (i != _asuntos.length - 1)
                                      ? _selectedIndex == i
                                          ? const Color(0xFF0000FF)
                                          : Colors.white
                                      : Colors
                                          .grey, // Cambia de color si está seleccionado
                                  width: 2, // Grosor del borde
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Botón de edición en la esquina superior derecha
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: ((_asuntos[i]!.keys.first)
                                                .split('id?')[1] !=
                                            '')
                                        ? IconButton(
                                            onPressed: () async {
                                              await showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return TarjetaCreacionAsunto(
                                                      edicion: true,
                                                      id: _asuntos[i]!
                                                          .keys
                                                          .first
                                                          .split('id?')[1]);
                                                },
                                              ).then((shouldReset) {
                                                _controladorTarjetasAsuntos
                                                    .resetPagina(); // Resetea a la página inicial

                                                if (shouldReset == true) {
                                                  _controladorTarjetasAsuntos
                                                      .resetPagina(); // Resetea a la página inicial
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.edit),
                                          )
                                        : Container(),
                                  ),
                                  // Centrar el asunto y la duración
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          // Separo el título y su id para solo rescatar el título
                                          (_asuntos[i]!.keys.first)
                                              .split('id?')[0],
                                          style: TextStyle(
                                            color: (i != _asuntos.length - 1)
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          duracion,
                                          style: subTituloEstilo,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                },
              );
            }
          },
        ));
  }
}

////////// FORMULARIO TITULO DEL ASUNTO //////////////////////////////
class FormularioAsunto extends StatefulWidget {
  const FormularioAsunto({super.key});

  @override
  State<FormularioAsunto> createState() => _FormularioAsuntoState();
}

class _FormularioAsuntoState extends State<FormularioAsunto> {
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  final TextEditingController _asuntoController = TextEditingController();

  final ValueNotifier asuntoNotifier = ValueNotifier("");
  late TextoTituloIndispuesto providerTextoTitulo;

  void _validateField(String value) {
    if (value.isEmpty) {
      setState(() {});
      _errorText = 'Este campo no puede estar vacío';
    } else {
      setState(() {});
      _errorText = null; // Campo válido
    }
  }

  @override
  void initState() {
    super.initState();
    // escucha el provider del titulo del asunto
    providerTextoTitulo = context.read<TextoTituloIndispuesto>();

    // Escuchar cambios en el controlador del texto
    _asuntoController.addListener(() {
      _validateField(providerTextoTitulo.getTitulo);
      print(
          'el titulo del asunto es: ----------------------------------- ${providerTextoTitulo.getTitulo}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Título:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Form(
          key: _formKey,
          child: TextFormField(
              // Validación para verificar si el campo está vacío
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo no puede estar vacío';
                }
                return null; // Si pasa la validación, devuelve null
              },
              onChanged: (value) {
                providerTextoTitulo.setTitulo(value);

                _validateField(value); // Llama a la validación manualmente
              },
              controller: _asuntoController,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 2)),
                  iconColor: color,
                  suffixIconColor: color,
                  fillColor: color,
                  hoverColor: color,
                  prefixIconColor: color,
                  focusColor: color,
                  hintText: 'ej.: 🥗 Comida de empresa',
                  errorText: _errorText)),
        ),
      ],
    );
  }
}

/////////// TARJETA DEL CALENDARIO ///////////////////////////////////

class TarjetaCalendario extends StatefulWidget {
  final dynamic argument;
  const TarjetaCalendario({super.key, this.argument});

  @override
  State<TarjetaCalendario> createState() => _TarjetaCalendarioState();
}

class _TarjetaCalendarioState extends State<TarjetaCalendario> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(children: [
        calendario(context),
      ]),
    );
  }

  calendario(context) {
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);

    final providerHorario =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);

    return TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: "es_ES",
      rowHeight: 65, // separacion entre los numeros diarios
      headerStyle:
          const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      daysOfWeekHeight: 50, //altura contenedor de los dias semanales
      daysOfWeekStyle: const DaysOfWeekStyle(
        decoration: BoxDecoration(color: Color.fromARGB(255, 210, 207, 219)),
        weekdayStyle: TextStyle(color: Color.fromARGB(255, 92, 91, 94)),
        weekendStyle: TextStyle(color: Color.fromARGB(255, 134, 6, 6)),
      ),
      availableGestures: AvailableGestures.all,
      selectedDayPredicate: (day) => isSameDay(
          day, providerFechaElegida.fechaElegida), // fecha seleccionada
      focusedDay: DateTime.now(),
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      onDaySelected: (day, newFechaElegida) {
        // Combina la nueva fecha con la hora original
        DateTime fechaConHoraRespetada = DateTime(
          newFechaElegida.year,
          newFechaElegida.month,
          newFechaElegida.day,
          providerFechaElegida.fechaElegida.hour,
          providerFechaElegida.fechaElegida.minute,
        );
        //setea provider fechaElegida y horario con la fecha seleccionada respetando la hora
        providerFechaElegida.setFechaElegida(fechaConHoraRespetada);
        providerHorario.setHoraInicio(fechaConHoraRespetada);
        providerHorario.setHoraFin(fechaConHoraRespetada);

        Navigator.pop(context);
      }, //_diaSeleccionado,
      // eventLoader: _getEventsForDay,
      calendarBuilders: CalendarBuilders(markerBuilder: (_, datetime, event) {
        return event.isEmpty
            ? Container()
            : Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: const Color.fromARGB(255, 197, 75, 75)),
                child: Center(
                  child: Text(
                    (event.length).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
      }),
    );
  }
}

/////////// TARJETA DE SELECCION DE HORARIOS /////////////////////////
class TarjetaHora extends StatefulWidget {
  final dynamic argument;
  const TarjetaHora({super.key, this.argument});

  @override
  State<TarjetaHora> createState() => _TarjetaHoraState();
}

class _TarjetaHoraState extends State<TarjetaHora> {
  bool botonActivado = false;

  @override
  Widget build(BuildContext context) {
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);
    // Verifica el estado del botón antes de construir la interfaz
    botonActivado = Verificadiferenciahorario.verificarBotonActivado(
        providerHoraFinCarrusel);
    return SizedBox(
      height: 500,
      child: seleccionHorarios(),
    );
  }

  seleccionHorarios() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CarruselDeHorarios(
                    horaSeleccionada: widget.argument, carrusel: 'horaInicio'),
                const Text('a'),
                CarruselDeHorarios(
                    horaSeleccionada: widget.argument, carrusel: 'horaFinal'),
              ],
            ),
            _botonEstablecerHorario()
          ],
        ),
      ),
    );
  }

  _botonEstablecerHorario() {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: botonActivado ? Colors.black : Colors.grey,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: InkWell(
            onTap: () {
              botonActivado ? Navigator.pop(context) : null;
            },
            child: const Center(
              child: Text(
                'Establecer',
                style: TextStyle(color: Colors.white),
              ),
            )));
  }
}

// ///////////////////// CARRUSEL DE HORARIO //////////////////////

class CarruselDeHorarios extends StatefulWidget {
  final DateTime? horaSeleccionada;
  final String? carrusel;

  const CarruselDeHorarios({super.key, this.horaSeleccionada, this.carrusel});

  static Map<String, DateTime> generarHorarios(DateTime horaSeleccionada) {
    final horaRef = DateTime(horaSeleccionada.year, horaSeleccionada.month,
        horaSeleccionada.day, 7, 0);

    Map<String, DateTime> horarios = {};
    DateTime startTime = horaRef; // 07:00h

    while (startTime.hour < 23 ||
        (startTime.hour == 23 && startTime.minute == 0)) {
      String formattedTime = DateFormat('HH:mm').format(startTime);
      horarios[formattedTime] = startTime;
      startTime = startTime.add(const Duration(minutes: 15));
    }

    return horarios;
  }

  @override
  State<CarruselDeHorarios> createState() => _CarruselDeHorariosState();
}

class _CarruselDeHorariosState extends State<CarruselDeHorarios> {
  DateTime? fechaElegida;

  Map<String, DateTime> horarios = {};
  final _pageController = PageController(viewportFraction: 0.2);
  int _currentPage = 0;

  double alturaCarrusel = 240;
  int numeroHoras = 1;

  @override
  void didChangeDependencies() {
    //seteaFechaElegida();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    horarios = CarruselDeHorarios.generarHorarios(widget.horaSeleccionada!);

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    // Navegar a la página deseada después de que el widget se haya construido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clave específica que queremos buscar
      String horaBuscada = DateFormat('HH:mm').format(widget.horaSeleccionada!);

      // Convertimos las claves en una lista y encontramos el índice de la clave deseada
      int indice = horarios.keys.toList().indexOf(horaBuscada);

      // Navega a la pagina numero:  índice
      // print('El índice de $horaBuscada es: $indice');
      _pageController.animateToPage(
        indice,
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);
    print(horarios);
    return GestureDetector(
        onTap: () {},
        child: SizedBox(
            width: 80,
            height: alturaCarrusel,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                  color: Colors.white,
                  width: 80,
                  height: alturaCarrusel,
                  // Altura del carrusel
                  child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _pageController,
                      itemCount: horarios.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });

                        // Actualizar Provider en base al carrusel
                        if (widget.carrusel == 'horaInicio') {
                          providerHoraFinCarrusel
                              .setHoraInicio(horarios.values.elementAt(index));
                        }

                        if (widget.carrusel == 'horaFinal') {
                          providerHoraFinCarrusel
                              .setHoraFin(horarios.values.elementAt(index));
                        }

                        print('INICIO: ${providerHoraFinCarrusel.horaInicio}');
                        print('FIN: ${providerHoraFinCarrusel.horaFin}');
                      },
                      itemBuilder: (context, i) {
                        String horario = horarios.keys.elementAt(i);

                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                horario,
                                style: estilo(i),
                              )
                            ],
                          ),
                        );
                      })),
            )));
  }

  void seteaFechaElegida() {
    // provider FECHA elegida
    /*  final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
     providerFechaElegida.setFechaElegida(hora); */

    final providerHorario =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);
    providerHorario.setHoraInicio(widget.horaSeleccionada!);
    providerHorario.setHoraFin(widget.horaSeleccionada!);
  }

  estilo(int i) {
    if (_currentPage == i) {
      return estiloHorariosResaltado;
    } else if (_currentPage == i - 1 || _currentPage == i + 1) {
      return estiloHorariosAlgoDifuminado;
    } else {
      return estiloHorariosDifuminado;
    }
  }
}

class BotonGuardar extends StatefulWidget {
  const BotonGuardar({super.key});

  @override
  State<BotonGuardar> createState() => _BotonGuardarState();
}

class _BotonGuardarState extends State<BotonGuardar> {
  String _emailSesionUsuario = '';
  bool botonActivado = false;
  bool personalizado = true;
  late TextoTituloIndispuesto providerTextoTitulo;
  String textoTitulo = '';

  String fechaPantalla = '';
  String dia = '';
  String horaInicioPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String horaFinPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String fechaInicio = '';
  String fechaFin = '';
  DateTime? horaInicio;
  DateTime? fechaElegida; // provider fecha elegida
  DateTime? horaFin; // provider hora fin elegida
  String horaInicioTexto = ''; //2024-08-09 13:00:00.000Z'
  String horaFinTexto = ''; //2024-08-09 14:00:00.000Z'

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  @override
  void initState() {
    super.initState();
    emailUsuario();
  }

  @override
  Widget build(BuildContext context) {
    // escucha el provider del titulo del asunto
    providerTextoTitulo = Provider.of<TextoTituloIndispuesto>(context);
    textoTitulo = providerTextoTitulo.getTitulo;
    // provider HORA elegida
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);
    // Verifica el estado del botón antes de construir la interfaz
    botonActivado = Verificadiferenciahorario.verificarBotonActivado(
        providerHoraFinCarrusel);

    // provider del boton Guardar
    final personalizadoProvider =
        Provider.of<BotonGuardarAgregarNoDisponible>(context);
    personalizado =
        personalizadoProvider.forularioVisible; // formulario es visible o no

    bool condicionBotonActivado() {
      //  con la variable 'personalizado' verfico si esta la opcion del asunto es personalizado
      // si es personalizado, compruebo con 'botonAtivado' los tramos horarios, y si el formulario está validado
      // si no es personalizado y el fomulario no esta visible, pues retorno la condicion verdadera para activar el boton y realizar el guardado.
      if (personalizado) {
        if (botonActivado && textoTitulo != ''
            /*  _formKey.currentState != null &&
            _formKey.currentState!.validate() &&
            _errorText == null */
            ) {
          return true;
        } else {
          return false;
        }
      }

      return true;
    }

    void cerrar() {
      personalizadoProvider.setBotonGuardar(true); // formulario es visible o no

      Navigator.pop(context);
      setState(() {});
    }

    // provider FECHA elegida
    final providerFechaElegida = Provider.of<FechaElegida>(context);
    fechaElegida = providerFechaElegida.fechaElegida;
    dia = DateFormat('yyyy-MM-dd') // fecha formateada para FIREBASE
        .format(fechaElegida!);

    // hora inicio
    horaInicio = providerHoraFinCarrusel.horaInicio;
    horaInicioPantalla = DateFormat('HH:mm').format(horaInicio!);

    // hora fin
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();
    horaFinPantalla = DateFormat('HH:mm').format(horaFin!);

    print('horaFinTexto para grabar cita -----------------------$horaFinTexto');

    //fecha y hora de inicio elegida
    // dateTimeElegido = widget.argument;

    horaInicioTexto = (fechaElegida).toString();
    horaInicio = fechaElegida;

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: condicionBotonActivado() ? Colors.black : Colors.grey,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: InkWell(
            onTap: condicionBotonActivado()
                ? () async {
                    await FirebaseProvider().nuevaCita(
                        _emailSesionUsuario,
                        dia,
                        horaInicioTexto,
                        horaFinTexto,
                        '0', // precio
                        textoTitulo, // comentario
                        '999', // idcliente
                        ['indispuesto'], // idServicio
                        'idEmpleado',
                        '' // idCitaCliente
                        );

                    cerrar();
                  }
                : null,
            child: const Center(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            )));
  }
}

////////////// TARJETA DE CREACION DEL ASUNTO /////////////////////////

class TarjetaCreacionAsunto extends StatefulWidget {
  bool? edicion = false;
  String? id;
  TarjetaCreacionAsunto({super.key, this.edicion, this.id = ''});

  @override
  State<TarjetaCreacionAsunto> createState() => _TarjetaCreacionAsuntoState();
}

class _TarjetaCreacionAsuntoState extends State<TarjetaCreacionAsunto> {
  String _emailSesionUsuario = '';
  String? selectedTime; // Variable para almacenar la selección actual
  String? _errorText;
  String textoTitulo = '';
  Map<String, dynamic> asunto = {};
  Map<String, dynamic>? newAsunto;

  final _keyForm = GlobalKey<FormState>();

  final List<String> timeIntervals = [
    "30 m",
    "1 h",
    "1 h 30 m",
    "2 h",
    "2 h 30 m",
    "3 h"
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserEmail();
    if (widget.edicion == true) {
      getAsuntoFB();
    }
  }

  Future<void> _initializeUserEmail() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    setState(() {
      _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    });
  }

  Map<String, dynamic> _createNewAsunto(String titulo, String? selectedTime) {
    final Map<String, int> timeMap = {
      "30 m": 0,
      "1 h": 1,
      "1 h 30 m": 1,
      "2 h": 2,
      "2 h 30 m": 2,
      "3 h": 3
    };

    final Map<String, int> minutesMap = {
      "30 m": 30,
      "1 h": 0,
      "1 h 30 m": 30,
      "2 h": 0,
      "2 h 30 m": 30,
      "3 h": 0
    };

    return {
      'titulo': titulo,
      'horas': timeMap[selectedTime] ?? 0,
      'minutos': minutesMap[selectedTime] ?? 30,
    };
  }

  void _onSubmit() {
    // provider del boton Guardar
    final personalizadoProvider =
        Provider.of<BotonGuardarAgregarNoDisponible>(context, listen: false);
    /*  // Obtén la instancia del ControladorTarjetasAsuntos
    final controladorTarjetasAsuntos =
        Provider.of<ControladorTarjetasAsuntos>(context, listen: false); */

    if (_keyForm.currentState?.validate() ?? false) {
      personalizadoProvider.setBotonGuardar(true); // formulario es visible o no

      newAsunto = _createNewAsunto(textoTitulo, selectedTime);
      FirebaseProvider()
          .nuevoAsuntoIndispuestos(_emailSesionUsuario, newAsunto!);
      mensajeInfo(context, 'Nuevo asunto agregado');
      Navigator.pop(context, true); // Indica que se debe resetear la página
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Form(
            key: _keyForm,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(widget.edicion!
                      ? 'Edita el asunto ${widget.id}'
                      : 'Agrega un horario'),
                  _buildTitleInput(),
                  _buildDropdown(),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    final color = Theme.of(context).primaryColor;
    return TextFormField(
      onChanged: (value) {
        setState(() {
          textoTitulo = value;
        });
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide(width: 2)),
        iconColor: color,
        suffixIconColor: color,
        fillColor: color,
        hoverColor: color,
        prefixIconColor: color,
        focusColor: color,
        hintText: '🏖️ Título',
        errorText: _errorText,
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: selectedTime, // Valor seleccionado
      hint: const Text(
          'Selecciona una duración'), // Texto cuando no hay selección
      items: timeIntervals.map((String time) {
        return DropdownMenuItem<String>(
          value: time,
          child: Text(time),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedTime = newValue; // Actualizar el valor seleccionado
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: _onSubmit,
        child: const Center(
          child: Text(
            'Agregar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void getAsuntoFB() async {
    asunto = await FirebaseProvider()
        .getAsuntoIndispuestoID(_emailSesionUsuario, widget.id!);
    print('99999999999999999999999999999999999999999999999999');
    print(asunto);
  }
}
