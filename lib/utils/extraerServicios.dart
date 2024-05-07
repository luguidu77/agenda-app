
List<String >extraerServicios( texto){
         // La cadena de texto que representa la lista de objetos JSON
          String jsonString = texto;
          // "idServicio": "[{idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semipermanente con refuerzo, detalle: , precio: 20, tiempo: 01:00}, {idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semipermanente con ...

// Expresión regular para encontrar los valores de la clave idServicio
          RegExp regExp = RegExp(r'idServicio:\s*([\w-]+)');

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