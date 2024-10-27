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
  String? horaInicio;
  String? horaFinal;
  String? comentario;
  String? email;
  String? idcliente;
  List<String>? idservicio;
  String? idEmpleado;
  String? nombreEmpleado;
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
    this.idEmpleado,
    this.nombreEmpleado,
    this.precio,
    this.confirmada,
    this.tokenWebCliente,
    this.idCitaCliente,
    // Inicialización de los nuevos campos
    this.nombreCliente,
    this.fotoCliente,
    this.telefonoCliente,
    this.emailCliente,
    this.notaCliente,
  });

  factory CitaModelFirebase.fromJson(Map<String, dynamic> json) =>
      CitaModelFirebase(
          id: json["id"],
          dia: json["dia"],
          horaInicio: json["horaInicio"],
          horaFinal: json["horaFinal"],
          comentario: json["comentario"],
          email: json["email"],
          idcliente: json["idCliente"],
          idservicio: ["idServicio"], // Adaptación de array
          idEmpleado: json["idEmpleado"],
          nombreEmpleado: json["nombreEmpleado"],
          precio: json["precio"],
          confirmada: json["confirmada"],
          tokenWebCliente: json["tokenWebCliente"],
          idCitaCliente: json["idCitaCliente"],
          // Mapeo de los nuevos campos
          nombreCliente: json["nombreCliente"],
          fotoCliente: json["fotoCliente"],
          telefonoCliente: json["telefonoCliente"],
          emailCliente: json["emailCliente"],
          notaCliente: json["notaCliente"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "dia": dia,
        "horaInicio": horaInicio,
        "horaFinal": horaFinal,
        "comentario": comentario,
        "email": email,
        "idCliente": idcliente,
        "idServicio": idservicio,
        "idEmpleado": idEmpleado,
        "nombreEmpleado": nombreEmpleado,
        "precio": precio,
        "confirmada": confirmada,
        "tokenWebCliente": tokenWebCliente,
        "idCitaCliente": idCitaCliente,
        // Nuevos campos añadidos al JSON
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
