//https://www.youtube.com/watch?v=n5SpF7nuVRk
//https://www.youtube.com/watch?v=6sEJBevHrm0

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  List<dynamic> listId = [];
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

    // comprueba las notificaciones pendientes
    List<PendingNotificationRequest>? pendientes =
        await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.pendingNotificationRequests() ??
            [];

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

      await visualizaNotificaciones(pendientes);
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

  visualizaNotificaciones(List<PendingNotificationRequest> pendientes) async {
    for (var e in pendientes) {
      listId.add(('${e.id}  -  ${e.title}    -  ${e.payload}'));
    }
    print(
        '######################  -lista  id pendientes de  notificacion: $listId');
  }

  cancelaNotificacion(id) async {
    // await flutterLocalNotificationsPlugin.cancelAll();

    // cancel the notification with id value
    // await flutterLocalNotificationsPlugin.cancel(id);
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
