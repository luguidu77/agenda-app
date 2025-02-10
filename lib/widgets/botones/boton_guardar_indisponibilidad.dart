import 'package:agendacitas/models/cita_model.dart';

import 'package:agendacitas/providers/citas_provider.dart';

import 'package:agendacitas/providers/providers.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/formatea_fecha_hora.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:agendacitas/utils/verificaDiferenciaHorario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    // provider HORA elegida
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);
    // Verifica el estado del botón antes de construir la interfaz
    botonActivado = Verificadiferenciahorario.verificarBotonActivado(
        providerHoraFinCarrusel);

    // provider del boton Guardar
    final personalizadoProvider =
        context.watch<BotonGuardarAgregarNoDisponible>();
    personalizado =
        personalizadoProvider.forularioVisible; // formulario es visible o no

    print(personalizado);

    final providerTextoTitulo = context.watch<TextoTituloIndispuesto>();
    print({'${providerTextoTitulo.getTitulo}'});
    bool condicionBotonActivado() {
      //  con la variable 'personalizado' verfico si esta la opcion del asunto es personalizado
      // si es personalizado, compruebo con 'botonAtivado' los tramos horarios, y si el formulario está validado
      // si no es personalizado y el fomulario no esta visible, pues retorno la condicion verdadera para activar el boton y realizar el guardado.
      if (botonActivado && providerTextoTitulo.getTitulo != ''
          /*  _formKey.currentState != null &&
            _formKey.currentState!.validate() &&
            _errorText == null */
          ) {
        return true;
      } else {
        return false;
      }
    }

    void cerrar() {
      personalizadoProvider.setBotonGuardar(true); // formulario es visible o no

      Navigator.pop(context);
      // setState(() {});
    }

    // provider contexto de la cita para obtener el id del empleado
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    final idEmpleado = contextoCreacionCita.contextoCita.idEmpleado;
    final nombreEmpleado = contextoCreacionCita.contextoCita.nombreEmpleado;
    final contextoCitas = context.read<CitasProvider>();

    // escucha el provider del titulo del asunto

    textoTitulo = '$nombreEmpleado  ${providerTextoTitulo.getTitulo}';

    // provider FECHA elegida
    final providerFechaElegida = Provider.of<FechaElegida>(context);
    fechaElegida = providerFechaElegida.fechaElegida;
    dia = formatearFechaDiaCita(fechaElegida!);

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
                    final citaEdicion = CitaModelFirebase(
                        dia: dia,
                        horaInicio: horaInicio,
                        horaFinal: horaFin,
                        comentario: textoTitulo,
                        idcliente: '999',
                        idEmpleado: idEmpleado,
                        idCitaCliente: '');
                    //guardar la cita en firebase
                    String idCitaFB = await FirebaseProvider().nuevaCita(
                        _emailSesionUsuario,
                        citaEdicion,
                        ['indispuesto'],
                        citaEdicion.idCitaCliente!);

                    //agrear la cita al contexto de las citas
                    citaEdicion.id = idCitaFB;
                    citaEdicion.idservicio = ['indispuesto'];
                    citaEdicion.colorEmpleado = 4278190335;
                    contextoCreacionCita.contextoCita.confirmada = true;
                    citaEdicion.comentario = textoTitulo;
                    citaEdicion.nombreCliente = '';

                    contextoCitas.agregaCitaAlContexto(citaEdicion);

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
