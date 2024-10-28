import 'package:agendacitas/providers/Firebase/firebase_provider.dart';

List<String> extraerIdServiciosdeCadenaTexto(texto) {
  String idServicioString = texto; //"[palabra,palabra2]"

// Elimina los corchetes y divide el texto por comas
  List<String> idServicioList =
      idServicioString.replaceAll(RegExp(r'[\[\]\s]'), '').split(',');

  print(idServicioList); // Salida: ["palabra", "palabra2"]

  return idServicioList;
}

List<String> extraerDenominacionServiciosdeCadenaTexto(texto) {
  // La cadena de texto que representa la lista de objetos JSON
  String jsonString = texto;
  // "idServicio": "[{idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semipermanente con refuerzo, detalle: , precio: 20, tiempo: 01:00}, {idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semipermanente con ...

// Expresión regular para encontrar los valores de la clave "servicio"
// Asegura que solo se capturen los valores de "servicio" y no de "idServicio" u otras claves similares
  RegExp regExp = RegExp(r'(?<!id)servicio:\s*([^,}]+)', caseSensitive: false);
  //caseSensitive: false (incluye tildes)

// Encuentra todos los valores de idServicio en la cadena JSON
  Iterable<Match> matches = regExp.allMatches(jsonString);

// Lista para almacenar los valores de idServicio
  List<String> idServicioValues = [];

// Itera sobre los resultados y agrega los valores a la lista
  for (Match match in matches) {
    idServicioValues.add(match.group(1)!);
  }

  return idServicioValues;
}

//Creo lista de nombre de servicios a partir de una lista de id de servicios
Future<List<String>> convierteListaIDaNombres(emailNegocio, idServicios) async {
  List<String> servicios = [];
  for (var id in idServicios) {
    var servicio =
        await FirebaseProvider().cargarServicioPorId(emailNegocio, id);

    servicios.add(servicio['servicio']);
  }

  return servicios;
}
