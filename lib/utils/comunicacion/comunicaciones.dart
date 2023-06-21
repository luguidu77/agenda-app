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

  String textoCompartir(PerfilModel perfilUsuarioApp, String clienta,
      String fecha, String servicio) {
    //EL MENSAJE CAMBIA SI HAY INICIADO UN USUARIO DE APP
    if (perfilUsuarioApp.denominacion != '') {
      return 'Hola $clienta,\n'
          'su cita ha sido reservada con ${perfilUsuarioApp.denominacion} para el día $fecha h.\n'
          'Servicio a realizar : $servicio.\n\n'
          'Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.\n\n'
          'Telefono: ${perfilUsuarioApp.telefono}\n'
          'Web: ${perfilUsuarioApp.website}\n'
          'Facebook: ${perfilUsuarioApp.facebook}\n'
          'Instagram: ${perfilUsuarioApp.instagram}\n'
          'Dónde estamos: ${perfilUsuarioApp.ubicacion}\n';
    } else {
      return 'Hola $clienta,\n'
          'su cita ha sido reservada para el día $fecha h.\n'
          'Servicio a realizar : $servicio.\n\n'
          'Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.';
    }
  }

  void compartirCitaWhatsapp(PerfilModel perfilUsuarioApp, String clienta,
      String telefono, String fecha, String servicio) async {
    String telef = '+$telefono';

    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);

    final url = Uri.parse('whatsapp://send?phone=$telef&text=$texto');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void compartirCitaEmail(PerfilModel perfilUsuarioApp, String clienta,
      String email, String fecha, String servicio) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': texto,
      }),
    );

    await launchUrl(emailLaunchUri);
  }

  void compartirCitaSms(PerfilModel perfilUsuarioApp, String clienta,
      String telefono, String fecha, String servicio) async {
    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);
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
