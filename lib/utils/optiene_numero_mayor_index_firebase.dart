import '../providers/providers.dart';

// ES UNA UTILIDAD QUE TRAE EL NUMERO MAYOR DE TODOS LOS INDEX DE LOS SERVICIOS
Future<int> devuelveIndexMayorServicios(
    iniciadaSesionUsuario, email, indexCategoriaElegida) async {
  List listaI = [];
  late int numeroMayor;
  if (iniciadaSesionUsuario) {
    var lista = await FirebaseProvider().cargarServicios(email);

    // SI EL CLIENTE NO TIENE TODAVIA SERVICIOS RETORNA EL 0 COMO MAYOR NUMERO DE INDEX
    if (lista.isEmpty) {
      return 0;
    }
    int numeroMinimo = 0;
    int numeroMaximo = 0;
    int numeroAcotado = 0;
    int num = 0;
    // SI HAY SERVICIOS, ALGORITMO PARA ENCONTRAR EL DE MAYOR NUMERO INDEX DE LOS SERVICIOS

    // EL RESULTADO ANTERIOR LO ACOTO ENTRE DOS NUMEROS ( EJ: ENTRE 0 Y 99 SI FUERA LA CATEGORIA INDEX 0)
    numeroMinimo = indexCategoriaElegida * 100;
    numeroMaximo = (indexCategoriaElegida * 100) + 99;

    for (var element in lista) {
      // indexCategoriaElegida = 0   -->   0-99
      // indexCategoriaElegida = 1  -->   100-199

      num = element.index;
      numeroAcotado = num.clamp(numeroMinimo, numeroMaximo);

      if (numeroAcotado == numeroMinimo || numeroAcotado == numeroMaximo) {
        // No devolver el valor máximo, puedes tomar alguna acción o asignar otro valor
        // por ejemplo, asignar un valor predeterminado o lanzar una excepción.
        numeroAcotado = 0; // Asignar un valor predeterminado
      }
      listaI.add(numeroAcotado);
    }

    // COMPRUEVO EL MAYOR VALOR DE LA LISTA
    int nM = listaI.reduce((valorAnterior, valorActual) =>
        valorAnterior > valorActual ? valorAnterior : valorActual);

    numeroMayor = nM;
  }
  return numeroMayor;
}
