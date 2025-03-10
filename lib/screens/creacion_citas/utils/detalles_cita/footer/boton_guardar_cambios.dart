import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/models/perfil_usuarioapp_model.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/footer/check.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/footer/widgets_footer.dart';
import 'package:agendacitas/screens/creacion_citas/utils/genera_id_cita_recordatorio.dart';
import 'package:agendacitas/utils/actualizacion_cita.dart';
import 'package:agendacitas/utils/comunicacion/comunicaciones.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BotonGuardarCambios extends StatelessWidget {
  const BotonGuardarCambios({super.key});

  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CreacionCitaProvider>();

    final EmailAdministradorAppProvider emailUsuarioProvider =
        context.read<EmailAdministradorAppProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Alinea el botón a la derecha
      children: [
        WidgetsFooter.boton('Guardar', () {
          if (citaProvider.contextoCita.horaInicio!.isAfter(DateTime.now())) {
            ///TODO PENDIENTE DE MANEJAR EL CONTEXTO DEL PERFIL DEL ADMINISTRADOR PARA EL ENVIO DE EMAILS
            ///SI EL CLIENTE NO TIENE EMAIL TAMPOCO SALDRA ESTA OPCION
            ///SI SE AGREGA EL EMAIL CON LA APP YA INICIADA HABRA QUE AGREGARLO AL CONTEXTO DE CLIENTES
            /* // Visualiza alerta para compartir al cliente
            _alertaActualizar(context, citaProvider,
                emailUsuarioProvider.emailAdministradorApp); */
            _actualiza(context, citaProvider, emailUsuarioProvider);
          } else {
            _actualiza(context, citaProvider, emailUsuarioProvider);
          }
        })
      ],
    );
  }

  static void _alertaActualizar(BuildContext context,
      CreacionCitaProvider citaProvider, String emailAdministrador) async {
    final perfilAdmin = PerfilAdministradorModel(
        denominacion: 'denominacion negocio',
        telefono: 'telefono negocio',
        email: emailAdministrador);

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 10,
                  children: [
                    const Text(
                      'Actualizar cita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CheckCompartir(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificar a ${citaProvider.contextoCita.nombreCliente} del cambio de la cita',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                  softWrap: true,
                                  'Envía un mensaje para informar a  ${citaProvider.contextoCita.nombreCliente} que se ha reprogramado la cita',
                                  style: const TextStyle(fontSize: 9)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        WidgetsFooter.boton('Actualizar', () async {
                          final cita = citaProvider.contextoCita;
                          if (citaProvider.estadoCheck) {
                            print(
                                'enviar notificacion --------------------------');
                            Comunicaciones().compartirCitaEmail(
                                context,
                                perfilAdmin,
                                'Cita preprogramada',
                                cita.nombreCliente!,
                                cita.emailCliente!,
                                DateTime.now().toString(), // cita.dia!,
                                cita.servicios!.map((e) => e).toString(),
                                cita.precio!);
                          }
                          /*  _actualiza(
                              context, citaProvider, emailUsuarioProvider); */
                        }),
                      ],
                    ),
                  ]),
            ),
          );
        });
  }

  static void _actualiza(
      BuildContext context, citaProvider, emailUsuarioProvider) async {
    // actualiza la cita
    final nuevaCitaCreada = await ActualizacionCita.actualizar(
      context,
      citaProvider.contextoCita,
      null,
      citaProvider.contextoCita.dia,
      citaProvider.contextoCita.horaInicio,
      emailUsuarioProvider.emailAdministradorApp,
    );

    // actualiza recordatorio local
    final notifPendientes =
        await NotificationService().getNotificacionesPendientes();

    final idRecordatorio =
        UtilsRecordatorios.idRecordatorio(citaProvider.contextoCita.horaInicio);

    final idRec = notifPendientes.firstWhere((e) => e == idRecordatorio);
    // elimina recordatorio local anterior
    NotificationService().cancelaNotificacion(idRec);
    // cuerpo texto de la notificacion
    final dataNotificacion = await Comunicaciones()
        .textoNotificacionesLocales(context, citaProvider.contextoCita);
    // crea nuevo recordatorio local
    //todo: pasar por la clase formater hora y fecha
    String textoHoraInicio =
        '${DateTime.parse(nuevaCitaCreada.horaInicio.toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(nuevaCitaCreada.horaInicio.toString()).minute.toString().padLeft(2, '0')}';
    NotificationService().notificacion(dataNotificacion.idRecordatorioCita,
        dataNotificacion.title, dataNotificacion.body, '', textoHoraInicio);

    // actualiza recordatorio firebase (coleccion recordatorios)

    // no visible el boton guardar
    citaProvider.setVisibleGuardar(false);
  }
}
