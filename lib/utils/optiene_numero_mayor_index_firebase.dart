import '../providers/providers.dart';

// ES UNA UTILIDAD QUE TRAE EL NUMERO MAYOR DE TODOS LOS INDEX DE LOS SERVICIOS
Future<int> devuelveIndexMayorServicios(iniciadaSesionUsuario, email) async {
  List listaI = [];
  late int numeroMayor;
  if (iniciadaSesionUsuario) {
    var lista = await FirebaseProvider().cargarServicios(email);

    // SI EL CLIENTE NO TIENE TODAVIA SERVICIOS RETORNA EL 0 COMO MAYOR NUMERO DE INDEX
    if (lista.isEmpty) {
      return 0;
    }

    // SI HAY SERVICIOS, ALGORITMO PARA ENCONTRAR EL DE MAYOR NUMERO INDEX DE LOS SERVICIOS
    for (var element in lista) {
      listaI.add(element.index);
    }
    int nM = listaI.reduce((valorAnterior, valorActual) =>
        valorAnterior > valorActual ? valorAnterior : valorActual);
    numeroMayor = nM;
  }
  return numeroMayor;
}
