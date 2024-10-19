// ignore_for_file: unused_import

import 'dart:io';

import 'package:agendacitas/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';
import 'style/estilo_pantalla.dart';

class NuevoActualizacionCliente extends StatefulWidget {
  /*  ClienteModel clienteParametro;
  bool pagado; */
  final ClienteModel? cliente;
  final bool? pagado;
  final String? usuarioAPP;

  const NuevoActualizacionCliente(
      {Key? key,
      required this.usuarioAPP,
      required this.cliente,
      required this.pagado})
      : super(key: key);

  @override
  State<NuevoActualizacionCliente> createState() =>
      _NuevoActualizacionClienteState();
}

class _NuevoActualizacionClienteState extends State<NuevoActualizacionCliente> {
  final _formKey = GlobalKey<FormState>();
  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);
  String textoValidacion = '';
  final ImagePicker _picker = ImagePicker();
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  bool pagado = false;
  PagoProvider? data;
  bool cargandoImagen = false;
  bool floatExtended = false;

  bool isEmailValid = true;
  String email = '';
  String numtelefono = '';

  bool isTelfValido = true;

  // ignore: prefer_typing_uninitialized_variables
  var myLogic;
  estadoPagoEmailApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    estadoPagoEmailApp();

    myLogic = MyLogicCliente(widget.cliente!);
    myLogic.init();

    // ANIMACION FLOATINGBUTTON
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        floatExtended = true;

        // Here you can write your code for open new view
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('hay sesion iniciada $iniciadaSesionUsuario');
    myLogic.textControllerFoto.text;
    //setState(() {});
    ClienteModel cliente = widget.cliente!;
    pagado = _iniciadaSesionUsuario;

    /*  bool pagado = widget.pagado!;
    String usuarioAPP = widget.usuarioAPP!;
    usuarioAPP != ''
        ? iniciadaSesionUsuario = true
        : iniciadaSesionUsuario = false; */

    // COMPROBACION => SI ESTE FORMULARIO ES LLAMADO DESDE  clientesScreen.dart(NUEVO CLIENTE)
    //                 O ES LLAMADO DESDE fichaClienteScreen.dart (ACUTALIZAR)
    bool nuevoCliente;
    (cliente.telefono == null) ? nuevoCliente = true : nuevoCliente = false;

    debugPrint(
        'email cliente:${cliente.email} telefono cliente ${cliente.telefono}// pagado : $pagado // usuarioAPP: $_emailSesionUsuario ');

    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor,
                )),
                label: Text(
                  nuevoCliente ? 'NUEVO CLIENTE' : 'ACTUALIZAR CLIENTE',
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!cargandoImagen) {
                      cliente = await clienteDatos();
                      setState(() {});
                      nuevoCliente
                          ? _nuevoCliente(
                              _emailSesionUsuario, cliente, pagado, myLogic)
                          : _refrescaFicha(
                              _emailSesionUsuario, cliente, pagado, myLogic);
                    } else {
                      mensajeError(context, 'NO ACTUALIZADO, CARGANDO FOTO');
                    }
                  }
                },
                icon: const Icon(Icons.save))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Carga de imagen o indicador de carga
                  !cargandoImagen
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: _iniciadaSesionUsuario &&
                                  myLogic.textControllerFoto.text.isNotEmpty
                              ? Image.network(
                                  myLogic.textControllerFoto.text,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "./assets/images/nofoto.jpg",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(width: 10),
                  // Botones para seleccionar imagen
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          label: const Text('MI IMÁGENES'),
                          onPressed: () async {
                            if (_iniciadaSesionUsuario) {
                              setState(() {
                                cargandoImagen = true;
                              });

                              final image = await getImageGaleria(
                                  _emailSesionUsuario,
                                  cliente.telefono ?? '',
                                  cliente);
                              myLogic.textControllerFoto.text = image;

                              setState(() {
                                cargandoImagen = false;
                              });
                            } else {
                              mensajeInfo(
                                  context, 'NO DISPONIBLE SIN INICIAR SESIÓN');
                            }
                          },
                          icon: const Icon(Icons.image),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          label: const Text('HAZ UNA FOTO'),
                          onPressed: () async {
                            if (_iniciadaSesionUsuario) {
                              setState(() {
                                cargandoImagen = true;
                              });

                              final image = await getImageFoto(
                                  _emailSesionUsuario, cliente.telefono ?? '');
                              myLogic.textControllerFoto.text = image;

                              setState(() {
                                cargandoImagen = false;
                              });
                            } else {
                              mensajeInfo(
                                  context, 'NO DISPONIBLE SIN INICIAR SESIÓN');
                            }
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 20), // Espacio entre la fila y el formulario
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        maxLength: 25,
                        style: Theme.of(context).textTheme.titleMedium,
                        validator: (value) => _validacion(value),
                        controller: myLogic.textControllerNombre,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Espacio entre campos
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            numtelefono = value;
                            isTelfValido = isPhoneNumberValid(value);
                          });
                        },
                        style: Theme.of(context).textTheme.titleLarge,
                        validator: (value) => _validacion(value),
                        keyboardType: TextInputType.number,
                        controller: myLogic.textControllerTelefono,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          errorText: isTelfValido
                              ? null
                              : 'Formato de teléfono inválido',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Espacio entre campos
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            email = value;
                            isEmailValid = isEmailValido(value);
                          });
                        },
                        style: Theme.of(context).textTheme.titleLarge,
                        keyboardType: TextInputType.emailAddress,
                        controller: myLogic.textControllerEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: isEmailValid
                              ? null
                              : 'Formato de correo inválido',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Espacio entre campos
                      TextFormField(
                        maxLength: 25,
                        style: Theme.of(context).textTheme.titleSmall,
                        controller: myLogic.textControllerNota,
                        decoration: InputDecoration(
                          labelText: 'Notas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 200), // Espacio adicional al final
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _actualizarClienteFB(usuarioAPP, cliente) {
    SincronizarFirebase().actualizarCliente(usuarioAPP, cliente);
  }

  _actualizar(ClienteModel cliente) {
    CitaListProvider().acutalizarCliente(cliente);
  }

  void _refrescaFicha(
      String usuarioAPP, ClienteModel cliente, bool pagado, myLogic) {
    //   print(cliente.foto);
    //ACTUALIZA CLIENTE EN DIPOSITIVO
    _actualizar(cliente);

    // ACTUALIZA CLIENTE DE FIREBASE SI HAY USUARIO
    if (usuarioAPP != '') _actualizarClienteFB(usuarioAPP, cliente);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => FichaClienteScreen(
                clienteParametro: ClienteModel(
                    id: cliente.id,
                    nombre: cliente.nombre,
                    telefono: cliente.telefono,
                    email: cliente.email,
                    foto: cliente.foto,
                    nota: cliente.nota),
              )),
    );
    String mensaje =
        'FICHA DE ${cliente.nombre.toString().toUpperCase()} ACTUALIZADA';
    mensajeSuccess(context, mensaje);
  }

  Future getImageFoto(String usuarioAPP, String telefonoCliente) async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      // SUBE LA FOTO A FIREBASE STORAGE
      String pathFireStore = '';

      if (usuarioAPP != '') {
        pathFireStore = await _subirImagenStorage(
            usuarioAPP, image!.path, telefonoCliente, myLogic);
      }

      return pathFireStore;
    } catch (e) {
      debugPrint('Error de imagen $e');
    }
  }

  Future getImageGaleria(
      String usuarioAPP, String telefonoCliente, cliente) async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      // SUBE LA FOTO A FIREBASE STORAGE
      String pathFireStore = '';

      if (_iniciadaSesionUsuario) {
        pathFireStore = await _subirImagenStorage(
            usuarioAPP, image!.path, telefonoCliente, myLogic);

        await _actualizar(cliente);
      }

      return pathFireStore;
    } catch (e) {
      debugPrint('Error de imagen $e');
    }
  }

//https://medium.com/unitechie/how-to-upload-files-to-firebase-storage-in-flutter-873fd764a39b
  _subirImagenStorage(usuarioAPP, image, telefonoCliente, myLogic) async {
    print('------------ESTOY SUBIENDO IMAGEN AL STORE');

    //1º INICIALIZAR

    await Firebase.initializeApp();
    var storage = FirebaseStorage.instance;
    //2º FILE LLEVA LA RUTA DE LA FOTO EN EL DISPOSITIVO
    final file = File(image);

    try {
      //3º SUBIR FOTO AL STORAGE
      //TASKSHAPSHOT ES PARA USAR EN POSTERIOR CONSULTA AL STORAGE

      TaskSnapshot taskSnapshot = await storage
          // GUARDO LAS FOTO DE FICHA CLIENTE EN LA SIGUIENTE DIRECCION DEL STORAGE FIREBASE
          .ref('agendadecitas/$usuarioAPP/clientes/$telefonoCliente/foto')
          .putFile(file);
      debugPrint(taskSnapshot.toString());
      // CONSULTA DE LA URL EN STORAGE
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint(downloadUrl.toString());

      myLogic.textControllerFoto.text = downloadUrl;
      setState(() {});
      cargandoImagen = false;

      final cliente = clienteDatos();
      _actualizarClienteFB(usuarioAPP, cliente);
      mensajeSuccess(context, 'FOTO CARGADA');
    } on FirebaseException catch (e) {
      var snackBar = SnackBar(
        content: Text('Error Store en la nube ${e.message}'),
      );

      _snakBar(snackBar);
      debugPrint(e.message.toString());
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('ERROR AL CARGAR LA FOTO'),
      );

      _snakBar(snackBar);
      debugPrint(e.toString());
    }
  }

  _snakBar(snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _nuevoCliente(String s, ClienteModel cliente, bool pagado, myLogic) async {
    String nombre = cliente.nombre!;
    String telefono = cliente.telefono!;
    String email = cliente.email!;
    String foto = cliente.foto!;
    String nota = cliente.nota!;
    if (pagado) {
      try {
        // COMPROBACION SI EL TELEFONO DEL CONTACTO YA EXISTE
        final existe = await FirebaseProvider()
            .cargarClientePorTelefono(_emailSesionUsuario, telefono);

        existe.isNotEmpty
            ? _alertaYaExiste(existe)
            : _agregaContacto(nombre, telefono, email, foto, nota);
      } catch (e) {
        mensajeError(context, 'algo salió mal');
      }
    } else {
      await CitaListProvider()
          .nuevoCliente(nombre, telefono, email, foto, nota)
          .whenComplete(() {
        debugPrint('cliente nuevo añadido!!');
        Navigator.pop(context);
        /*  Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(
                      index: 2,
                    ))); */
      });
    }
  }

  clienteDatos() {
    ClienteModel cliente = ClienteModel();

    cliente.id = widget.cliente!.id;
    cliente.nombre = myLogic.textControllerNombre.text;
    cliente.telefono = myLogic.textControllerTelefono.text;
    cliente.email = myLogic.textControllerEmail.text;
    cliente.foto = myLogic.textControllerFoto.text;
    cliente.nota = myLogic.textControllerNota.text;
    return cliente;
  }

  _validacion(value) {
    if (value.isEmpty) {
      return 'Este campo no puede quedar vacío';
    }
  }

  void _agregaContacto(String nombre, String telefono, String email,
      String foto, String nota) async {
    await FirebaseProvider()
        .nuevoCliente(_emailSesionUsuario, nombre, telefono, email, foto, nota)
        .whenComplete(() {
      debugPrint('cliente nuevo añadido en Firebase!!');
      Navigator.pop(context);
      _actualiza();
    });
  }

  _actualiza() {
    mensajeInfo(
        context, 'Contacto Agregado, \nArrastra la lista para actualizar');
  }

  void _alertaYaExiste(existe) {
    mensajeError(context, '$mensajeYaExisteCliente ${existe['nombre']}');
  }

// funcion validar formatos email
  bool isEmailValido(String email) {
    final emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  // Función para validar el formato del número de teléfono sin símbolos no deseados
  bool isPhoneNumberValid(String phoneNumber) {
    final phoneRegex = RegExp(r'^[0-9]*$');
    return phoneRegex.hasMatch(phoneNumber);
  }
}
