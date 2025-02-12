class ClienteModel {
  var id;
  String? nombre;
  String? telefono;
  String? email;
  String? foto;
  String? nota;

  ClienteModel({
    this.id,
    this.nombre,
    this.telefono,
    this.email,
    this.foto,
    this.nota,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        id: json["id"],
        nombre: json["nombre"],
        telefono: json["telefono"],
        email: json["email"],
        foto: json["foto"],
        nota: json["nota"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "telefono": telefono,
        "email": email,
        "foto": foto,
        "nota": nota,
      };
}

class CitaModel {
  int? id;
  String? dia;
  String? horaInicio;
  String? horaFinal;
  String? comentario;
  var idcliente;
  var idservicio;

  CitaModel({
    this.id,
    this.dia,
    this.horaInicio,
    this.horaFinal,
    this.comentario,
    this.idcliente,
    this.idservicio,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) => CitaModel(
        id: json["id"],
        dia: json["dia"],
        horaInicio: json["horainicio"],
        horaFinal: json["horafinal"],
        comentario: json["comentario"],
        idcliente: json["id_cliente"],
        idservicio: json["id_servicio"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dia": dia,
        "horainicio": horaInicio,
        "horafinal": horaFinal,
        "comentario": comentario,
        "id_cliente": idcliente,
        "id_servicio": idservicio,
      };
}

class CitaModelFirebase {
  var id;
  String? dia;
  DateTime? horaInicio;
  DateTime? horaFinal;
  String? comentario;
  String? email;
  String? idcliente;
  List<dynamic>? idservicio;
  List<String>? servicios;
  String? idEmpleado;
  String? nombreEmpleado;
  int? colorEmpleado;
  String? precio;
  bool? confirmada;
  String? tokenWebCliente;
  String? idCitaCliente;

  // Nuevos campos añadidos
  String? nombreCliente;
  String? fotoCliente;
  String? telefonoCliente;
  String? emailCliente;
  String? notaCliente;

  CitaModelFirebase({
    this.id,
    this.dia,
    this.horaInicio,
    this.horaFinal,
    this.comentario,
    this.email,
    this.idcliente,
    this.idservicio,
    this.servicios,
    this.idEmpleado,
    this.nombreEmpleado,
    this.colorEmpleado,
    this.precio,
    this.confirmada,
    this.tokenWebCliente,
    this.idCitaCliente,
    this.nombreCliente,
    this.fotoCliente,
    this.telefonoCliente,
    this.emailCliente,
    this.notaCliente,
  });

  CitaModelFirebase copyWith({
    var id,
    String? dia,
    DateTime? horaInicio,
    DateTime? horaFinal,
    String? comentario,
    String? email,
    String? idcliente,
    List<dynamic>? idservicio,
    List<String>? servicios,
    String? idEmpleado,
    String? nombreEmpleado,
    int? colorEmpleado,
    String? precio,
    bool? confirmada,
    String? tokenWebCliente,
    String? idCitaCliente,
    String? nombreCliente,
    String? fotoCliente,
    String? telefonoCliente,
    String? emailCliente,
    String? notaCliente,
  }) {
    return CitaModelFirebase(
      id: id ?? this.id,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFinal: horaFinal ?? this.horaFinal,
      comentario: comentario ?? this.comentario,
      email: email ?? this.email,
      idcliente: idcliente ?? this.idcliente,
      idservicio: idservicio ?? this.idservicio,
      servicios: servicios ?? this.servicios,
      idEmpleado: idEmpleado ?? this.idEmpleado,
      nombreEmpleado: nombreEmpleado ?? this.nombreEmpleado,
      colorEmpleado: colorEmpleado ?? this.colorEmpleado,
      precio: precio ?? this.precio,
      confirmada: confirmada ?? this.confirmada,
      tokenWebCliente: tokenWebCliente ?? this.tokenWebCliente,
      idCitaCliente: idCitaCliente ?? this.idCitaCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      fotoCliente: fotoCliente ?? this.fotoCliente,
      telefonoCliente: telefonoCliente ?? this.telefonoCliente,
      emailCliente: emailCliente ?? this.emailCliente,
      notaCliente: notaCliente ?? this.notaCliente,
    );
  }

  void actualizarParcialmente(CitaModelFirebase nuevosDatos) {
    id = nuevosDatos.id ?? id;
    dia = nuevosDatos.dia ?? dia;
    horaInicio = nuevosDatos.horaInicio ?? horaInicio;
    horaFinal = nuevosDatos.horaFinal ?? horaFinal;
    comentario = nuevosDatos.comentario ?? comentario;
    email = nuevosDatos.email ?? email;
    idcliente = nuevosDatos.idcliente ?? idcliente;
    idservicio = nuevosDatos.idservicio ?? idservicio;
    servicios = nuevosDatos.servicios ?? servicios;
    idEmpleado = nuevosDatos.idEmpleado ?? idEmpleado;
    nombreEmpleado = nuevosDatos.nombreEmpleado ?? nombreEmpleado;
    colorEmpleado = nuevosDatos.colorEmpleado ?? colorEmpleado;
    precio = nuevosDatos.precio ?? precio;
    confirmada = nuevosDatos.confirmada ?? confirmada;
    tokenWebCliente = nuevosDatos.tokenWebCliente ?? tokenWebCliente;
    idCitaCliente = nuevosDatos.idCitaCliente ?? idCitaCliente;
    nombreCliente = nuevosDatos.nombreCliente ?? nombreCliente;
    fotoCliente = nuevosDatos.fotoCliente ?? fotoCliente;
    telefonoCliente = nuevosDatos.telefonoCliente ?? telefonoCliente;
    emailCliente = nuevosDatos.emailCliente ?? emailCliente;
    notaCliente = nuevosDatos.notaCliente ?? notaCliente;
  }

  factory CitaModelFirebase.fromJson(Map<String, dynamic> json) =>
      CitaModelFirebase(
        id: json["id"],
        dia: json["dia"],
        horaInicio: json["horaInicio"] != null
            ? DateTime.parse(json["horaInicio"])
            : null,
        horaFinal: json["horaFinal"] != null
            ? DateTime.parse(json["horaFinal"])
            : null,
        comentario: json["comentario"],
        email: json["email"],
        idcliente: json["idCliente"],
        idservicio: json["idServicio"] ?? [],
        servicios: List<String>.from(json["servicios"] ?? []),
        idEmpleado: json["idEmpleado"],
        nombreEmpleado: json["nombreEmpleado"],
        colorEmpleado: json["colorEmpleado"],
        precio: json["precio"],
        confirmada: json["confirmada"],
        tokenWebCliente: json["tokenWebCliente"],
        idCitaCliente: json["idCitaCliente"],
        nombreCliente: json["nombreCliente"],
        fotoCliente: json["fotoCliente"],
        telefonoCliente: json["telefonoCliente"],
        emailCliente: json["emailCliente"],
        notaCliente: json["notaCliente"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dia": dia,
        "horaInicio": horaInicio?.toIso8601String(),
        "horaFinal": horaFinal?.toIso8601String(),
        "comentario": comentario,
        "email": email,
        "idCliente": idcliente,
        "idServicio": idservicio,
        "servicios": servicios,
        "idEmpleado": idEmpleado,
        "nombreEmpleado": nombreEmpleado,
        "colorEmpleado": colorEmpleado,
        "precio": precio,
        "confirmada": confirmada,
        "tokenWebCliente": tokenWebCliente,
        "idCitaCliente": idCitaCliente,
        "nombreCliente": nombreCliente,
        "fotoCliente": fotoCliente,
        "telefonoCliente": telefonoCliente,
        "emailCliente": emailCliente,
        "notaCliente": notaCliente,
      };
}

class ServicioModel {
  var id;
  String? servicio;
  String? tiempo;
  var precio;
  String? detalle;
  String? activo;

  ServicioModel({
    this.id,
    this.servicio,
    this.tiempo,
    this.precio,
    this.detalle,
    this.activo,
  });

  ServicioModel copyWith({
    var id,
    String? servicio,
    String? tiempo,
    var precio,
    String? detalle,
    String? activo,
  }) {
    return ServicioModel(
      id: id ?? this.id,
      servicio: servicio ?? this.servicio,
      tiempo: tiempo ?? this.tiempo,
      precio: precio ?? this.precio,
      detalle: detalle ?? this.detalle,
      activo: activo ?? this.activo,
    );
  }

  factory ServicioModel.fromJson(Map<String, dynamic> json) => ServicioModel(
        id: json["id"],
        servicio: json["servicio"],
        tiempo: json["tiempo"],
        precio: json["precio"],
        detalle: json["detalle"],
        activo: json["activo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "servicio": servicio,
        "tiempo": tiempo,
        "precio": precio,
        "detalle": detalle,
        "activo": activo,
      };
}

class ServicioModelFB {
  var id;
  String? servicio;
  String? tiempo;
  var precio;
  String? detalle;
  String? activo;
  String? idCategoria;
  int? index;

  ServicioModelFB(
      {this.id,
      this.servicio,
      this.tiempo,
      this.precio,
      this.detalle,
      this.activo,
      this.idCategoria,
      this.index});
  ServicioModelFB copyWith({
    var id,
    String? servicio,
    String? tiempo,
    var precio,
    String? detalle,
    String? activo,
    String? idCategoria,
    int? index,
  }) {
    return ServicioModelFB(
      id: id ?? this.id,
      servicio: servicio ?? this.servicio,
      tiempo: tiempo ?? this.tiempo,
      precio: precio ?? this.precio,
      detalle: detalle ?? this.detalle,
      activo: activo ?? this.activo,
      idCategoria: idCategoria ?? this.idCategoria,
      index: index ?? this.index,
    );
  }

  factory ServicioModelFB.fromJson(Map<String, dynamic> json) =>
      ServicioModelFB(
        id: json["id"],
        servicio: json["servicio"],
        tiempo: json["tiempo"],
        precio: json["precio"],
        detalle: json["detalle"],
        activo: json["activo"],
        idCategoria: json["categoria"],
        index: json["index"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "servicio": servicio,
        "tiempo": tiempo,
        "precio": precio,
        "detalle": detalle,
        "activo": activo,
        "categoria": idCategoria,
        "index": index,
      };
}

class CategoriaServicioModel {
  var id;
  String? nombreCategoria;
  String? detalle;

  CategoriaServicioModel({
    this.id,
    this.nombreCategoria,
    this.detalle,
  });

  factory CategoriaServicioModel.fromJson(Map<String, dynamic> json) =>
      CategoriaServicioModel(
        id: json["id"],
        nombreCategoria: json["nombreCategoria"],
        detalle: json["detalle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombreCategoria": nombreCategoria,
        "detalle": detalle,
      };
}
