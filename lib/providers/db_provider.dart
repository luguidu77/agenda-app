import 'dart:async';
import 'dart:io';

import 'package:agendacitas/models/pago_model.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/models/plan_amigo_model.dart';
import 'package:agendacitas/models/recordatorio_model.dart';
import 'package:agendacitas/models/tema_model.dart';
import 'package:agendacitas/models/tiempo_record_model.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:agendacitas/models/cita_model.dart';
export 'package:agendacitas/models/cita_model.dart';

// inicializar SQFLITE
//https://stackoverflow.com/questions/67049107/the-non-nullable-variable-database-must-be-initialized

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join('${directory.path}/agendacitas.db');
    WidgetsFlutterBinding.ensureInitialized();

    //crear base de datos
    return await openDatabase(path, version: 8, onOpen: (db) {},
        onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (Database db, int version) async {
      await db.execute('''
         CREATE TABLE Cita(
           id INTEGER PRIMARY KEY,
           dia TEXT,
           horainicio TEXT,
           horafinal TEXT,
           comentario TEXT,
           id_cliente INTEGER,
           id_servicio INTEGER
          )         
        ''');
      await db.execute('''
         CREATE TABLE Cliente(
           id INTEGER PRIMARY KEY,
           nombre TEXT,
           telefono TEXT,
           email TEXT,
           foto TEXT,
           nota TEXT
          )         
        ''');
      await db.execute('''
         CREATE TABLE Servicio(
           id INTEGER PRIMARY KEY,
           servicio TEXT,
           tiempo TEXT,
           precio INTEGER,
           detalle TEXT,
           activo TEXT
         )         
        ''');
      await db.execute('''
          CREATE TABLE Recordatorios(
            id INTEGER PRIMARY KEY,
            idRecord TEXT,
            fecha TEXT
          )         
          ''');
      await db.execute('''
          CREATE TABLE TiempoRecordatorio(
            id INTEGER,
            tiempo TEXT
          )         
          ''');
      await db.execute('''
          CREATE TABLE Tema(
            id INTEGER,
            color INTEGER
          )         
          ''');
      await db.execute('''
          CREATE TABLE Pago(
            id INTEGER,
            pago TEXT,
            email TEXT
          )         
          ''');
      await db.execute('''
          CREATE TABLE PlanAmigo(
            id INTEGER,
            email TEXT
          )         
          ''');
      await db.execute('''
          CREATE TABLE Personaliza(
            id INTEGER,
            codpais INTEGER,
            mensaje TEXT,
            enlace TEXT,
            moneda TEXT
          )         
          ''');
      await db.execute('''
          CREATE TABLE Notificaciones(
            id INTEGER PRIMARY KEY,
            leading TEXT,
            title TEXT,
            subtitle TEXT
          )         
          ''');
    });
  }

  Future<int> nuevoCliente(ClienteModel nuevoCliente) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Cliente', nuevoCliente.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> nuevaCita(CitaModel nuevaCita) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Cita', nuevaCita.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> nuevoServicio(ServicioModel nuevoServicio) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Servicio', nuevoServicio.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> nuevoRecordatorio(RecordatorioModel nuevoRecordatorio) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Recordatorios', nuevoRecordatorio.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> nuevoTiempoRecordatorio(
      TiempoRecordatorioModel nuevoTiempoRecordatorio) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!
        .insert('TiempoRecordatorio', nuevoTiempoRecordatorio.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> nuevoTema(TemaModel nuevoTema) async {
    print('color que se cuarda :  ${nuevoTema.color}');
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Tema', nuevoTema.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> guardarPersonaliza(PersonalizaModel nuevoPersonaliza) async {
    // Verifica la base de datos
    final db = await database;
    final res = await db!.insert('Personaliza', nuevoPersonaliza.toJson());

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> guardaPago(PagoModel guardapago) async {
    print('pago que se cuarda :  ${guardapago.pago}');
    print('email que se cuarda :  ${guardapago.email}');
    // Verifica la base de datos
    final db = await database;
    //todo: con insert, se agregan nuevos objetos de pago en db, por lo que se acumalan inecesariamente
    //? deberia hacer un UPDATE cuando ya hubiera un pago guardado
    // await db!.delete('Pago');
    final datos = await db!.query('Pago');

    /// final res = await db.update('Pago', guardapago.toJson());
    print(datos.length);
    final res = datos.isEmpty
        ? await db.insert('Pago', guardapago.toJson())
        : await db.update('Pago', guardapago.toJson());
    print('------------id pago --------$res');

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<int> guardaPlanAmigo(PlanAmigoModel planAmigo) async {
    debugPrint('email que se cuarda :  ${planAmigo.email.toString()}');
    // Verifica la base de datos
    final db = await database;
    //todo: con insert, se agregan nuevos objetos de email en db, por lo que se acumalan inecesariamente
    //? deberia hacer un UPDATE cuando ya hubiera un pago guardado

    final datos = await db!.query('PlanAmigo');

    /// final res = await db.update('Pago', guardapago.toJson());
    print(datos.length);
    final res = datos.isEmpty
        ? await db.insert('PlanAmigo', planAmigo.toJson())
        : await db.update('PlanAmigo', planAmigo.toJson());
    print('------------id planAmigo --------$res');

    // RES Es el ID del último registro guardado
    return res;
  }

  Future<List<CitaModel>> getTodasLasCitas() async {
    final db = await database;
    final res = await db!.query('Cita');
    return res.isNotEmpty ? res.map((s) => CitaModel.fromJson(s)).toList() : [];
  }

  Future<List<ClienteModel>> getTodosLosClientes() async {
    final db = await database;
    final res = await db!.query('Cliente');
    return res.isNotEmpty
        ? res.map((s) => ClienteModel.fromJson(s)).toList()
        : [];
  }

  Future<List<ServicioModel>> getTodoslosServicios() async {
    final db = await database;
    final res = await db!.query('Servicio');
    return res.isNotEmpty
        ? res.map((s) => ServicioModel.fromJson(s)).toList()
        : [];
  }

  Future<List<RecordatorioModel>> getTodoslosRecordatorios() async {
    final db = await database;
    final res = await db!.query('Recordatorios');
    return res.isNotEmpty
        ? res.map((s) => RecordatorioModel.fromJson(s)).toList()
        : [];
  }

  Future<List<TiempoRecordatorioModel>> getTiempoRecordatorios() async {
    final db = await database;
    final res = await db!.query('TiempoRecordatorio');
    return res.isNotEmpty
        ? res.map((s) => TiempoRecordatorioModel.fromJson(s)).toList()
        : [];
  }

  Future<List<TemaModel>> getTema() async {
    final db = await database;
    final res = await db!.query('Tema');
    return res.isNotEmpty ? res.map((s) => TemaModel.fromJson(s)).toList() : [];
  }

  Future<dynamic> getPago() async {
    final db = await database;
    final res = await db!.query('Pago');

    //print(res.map((e) => e['pago']));
    Map<String, Object?> pago;
    // COMPROBACION NECESARIA CUANDO LA BD DEL DISPOSITIVO ESTA VACÍA
    // SIN ESTA COMPROBACION DEVUELVE NULL

    debugPrint('estoy viendo lo que se trae del dispositivo Pago $res');
    if (res.isNotEmpty) {
      pago = {
        'pago': res[0]['pago'],
        'email': res[0]['email'],
      };
    } else {
      //SI LA BD ESTA VACIA , DEVUELVE PAGO:FALSE Y EMAIL: ''
      pago = {'pago': 'false', 'email': ''};
    }

    return pago;
  }

  Future<dynamic> getPlanAmigo() async {
    final db = await database;
    final res = await db!.query('PlanAmigo');

    Map<String, Object?> data;
    // COMPROBACION NECESARIA CUANDO LA BD DEL DISPOSITIVO ESTA VACÍA
    // SIN ESTA COMPROBACION DEVUELVE NULL

    debugPrint('estoy viendo lo que se trae del dispositivo PlanAmigo $res');
    if (res.isNotEmpty) {
      data = {
        'email': res[0]['email'],
      };
    } else {
      //SI LA BD ESTA VACIA , DEVUELVE PlanAmigo, EMAIL: ''
      data = {'email': ''};
    }

    return data;
  }

  Future<List<CitaModel>> getCitasHoraOrdenadaPorFecha(String fecha) async {
    final db = await database;
    final res = await db!.rawQuery("select * from Cita where dia='$fecha'");

    return res.isNotEmpty ? res.map((s) => CitaModel.fromJson(s)).toList() : [];
  }

  Future<List<CitaModel>> getCitasPorCliente(int idCliente) async {
    final db = await database;
    final res =
        await db!.rawQuery("select * from Cita where id_cliente='$idCliente'");

    return res.isNotEmpty ? res.map((s) => CitaModel.fromJson(s)).toList() : [];
  }

  Future<List<CitaModel>> getServiciosPorCliente(int idCliente) async {
    final db = await database;
    final res =
        await db!.rawQuery("select * from Servicio where id='$idCliente'");

    return res.isNotEmpty ? res.map((s) => CitaModel.fromJson(s)).toList() : [];
  }

  Future<ClienteModel> getCientePorId(int id) async {
    final db = await database;
    final res = await db!.query(
      "Cliente",
      where: 'id = $id',
    );
    return ClienteModel.fromJson(res.first);
    /* return res.isNotEmpty
        ? res.map((s) => ClienteModel.fromJson(s)).toList()
        : []; */
  }

  Future<ServicioModel> getServicioPorId(id) async {
    final db = await database;
    final res = await db!.query(
      "Servicio",
      where: 'id = $id',
    );
    return ServicioModel.fromJson(res.first);
    /* return res.isNotEmpty
        ? res.map((s) => ClienteModel.fromJson(s)).toList()
        : []; */
  }

  Future<List<ClienteModel>> getCientePorTelefono(String telefono) async {
    final db = await database;
    final res = await db!.query(
      "Cliente",
      where: 'telefono = $telefono',
    );

    return res.isNotEmpty
        ? res.map((s) => ClienteModel.fromJson(s)).toList()
        : [];
  }

  Future<RecordatorioModel> getRecordatorioPorId(int id) async {
    final db = await database;
    final res = await db!.query(
      "Recordatorios",
      where: 'id = $id',
    );
    return RecordatorioModel.fromJson(res.first);
  }

  Future<List<PersonalizaModel>> getPersonaliza() async {
    final db = await database;
    final res = await db!.query('Personaliza');
    return res.isNotEmpty
        ? res.map((s) => PersonalizaModel.fromJson(s)).toList()
        : [];
  }

  eliminaTodoslasCitas() async {
    final db = await database;

    final res = await db!.delete(
      'Cita',
    );
    return res;
  }

  eliminarCita(int id) async {
    final db = await database;

    final res = await db!.delete(
      'Cita',
      where: 'id = $id',
    );
    return res;
  }

  eliminaTodoslosServicios() async {
    final db = await database;

    final res = await db!.delete(
      'Servicio',
    );
    return res;
  }

  eliminarServicio(int id) async {
    final db = await database;

    final res = await db!.delete(
      'Servicio',
      where: 'id = $id',
    );
    return res;
  }

  eliminaTodoslosClientes() async {
    final db = await database;

    final res = await db!.delete(
      'Cliente',
    );
    return res;
  }

  eliminarCliente(int id) async {
    final db = await database;

    final res = await db!.delete(
      'Cliente',
      where: 'id = $id',
    );
    return res;
  }

  eliminarRecordatorio(int id) async {
    final db = await database;

    final res = await db!.delete(
      'Recordatorios',
      where: 'id = $id',
    );
    return res;
  }

  actualizarCliente(ClienteModel cliente) async {
    //realizo un nuevo cliente quitando el id , porque no se puede acualizar el integerkey ya que es autoincrementado.
    print(cliente.foto);
    Map<String, Object?> newCliente = {
      'nombre': cliente.nombre,
      'telefono': cliente.telefono,
      'email': cliente.email,
      'foto': cliente.foto,
      'nota': cliente.nota
    };
    final db = await database;

    final res = await db!.update('Cliente', newCliente,
        where: 'id = ?', whereArgs: [cliente.id]);
    return res;
  }

  actualizarRecordatorio(TiempoRecordatorioModel recordatorio) async {
    Map<String, Object?> newRecordatorio = {
      'id': 0,
      'tiempo': recordatorio.tiempo
    };
    final db = await database;

    final res = await db!.update('TiempoRecordatorio', newRecordatorio);

    return res;
  }

  acutalizarServicio(ServicioModel servicio) async {
    //realizo un nuevo cliente quitando el id , porque no se puede acualizar el integerkey ya que es autoincrementado.
    Map<String, Object?> newServicio = {
      'servicio': servicio.servicio,
      'tiempo': servicio.tiempo,
      'precio': servicio.precio,
      'detalle': servicio.detalle,
      'activo': servicio.activo,
    };
    final db = await database;

    final res = await db!.update('Servicio', newServicio,
        where: 'id = ?', whereArgs: [servicio.id]);
    return res;
  }

  actualizarCita(CitaModel cita) async {
    //realizo un nuevo cliente quitando el id , porque no se puede acualizar el integerkey ya que es autoincrementado.
    Map<String, Object?> newCita = {
      'dia': cita.dia,
      'horainicio': cita.horaInicio,
      'horafinal': cita.horaFinal,
      'comentario': cita.comentario,
      'id_cliente': cita.idcliente,
      'id_servicio': cita.idservicio,
    };
    final db = await database;

    final res = await db!
        .update('Cita', newCita, where: 'id = ?', whereArgs: [cita.id]);
    return res;
  }

  actualizarTema(int color) async {
    Map<String, int> newColor = {'id': 0, 'color': color};
    final db = await database;

    final res = await db!.update('Tema', newColor);

    return res;
  }

  actualizarPersonaliza(PersonalizaModel personaliza) async {
    Map<String, Object?> newPersonaliza = {
      'id': 0,
      'codpais': personaliza.codpais,
      'mensaje': personaliza.mensaje,
      'enlace': personaliza.enlace,
      'moneda': personaliza.moneda
    };
    final db = await database;

    final res = await db!.update('Personaliza', newPersonaliza);

    return res;
  }
}
