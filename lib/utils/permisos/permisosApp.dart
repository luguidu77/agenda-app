import 'package:permission_handler/permission_handler.dart';

class Autorizaciones {
  permisoSMS() async {
    if (await Permission.sms.request().isGranted) {
      print("permiso acceso sms");
      // Either the permission was already granted before or the user just granted it.
    }
  }

  statusPermisoSMS() async {
    var statusPermisos = await Permission.sms.status;
    return statusPermisos;
  }
}
