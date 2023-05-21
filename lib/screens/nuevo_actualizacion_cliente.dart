// ignore_for_file: unused_import

import 'dart:io';

import 'package:agendacitas/main.dart';
import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/screens/ficha_cliente_screen.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';

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
  final ImagePicker _picker = ImagePicker();
  bool iniciadaSesionUsuario = false;
  String usuarioAPP = '';
  bool pagado = false;
  PagoProvider? data;
  bool cargandoImagen = false;
  bool floatExtended = false;

  // ignore: prefer_typing_uninitialized_variables
  var myLogic;
  compruebaPago() async {
    //   PagoProvider para obtener pago y el email del usuarioAPP
    final providerPagoUsuarioAPP =
        Provider.of<PagoProvider>(context, listen: false);

    setState(() {
      pagado = providerPagoUsuarioAPP.pagado['pago'];
      usuarioAPP = providerPagoUsuarioAPP.pagado['email'];
      usuarioAPP != ''
          ? iniciadaSesionUsuario = true
          : iniciadaSesionUsuario = false;
    });
    print(
        'datos gardados en tabla Pago (nuevo_actualizacion_cliente.dart) PAGO: $pagado // EMAIL:$usuarioAPP ');
  }

  @override
  void initState() {
    compruebaPago();

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
    print('hay sesion iniciada $iniciadaSesionUsuario');
    myLogic.textControllerFoto.text;
    //setState(() {});
    ClienteModel cliente = widget.cliente!;
    pagado = iniciadaSesionUsuario;

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
        'email cliente:${cliente.email} telefono cliente ${cliente.telefono}// pagado : $pagado // usuarioAPP: $usuarioAPP ');

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          nuevoCliente ? 'NUEVO CLIENTE' : 'ACTUALIZAR CLIENTE',
        ),
        isExtended: floatExtended,
        icon: nuevoCliente
            ? const Icon(Icons.add)
            : const Icon(Icons.change_circle_outlined),
        onPressed: () async {
          if (!cargandoImagen) {
            cliente = await clienteDatos();
            setState(() {});
            nuevoCliente
                ? _nuevoCliente(usuarioAPP, cliente, pagado, myLogic)
                : _refrescaFicha(usuarioAPP, cliente, pagado, myLogic);
          } else {
            mensajeError(context, 'NO ACTUALIZADO, CARGANDO FOTO');
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(58.0),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Row(
              //BOTON X PARA CERRAR FORMULARIO
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 50,
                ),
                IconButton(
                    onPressed: () => nuevoCliente
                        ? Navigator.pop(context)
                        : Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FichaClienteScreen(
                                      clienteParametro: ClienteModel(
                                          id: cliente.id,
                                          nombre: cliente.nombre,
                                          telefono: cliente.telefono,
                                          email: cliente.email,
                                          foto: myLogic.textControllerFoto.text,
                                          nota: cliente.nota),
                                    )),
                          ),
                    icon: const Icon(
                      Icons.close,
                      size: 50,
                      color: Color.fromARGB(167, 114, 136, 150),
                    )),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                !cargandoImagen // espera a que la imagen se cargue
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(150.0),
                        child:
                            // ##### si hay sesion y foto guadada la carga de firebase con al ruta de textControllerFoto.text(no visible al usuario) #####
                            iniciadaSesionUsuario &&
                                    myLogic.textControllerFoto.text != ''
                                ? Image.network(
                                    myLogic.textControllerFoto.text,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                // ### si no hay foto  o  no hay usuario, muestra imagen nofoto.jpg
                                : Image.asset(
                                    "./assets/images/nofoto.jpg",
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(150.0),
                        child: const CircularProgressIndicator(),
                      ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (iniciadaSesionUsuario) {
                            setState(() {
                              cargandoImagen = true;
                            });

                            final image = await getImageGaleria(
                                usuarioAPP,
                                cliente.telefono != null
                                    ? cliente.telefono!
                                    : '',
                                cliente);
                            myLogic.textControllerFoto.text = image;

                            setState(() {
                              cargandoImagen = false;
                            });

                            //  /utils/alertaNodisponible.dart
                          } else {
                            mensajeInfo(
                                context, 'NO DISPONIBLE SIN INICIAR SESION');
                          }
                        },
                        icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () async {
                          if (iniciadaSesionUsuario) {
                            setState(() {
                              cargandoImagen = true;
                            });

                            final image = await getImageFoto(
                                usuarioAPP,
                                cliente.telefono != null
                                    ? cliente.telefono!
                                    : '');
                            myLogic.textControllerFoto.text = image;
                            setState(() {
                              cargandoImagen = false;
                            });

                            //  /utils/alertaNodisponible.dar
                          } else {
                            mensajeInfo(
                                context, 'NO DISPONIBLE SIN INICIAR SESION');
                          }
                        },
                        icon: const Icon(Icons.photo_camera)),
                  ],
                )
              ],
            ),
            //todo: NO HAY FORM PARA VALIDAR LAS ENTRADAS?
            TextField(
              controller: myLogic.textControllerNombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: myLogic.textControllerTelefono,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: myLogic.textControllerEmail,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            /*  TextField(
              //todo: quitar en produccion
              enabled: false,
              controller: myLogic.textControllerFoto,
              decoration: const InputDecoration(labelText: 'Foto'),
            ), */
            TextField(
              controller: myLogic.textControllerNota,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    );
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

      if (iniciadaSesionUsuario) {
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
    if (iniciadaSesionUsuario) {
      await FirebaseProvider()
          .nuevoCliente(usuarioAPP, nombre, telefono, email, foto, nota)
          .whenComplete(() {
        debugPrint('cliente nuevo añadido en Firebase!!');
        Navigator.pushNamed(context, 'clientesScreen');
      });
    } else {
      await CitaListProvider()
          .nuevoCliente(nombre, telefono, email, foto, nota)
          .whenComplete(() {
        debugPrint('cliente nuevo añadido!!');
        Navigator.pushNamed(context, 'clientesScreen');
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
}
