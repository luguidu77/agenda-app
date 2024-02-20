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
  String? idcliente;
  String? idservicio;
  String? idEmpleado;
  double? precio;
  String? confirmada;
  String? tokenWebCliente;
  String? idCitaCliente;

  CitaModelFirebase({
    this.id,
    this.dia,
    this.horaInicio,
    this.horaFinal,
    this.comentario,
    this.idcliente,
    this.idservicio,
    this.idEmpleado,
    this.precio,
    this.confirmada,
    this.tokenWebCliente,
    this.idCitaCliente,
  });

  factory CitaModelFirebase.fromJson(Map<String, dynamic> json) =>
      CitaModelFirebase(
          id: json["id"],
          dia: json["dia"],
          horaInicio: json["horainicio"],
          horaFinal: json["horafinal"],
          comentario: json["comentario"],
          idcliente: json["id_cliente"],
          idservicio: json["id_servicio"],
          idEmpleado: json["id_empleado"],
          precio: json["precio"],
          confirmada: json["confirmada"],
          tokenWebCliente: json["tokenWebCliente"],
          idCitaCliente: json["idCitaCliente"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "dia": dia,
        "horainicio": horaInicio,
        "horafinal": horaFinal,
        "comentario": comentario,
        "id_cliente": idcliente,
        "id_servicio": idservicio,
        "id_empleado": idEmpleado,
        "precio": precio,
        "confirmada": confirmada,
        "tokenWebCliente": tokenWebCliente,
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
