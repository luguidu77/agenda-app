//https://www.youtube.com/watch?v=n5SpF7nuVRk
//https://www.youtube.com/watch?v=6sEJBevHrm0

import 'dart:io';

import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  List<int> listId = [];
  // generador de numero unico

  // Find the 'current location'

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  notificacion(int id, String? title, String? body, String payload,
      String horaInicio) async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    // comprueba las notificaciones pendientes
    List<PendingNotificationRequest>? pendientes =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.pendingNotificationRequests() as List<PendingNotificationRequest>;

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
        onDidReceiveBackgroundNotificationResponse: datapayload);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'hihg_channel', 'High Importance Notification',
        description: "this channel is for important notification",
        importance: Importance.max);

    //initialize timezone package here
    tz.initializeTimeZones();
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    final location = tz.getLocation(currentTimeZone); //'Europe/Madrid'



    // VERIFICA LOS ID DE LAS VERIFICACIONES PENDIENTES Y LE SUMA 1

    await visualizaNotificaciones(pendientes);

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

    //!envio hora concreta
    String fecha = horaInicio.split(' ').first;
    String hora = horaInicio.split(' ').last;

    int year = int.parse(fecha.split('-')[0]);
    int month = int.parse(fecha.split('-')[1]);
    int day = int.parse(fecha.split('-')[2]);
    int hour = int.parse(hora.split(':')[0]);
    int minute = int.parse(hora.split(':')[1]);
    // print('$year,  $month , $day,  $hour, $minute');
    // print(horaInicio);
    //TZDateTime(location, 2022, 8, 14, 21, 30, 0, 0, 0),
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime(location, year, month, day, hour, minute, 0, 0, 0),
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description)),
        //androidAllowWhileIdle: true,

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    print(pendientes.map((e) {
      return print('''
   id: ${e.id}
   title:  ${e.title}
   body: ${e.body}
   payload:  ${e.payload}
   

 ''');
    }));
  }

  void onSelectNotification( String? payload)  {
    // Aquí puedes manejar la notificación recibida, por ejemplo, mostrar un diálogo
     print('mensaje recibido por notificacion local ------------------------------------ Payload: $payload' );
   
  }

  visualizaNotificaciones(List<PendingNotificationRequest> pendientes) async {
    for (var e in pendientes) {
      listId.add((e.id));
    }
    print('######################  -lista id notificacion: $listId');
  }

  cancelaNotificacion(id) async {
    //await flutterLocalNotificationsPlugin.cancelAll();

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
