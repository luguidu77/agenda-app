import 'package:agendacitas/models/models.dart';

adaptacionPerfilNegocio(PerfilAdministradorModel perfilNegocio) {
  NegocioModel negocio = NegocioModel(
      id: perfilNegocio.id!, // ID DEL NEGOCIO QUE TIENE EN LA WEB
      denominacion: perfilNegocio.denominacion!,
      direccion: perfilNegocio.ubicacion!,
      ubicacion: '',
      email: perfilNegocio.email!,
      telefono: perfilNegocio.telefono!,
      imagen: perfilNegocio.foto!,
      moneda: 'perfilNegocio.moneda!',
      latitud: 0,
      longitud: 0,
      valoracion: '',
      categoria: '',
      servicios: '',
      tokenMessaging: '',
      descripcion: '',
      facebook: '',
      instagram: '',
      horarios: '',
      destacado: false,
      publicado: true,
      blog: {});

  return negocio;
}
