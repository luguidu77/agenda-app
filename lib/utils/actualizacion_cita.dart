import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/genera_id_cita_recordatorio.dart';

import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:agendacitas/utils/notificaciones/recordatorio_local/recordatorio_local.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActualizacionCita {
  static agregar(BuildContext context, CitaModelFirebase citaElegida) {
    citaElegida.confirmada = true;
    final contextoCitaProvider = context.read<CitasProvider>();

    Future.microtask(() {
      contextoCitaProvider.agregaCitaAlContexto(citaElegida);
    });
  }

  static Future<CitaModelFirebase> actualizar(
      BuildContext context,
      CitaModelFirebase cita,
      DateTime?
          fechaDroppintTime, // fecha del calendario cuando se arrastra tarjeta
      String?
          fechaFormulario, // fecha del formulario reasignar de la pantalla detalles cita
      DateTime? horaInicioProgramable, // formulario reasignar

      emailSesionUsuario,
      dataNotificacion) async {
    final contextoCitas = context.read<CitasProvider>();
    int idRecordatorioLocal =
        await UtilsRecordatorios.idRecordatorio(cita.horaInicio!);
    final personalizaProvider = context.read<PersonalizaProviderFirebase>();
    final personaliza = personalizaProvider.getPersonaliza;
    String? textoFecha;
    String? textoFechaHoraInicio;
    String? textoFechaHoraFinal;
    DateTime? nuevaHoraDateTime;

    List<int> calculaTiempo(timestamp1, timestamp2) {
      DateTime dateTime1 = (timestamp1);
      DateTime dateTime2 = (timestamp2);
      Duration difference = dateTime2.difference(dateTime1);

      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;
      return [hours, minutes];
    }

    // OBTENER LA DIFERENCIA ENTRE LA HORA DE INICIO Y LA FINAL PARA CONOCER EL TIEMPO DE LA CITA
    List<int> tiempoServicios = calculaTiempo(cita.horaInicio, cita.horaFinal);

    // DIFERENCIO SI LOS DATOS LLEGAN DE ARRASTRAR TARJETA DEL CALENDARIO O DEL FORMULARIO DETALLES CITA
    if (fechaDroppintTime != null) {
      nuevaHoraDateTime = fechaDroppintTime;

      textoFecha =
          '${nuevaHoraDateTime.year}-${nuevaHoraDateTime.month.toString().padLeft(2, '0')}-${nuevaHoraDateTime.day.toString().padLeft(2, '0')}';
    } else {
      nuevaHoraDateTime = horaInicioProgramable;

      textoFecha = fechaFormulario;
    }

    textoFechaHoraInicio =
        ('$textoFecha ${nuevaHoraDateTime!.hour.toString().padLeft(2, '0')}:${nuevaHoraDateTime.minute.toString().padLeft(2, '0')}:00Z');
    // a la hora final le sumo el tiempoServicios
    textoFechaHoraFinal =
        ('$textoFecha ${(nuevaHoraDateTime.hour + tiempoServicios[0]).toString().padLeft(2, '0')}:${(nuevaHoraDateTime.minute + tiempoServicios[1]).toString().padLeft(2, '0')}:00Z');

    debugPrint(cita.toString()); // print cita

    //? la funcion extraerServicios, resuelve el problema de que el json no tiene comillas en sus claves: [{idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semiperman

    /*    if (cita.idservicio != null) {
      idServicios = extraerIdServiciosdeCadenaTexto(cita.idservicio);

      
    } */

    //quitar espacios en blanco de los servicios
    List<dynamic> idServicios =
        cita.idservicio!.map((e) => e.toString().trim()).toList();

    // si la funcion anterior trae una lista vacía, quiere decir que no hay servicios y por lo tanto sera una tarjeta de No DISPONIBLE
    /* if (idServicios.isEmpty) {
      idServicios = ['indispuesto'];
    } */

    CitaModelFirebase newCita = CitaModelFirebase();

    newCita.email = cita.email;
    newCita.id = cita.id;
    newCita.dia = textoFecha;
    newCita.horaInicio = nuevaHoraDateTime;
    newCita.horaFinal = DateTime.parse(textoFechaHoraFinal);
    newCita.comentario =
        cita.comentario!; //todo añadir un nuevo campo REPROGRAMACION
    newCita.idcliente = cita.idcliente;
    newCita.idservicio = idServicios;

    newCita.idEmpleado = cita.idEmpleado;
    newCita.confirmada = cita.confirmada;

    newCita.idCitaCliente = cita.idCitaCliente;
    newCita.tokenWebCliente = cita.tokenWebCliente;
    newCita.idRecordatorioLocal = idRecordatorioLocal;
    debugPrint('$textoFecha  $textoFechaHoraInicio $textoFechaHoraFinal');

    // Establece las citas en el contexto, eliminando la antigua y agregandola modificada
    // Asegúrate de que no intente notificar al Provider durante el proceso de construcción. Puedes usar Future.microtask para diferir la notificación:
    Future.microtask(() {
      contextoCitas.eliminacitaAlContexto(cita.id);
      contextoCitas.agregaCitaAlContexto(newCita);
    });

    //* ACUTALIZA LAS BASE DE DATOS DE agandadecitaspp y clienteAgendoWeb
    await FirebaseProvider().actualizarCita(emailSesionUsuario, newCita);

    // CREA NUEVO RECORDATORIO LOCAL
    //  Generar fecha formateada para guardar
    DateTime dateTime = newCita.horaInicio!;
    String fechaYMD =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    // Obtener tiempo de recordatorio configurado

    final horaRecordatorio = await CrearRecordatorio().calcularHoraRecordatorio(
      newCita,
      personaliza.tiempoRecordatorio!,
    );

    await CrearRecordatorio.crearRecordatorioLocalyEnFirebase(
      citaElegida: newCita,
      fecha: fechaYMD,
      precio: cita.precio!,
      idServicios: newCita.idservicio! as List<String>,
      nombreServicio: cita.servicios!.first,
      dataNotificacion: dataNotificacion,
      horaRecordatorio: horaRecordatorio,
    );

    // si es una tarjeta indisponibilidad, no actualiza clienteAgendoWeb
    /*  if (idServicios != ['indispuesto']) {
      await FirebaseProvider().actualizaCitareasignada(
          emailSesionUsuario, newCita); // cliente Agendo Web
    } */

    return newCita;
  }
}
