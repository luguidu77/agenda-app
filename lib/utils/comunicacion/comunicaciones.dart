import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';

class Comunicaciones {
  static void hacerLlamadaTelefonica(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void enviarEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static enviaEmailConAsunto(String subject) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'agendadecitaspro@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': subject,
      }),
    );

    await launchUrl(emailLaunchUri);
  }

  String textoCompartir(PerfilAdministradorModel perfilUsuarioApp,
      String textoActual, String clienta, String fecha, String servicio) {
    //EL MENSAJE CAMBIA SI HAY INICIADO UN USUARIO DE APP
    if (perfilUsuarioApp.denominacion != '') {
      RegExp regExp = RegExp(
          r'\$(\w+)'); // Expresión regular para buscar palabras que comienzan con $
      String resultado = textoActual.replaceAllMapped(regExp, (match) {
        // match.group(1) contiene el texto después del $
        String variable = match.group(1)!;
        // Aquí puedes mapear las variables a sus valores
        switch (variable) {
          case 'denominacion':
            return perfilUsuarioApp.denominacion!;
          case 'telefono':
            return perfilUsuarioApp.telefono!;
          case 'web':
            return perfilUsuarioApp.website!;
          case 'facebook':
            return perfilUsuarioApp.facebook!;
          case 'instagram':
            return perfilUsuarioApp.instagram!;
          case 'ubicacion':
            return perfilUsuarioApp.ubicacion!;

          case 'cliente':
            return clienta;
          case 'fecha':
            return fecha;
          case 'servicio':
            return servicio;

          case 'salto':
            return '\n';
          default:
            '';
        }

        if (variable == 'clienta') {
          return clienta;
        } else {
          return ''; // Si no encuentras una variable, puedes dejarla en blanco o manejarla como desees
        }
      });

      String textoResultado = resultado.replaceAll('%', '\n');
      return textoResultado;
/* 
      Hola $cliente,%su cita ha sido reservada con $denominacion para el día $fecha h.%Servicio a realizar : $servicio.%%Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.%%Telefono: $telefono%Web: $web%Facebook: $facebook%Instagram: $instagram%Dónde estamos: $ubicacion%;  */
    } else {
      return 'Hola $clienta,\n'
          'su cita ha sido reservada para el día $fecha h.\n'
          'Servicio a realizar : $servicio.\n\n'
          'Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.';
    }
  }

  void compartirCitaWhatsapp(
    PerfilAdministradorModel perfilUsuarioApp,
    String textoActual,
    String clienta,
    String telefono,
    String fecha,
    String servicio,
  ) async {
    print(
        'compartir =============================================================');
    //print(textoActual);

    String? fechaLarga;
    DateTime resFecha =
        DateTime.parse(fecha); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));

    String telef = '+$telefono';

    String texto = textoCompartir(
        perfilUsuarioApp, textoActual, clienta, fechaLarga, servicio);

    final url = Uri.parse('whatsapp://send?phone=$telef&text=$texto');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void compartirCitaEmail(
      context,
      PerfilAdministradorModel perfilUsuarioApp,
      String textoActual,
      String clienta,
      String email,
      String fecha,
      String servicio,
      String precio) async {
    //***           ENVIOS EMAIL AUTOMATICOS SERVICIO FIREBASE ******************************** */
    PerfilAdministradorModel negocio = PerfilAdministradorModel(
        denominacion: perfilUsuarioApp.denominacion,
        telefono: perfilUsuarioApp.telefono);
    // Convertir el texto en una lista de textos
    List<String> textListServicio = servicio.split(', ');

    CitaModelFirebase cita = CitaModelFirebase(
        horaInicio: DateTime.parse(fecha),
        email: email,
        idservicio: textListServicio,
        precio: precio);

    await emailEstadoCita('Cita confirmada', cita, perfilUsuarioApp.email)
        .then((mailId) {
      Future.delayed(const Duration(seconds: 10), () async {
        dynamic statusEnvio = await comprueStatusEmail(mailId);
        switch (statusEnvio) {
          case 'SUCCESS':
            mensajeInfo(context, 'Email enviado');

          default:
            mensajeError(context, 'No se ha entregado el email');
        }
      });
    });

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ */

    //** ********** ENVIOS MANUALES *********************************************************** */

    /*
        String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    string text= textoCompartir(perfilUsuarioApp, textoActual, clienta, fecha, servicio);
      final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': texto,
      }),
    );

    await launchUrl(emailLaunchUri); */
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ */
  }

  void compartirCitaSms(
      PerfilAdministradorModel perfilUsuarioApp,
      String textoActual,
      String clienta,
      String telefono,
      String fecha,
      String servicio) async {
    String? fechaLarga;
    DateTime resFecha =
        DateTime.parse(fecha); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));

    String texto = textoCompartir(
        perfilUsuarioApp, textoActual, clienta, fechaLarga, servicio);
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: telefono,
      queryParameters: <String, String>{
        'body': texto,
      },
    );

    await launchUrl(smsLaunchUri);
  }
}
