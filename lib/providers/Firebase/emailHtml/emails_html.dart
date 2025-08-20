import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/utils/formatear.dart';

String formatearFecha(String fechaOriginal) {
  return formateaFechaLarga(fechaOriginal);
}

String formatearHora(String horaOriginal) {
  // Parsear la cadena en un objeto DateTime
  DateTime dateTime = DateTime.parse(horaOriginal);

  // Obtener la hora y los minutos
  int hora = dateTime.hour;
  int minutos = dateTime.minute;

  // Formatear la hora en el formato deseado
  return "$hora:${minutos.toString().padLeft(2, '0')}";
}

String textoHTML(String estadoCita, PerfilAdministradorModel negocio,
    CitaModelFirebase cita) {
  String negocioNombre = negocio.denominacion!;
  String negocioDireccion = '${negocio.ubicacion} '; /* - ${negocio.ciudad} */
  String fechaCita = formatearFecha(cita.horaInicio.toString());
  // formatearHora(cita.horaFinal.toString());
  String precioTotal = cita.precio.toString();
  String moneda = negocio.moneda.toString();

  // Crear una cadena de texto HTML con los elementos de la lista en columna
  String htmlServicios = "<div>";
  for (String item in cita.idservicio!) {
    htmlServicios += "<p>$item</p>";
  }
  htmlServicios += "</div>";

  return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estado de Cita</title>
    <style>
        /* Estilos compatibles con email */
        body {
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            font-family: Arial, sans-serif;
            color: #333333;
        }

        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .header {
            background-color: #6C5CE7;
            padding: 30px;
            text-align: center;
        }

        .brand {
            display: inline-block;
            background-color: #ffffff;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .brand img {
            display: block;
            width: 50px;
            height: auto;
            margin: 0 auto;
        }

        .brand-name {
            color: #6C5CE7;
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
        }

        .content {
            padding: 30px;
        }

        .status-badge {
            background-color: #00B894;
            color: #ffffff;
            padding: 12px 20px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: bold;
            text-align: center;
            margin: -40px auto 20px;
            width: fit-content;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .detail-card {
            margin-bottom: 20px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }

        .detail-label {
            color: #6C5CE7;
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .detail-value {
            font-size: 16px;
            color: #333333;
        }

        .service-list {
            margin: 20px 0;
        }

        .service-item {
            padding: 10px 0;
            border-bottom: 1px solid #eeeeee;
        }

        .service-item:last-child {
            border-bottom: none;
        }

        .action-button {
            display: block;
            width: 100%;
            padding: 15px;
            background-color: #6C5CE7;
            color: #ffffff;
            text-align: center;
            text-decoration: none;
            font-size: 16px;
            font-weight: bold;
            border-radius: 8px;
            margin-top: 20px;
        }

        .footer {
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            font-size: 12px;
            color: #666666;
        }

        @media only screen and (max-width: 600px) {
            .email-container {
                border-radius: 0;
            }
            
            .header {
                padding: 20px;
            }
            
            .content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header -->
        <div class="header">
            <div class="brand">
                <img src="https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/icon.png?alt=media&token=07e36df3-760d-4d29-8c2e-699dae181ad1" 
                     alt="Logo"
                     width="50">
                <div class="brand-name">Agenda de Citas</div>
            </div>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="status-badge">
                $estadoCita
            </div>

            <div class="detail-card">
                <div class="detail-label">Negocio</div>
                <div class="detail-value">
                    <a href="http://agendadecitas.online" style="color: #6C5CE7; text-decoration: none;">$negocioNombre</a>
                </div>
                <div class="detail-value">$negocioDireccion</div>
            </div>

           <div class="detail-card">
                <div class="detail-label">Fecha y Hora</div>
                <div class="detail-value">$fechaCita</div>
            </div>

            <div class="detail-card">
                <div class="detail-label">Servicios</div>
                <div class="service-list">
                    $htmlServicios
                </div>
            </div>

           

            <div class="detail-card">
                <div class="detail-label">Precio Total</div>
                <div class="detail-value">$precioTotal $moneda</div>
            </div>

            <a href="http://agendadecitas.online/citas" class="action-button">
                Gestionar mis citas
            </a>
        </div>

        <!-- Footer -->
        <div class="footer">
            © 2024 Agenda de Citas Online. Todos los derechos reservados.
        </div>
    </div>
</body>
</html>''';
}

String textoHTMLInvitacion(
    //https://agendadecitas.online/#/invitacion?id=1WosONwUBRqYDSc2JtYk&foto=https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/agendadecitas%2Fadriananoemi067%40gmail.com%2Fclientes%2F%2B549116434-1681%2Ffoto?alt=media&token=babab7ff-4465-4728-b666-8ef8c82be410&name=Mario&email=hello@gmail.es&idNegocio=luguidu@hotmail.com&nombreNegocio=Agencia%20de%20Servicios
    PerfilAdministradorModel negocio,
    EmpleadoModel empleado) {
  String emailNegocio = negocio.email!;
  String negocioNombre = negocio.denominacion!;
  String idEmpleado = empleado.id;
  String nombreEmpleado = empleado.nombre;
  String emailEmpleado = empleado.email;
  String fotoEmpleado = empleado.foto;
  String telefonoEmpleado = empleado.telefono;

  return '''<!DOCTYPE html>
<html lang="en" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
  <title>Invitación a unirte</title>
  <meta charset="UTF-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
  <!--[if mso]>
  <xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch><o:AllowPNG/></o:OfficeDocumentSettings></xml>
  <![endif]-->
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600" rel="stylesheet" type="text/css"/>
  <style>
    * {
      box-sizing: border-box;
    }
    body {
      margin: 0;
      padding: 0;
      font-family: 'Montserrat', sans-serif;
      background-color: #f7f7f7;
      color: #333;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background: #fff;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .header {
      background-color: #4caf50;
      color: #fff;
      text-align: center;
      padding: 20px;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
    }
    .content {
      padding: 20px;
      font-size: 16px;
      line-height: 1.5;
    }
    .content p {
      margin: 0 0 20px;
    }
    .footer {
      background-color: #f1f1f1;
      text-align: center;
      padding: 10px;
      font-size: 12px;
      color: #888;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>¡Te han enviado una invitación!</h1>
    </div>
    <div class="content">
      <p>Hola, <strong>$nombreEmpleado</strong>:</p>
      <p>Has recibido una invitación para unirte a <strong>$negocioNombre</strong> en <em>Agenda de citas</em>.</p>
     
    </div>
    <div class="button-container">
  <a href="https://agendadecitas.online/#/invitacion?id=$idEmpleado&foto=$fotoEmpleado&name=$nombreEmpleado&email=$emailEmpleado&telefono=$telefonoEmpleado&idNegocio=$emailNegocio&nombreNegocio=$nombreEmpleado" target="_blank">Aceptar invitación</a>
</div>
<br><br><br>
    <div class="footer">
      © {current_year} Agenda de citas. Todos los derechos reservados.
    </div>
  </div>
</body>
</html>
 ''';
}
