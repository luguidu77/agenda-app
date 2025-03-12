//https://www.youtube.com/watch?v=n5SpF7nuVRk
//https://www.youtube.com/watch?v=6sEJBevHrm0

import 'dart:io';

import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/notificacion_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_resumen.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:agendacitas/utils/comunicacion/comunicaciones.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;

class CrearRecordatorio {
  String horaRecordatorio = '';
  // Calcular la hora de recordatorio basada en la configuración
  Future<String> calcularHoraRecordatorio(
      CitaModelFirebase citaElegida, tiempoTextoRecord) async {
    DateTime cita = citaElegida.horaInicio!;

    // Si tiempo a restar es '24:00', resto un día
    if (tiempoTextoRecord[0] == '2') {
      horaRecordatorio = cita.subtract(const Duration(days: 1)).toString();
    } else {
      String tiempoAux =
          '${cita.year}-${cita.month.toString().padLeft(2, '0')}-${cita.day.toString().padLeft(2, '0')} $tiempoTextoRecord';
      DateTime tiempoRecordatorio = DateTime.parse(tiempoAux);

      horaRecordatorio = cita
          .subtract(Duration(
              hours: tiempoRecordatorio.hour,
              minutes: tiempoRecordatorio.minute))
          .toString();
    }

    return horaRecordatorio;
  }

  static Future<void> crearRecordatorioLocalyEnFirebase({
    required CitaModelFirebase citaElegida,
    required String fecha,
    required String precio,
    required List<String> idServicios,
    required String nombreServicio,
    required String horaRecordatorio,
    required NotificacionRecord dataNotificacion,
  }) async {
    // 2. Guardar recordatorio en Firebase
    await FirebaseProvider().creaRecordatorio(
        citaElegida.email!, fecha, citaElegida, precio, idServicios);

    // 3. Verificar si la fecha es posterior a la actual
    DateTime diaRecord = DateTime.parse(horaRecordatorio);
    DateTime ahora = DateTime.now().subtract(const Duration(minutes: 1));

    if (diaRecord.isAfter(ahora)) {
      debugPrint('---------GUARDA RECORDATORIO-------');
      try {
        // 4. Crear notificación local
        await NotificationService().notificacion(
            dataNotificacion.idRecordatorioCita,
            dataNotificacion.title,
            dataNotificacion.body,
            'citapayload',
            horaRecordatorio);
      } catch (e) {
        debugPrint('Error de notificación local: $e');
        // 5. Mostrar diálogo para permisos de segundo plano
        // _mostrarDialogoPermisosSegundoPlano(context);
      }
    }
  }

  static // Mostrar diálogo para permisos de segundo plano
      void _mostrarDialogoPermisosSegundoPlano(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BackgroundPermissionDialog();
      },
    );
    mensajeInfo(context, 'No recordaremos esta cita');
  }
}

class NotificationService {
  List<int> listId = [];
  // generador de numero unico

  // Find the 'current location'

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  notificacion(int id, String? title, String? body, String payload,
      String horaInicio) async {
    DateTime scheduledDateTime = DateTime.parse(horaInicio);

    // Convierte el DateTime a TZDateTime usando la zona local
    tz.TZDateTime scheduledTZDateTime =
        tz.TZDateTime.from(scheduledDateTime, tz.local);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    //Initialization Settings for Android
    //YOUR_APPLICATION_FOLDER_NAME\android\app\src\main\res\drawable\YOUR_APP_ICON.png
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    //Initialization Settings for iOS
    /*     const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    ); */

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      //iOS: initializationSettingsIOS
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      onSelectNotification(response.payload);
    });

    /* Asegúrate de que el canal que usas en AndroidNotificationDetails coincida con el canal que has creado o registrado previamente. 
          Si el canal no existe o no se ha creado correctamente, la notificación podría no mostrarse.*/
    const String channelId = 'high_importance_channel';
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'High Importance Notifications',
      description: "Este canal es para notificaciones importantes",
      importance: Importance.max,
    );

    //!notificaciones con intervalos
    /*  await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'repeating title',
        'repeating body',
        RepeatInterval.everyMinute,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description)),
        androidAllowWhileIdle: true); */

    //!envio notificacion directa
    /*  flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description)),
        payload: payload); */

    /* La diferencia que ves se debe a que el método toString() de tz.TZDateTime muestra la hora en formato UTC (por eso aparece la "Z" al final), 
        y en tu zona horaria (España, que es UTC+1 en horario estándar o UTC+2 en horario de verano) la hora local es una hora (o dos) mayor. Es decir,
         si ves en consola 2025-03-09 15:45:00.000Z, eso representa el mismo instante que 16:45:00 en España (suponiendo que España esté en UTC+1 en ese momento). */

    final localFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    print(
        'Hora local recordatorio (UTC )- ${localFormatter.format(scheduledTZDateTime)}');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDateTime //scheduledDate
          ,
          const NotificationDetails(
              android: AndroidNotificationDetails(
            channelId,
            'High Importance Notifications',
            channelDescription: 'full screen channel description',
            priority: Priority.max,
            importance: Importance.max,
            // fullScreenIntent: true
          )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      // cancelaNotificacion(id);
    } catch (e) {
      print('Error al programar la notificación: $e');
    }
  }

  void onSelectNotification(String? payload) {
    // Aquí puedes manejar la notificación recibida, por ejemplo, mostrar un diálogo

    print(
        'mensaje recibido por notificacion local ------------------------------------ Payload: $payload');
  }

  Future<List<int>> getNotificacionesPendientes() async {
    // comprueba las notificaciones pendientes
    List<PendingNotificationRequest>? pendientes =
        await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.pendingNotificationRequests() ??
            [];
    for (var e in pendientes) {
      listId.add(e.id);
    }
    print(
        '######################  -lista  id pendientes de  notificacion: $listId');

    return listId;
  }

  cancelaNotificacion(id) async {
    // await flutterLocalNotificationsPlugin.cancelAll();

    // cancel the notification with id value
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

void datapayload(data) async {
  print(data);
}

class NotificacionesFirebaseMessaging {
  //### NOTIFICACIONES  DESDE FIREBASE MESSAGING ############################################
  //https://medium.com/@alvarohurtadobo/configurando-firebase-push-notifications-en-flutter-3-3-9e9eed94bbb7
  // NOTIFICACIONES A USUARIOS DE LA APLICACION CON INICIO DE SESION

  // ### NOTIFICACIONES FIREBASE
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPluginMessaging;
  bool isFlutterLocalNotificationsInitialized = false;
  //##############################
  Future<void> setupFlutterNotifications() async {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPluginMessaging =
        FlutterLocalNotificationsPlugin();

    /// Crear un canal de notificación
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPluginMessaging
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    /*  debugPrint('A continuacion los datos que trae la notificacion:');
    print(message.data); */

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null &&
        android != null &&
        (Platform.isAndroid || Platform.isIOS)) {
      flutterLocalNotificationsPluginMessaging.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            importance: Importance.high,
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );
    }
  }

  void guardarToken(String? fcmToken) {}
}
