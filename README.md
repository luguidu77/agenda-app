# agendacitas

# como duplicar un proyector para hacer una copia de respaldo
https://docs.github.com/es/repositories/creating-and-managing-repositories/duplicating-a-repository

# obtener sha-1
sha-1 : ir a carpeta android\ y ejecutar .\gradlew signingReport --warning-mode all


## DESPLEGAR EN PLAY STORE :

- flutter clean
- CAMBIAR Version EN Android/app/build.gradle ingrementa versionCode y versionName
- version base de datos DB Provider.
- quitar PAGADO DEL home.dart -->> PagoProvider().guardaPagado(true);
- comprobar pago STRIPE en PRODUCTION google_pay_payment_profile.json y variables en wallet/ tarjetaPago.dart
- flutter build appbundle
- C:\ProyectosFutter\agenda3\build\app\outputs\bundle\release

## Mi widget Boton FloatingActionButonWidget

FloatingActionButonWidget(
icono: const Icon(Icons.add),
texto: 'Cita',
funcion: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => ClientaStep(
clienteParametro:
ClienteModel(nombre: '', telefono: '', email: ''))),
);
},
),

## SOLUCION DE ERRORES al construir el Bundle: C:\Users\ritag\Documents\proyeto trabajo\proyectos flutter\gradle.docx
  # limpieza gradle y cache
     gradle clean, gradle --stop


