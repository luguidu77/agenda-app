import 'dart:io';

import 'package:agendacitas/screens/config/config_usuario_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';

class NuevoAcutalizacionUsuarioApp extends StatefulWidget {
  PerfilModel? perfilUsuarioApp;
  String? usuarioAPP;
  NuevoAcutalizacionUsuarioApp(
      {Key? key, required this.usuarioAPP, required this.perfilUsuarioApp})
      : super(key: key);

  @override
  State<NuevoAcutalizacionUsuarioApp> createState() =>
      _NuevoAcutalizacionUsuarioAppState();
}

class _NuevoAcutalizacionUsuarioAppState
    extends State<NuevoAcutalizacionUsuarioApp> {
  final ImagePicker _picker = ImagePicker();

  bool cargandoImagen = false;
  bool floatExtended = false;

  var myLogic;
  @override
  void initState() {
    myLogic = MyLogicUsuarioAPP(widget.perfilUsuarioApp);
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
    String usuarioAPP = widget.usuarioAPP!; // el email del usuario
    TextEditingController textControllerEmail =
        TextEditingController(text: usuarioAPP);

    PerfilModel perfilUsuarioApp = PerfilModel();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'ACTUALIZAR',
        ),
        isExtended: floatExtended,
        icon: const Icon(Icons.change_circle_outlined),
        onPressed: () async {
          perfilUsuarioApp.denominacion =
              myLogic.textControllerDenominacion.text;

          perfilUsuarioApp.foto = myLogic.textControllerFoto.text;
          perfilUsuarioApp.telefono = myLogic.textControllerTelefono.text;

          perfilUsuarioApp.descripcion = myLogic.textControllerDescripcion.text;
          perfilUsuarioApp.facebook = myLogic.textControllerFacebook.text;
          perfilUsuarioApp.instagram = myLogic.textControllerInstagram.text;
          perfilUsuarioApp.website = myLogic.textControllerWebsite.text;
          perfilUsuarioApp.ubicacion = myLogic.textControllerUbicacion.text;
          setState(() {});

          _refrescaFicha(perfilUsuarioApp, usuarioAPP, myLogic);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(58.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Row(
                //BOTON X PARA CERRAR FORMULARIO

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  IconButton(
                      onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ConfigUsuarioApp()),
                          ),
                      icon: const Icon(
                        Icons.close,
                        size: 50,
                        color: Color.fromARGB(167, 114, 136, 150),
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(150.0),
                    child: myLogic.textControllerFoto.text != ''
                        ? FadeInImage.assetNetwork(
                            width: 150,
                            height: 150,
                            placeholder: './assets/icon/galeria-de-fotos.gif',
                            image: myLogic.textControllerFoto.text.toString(),
                          )
                        : SizedBox(
                            child: Image.asset(
                              "./assets/images/nofoto.jpg",
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            cargandoImagen = true;

                            final image = await getImageGaleria(
                              usuarioAPP,
                            );
                            myLogic.textControllerFoto.text = image;

                            setState(() {});

                            cargandoImagen = false;

                            //  /utils/alertaNodisponible.dart
                          },
                          icon: const Icon(Icons.image)),
                      IconButton(
                          onPressed: () async {
                            cargandoImagen = true;

                            final image = await getImageFoto(
                              usuarioAPP,
                            );
                            myLogic.textControllerFoto.text = image;
                            setState(() {});

                            cargandoImagen = false;

                            //  /utils/alertaNodisponible.dart
                          },
                          icon: const Icon(Icons.photo_camera)),
                    ],
                  )
                ],
              ),
              //todo: NO HAY FORM PARA VALIDAR LAS ENTRADAS?
              TextField(
                controller: myLogic.textControllerDenominacion,
                decoration: const InputDecoration(
                    labelText: 'Denominación de tu negocio'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: myLogic.textControllerTelefono,
                decoration:
                    const InputDecoration(labelText: 'Teléfono de contacto'),
              ),
              TextField(
                enabled: false,
                controller: textControllerEmail,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                controller: myLogic.textControllerDescripcion,
                decoration:
                    const InputDecoration(labelText: 'Describe tu negocio'),
              ),

              TextField(
                enabled: false,
                controller: myLogic.textControllerFoto,
                decoration: const InputDecoration(labelText: 'Foto'),
              ),
              TextField(
                controller: myLogic.textControllerFacebook,
                decoration: const InputDecoration(labelText: 'Facebook'),
              ),
              TextField(
                controller: myLogic.textControllerInstagram,
                decoration: const InputDecoration(labelText: 'Instagram'),
              ),
              TextField(
                controller: myLogic.textControllerWebsite,
                decoration: const InputDecoration(labelText: 'Website'),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                controller: myLogic.textControllerUbicacion,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),

              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refrescaFicha(
      PerfilModel perfilUsuarioApp, String emailUsuarioApp, myLogic) async {
    // ACTUALIZA CLIENTE DE FIREBASE SI HAY USUARIO

    await _actualizarUsuarioAPPFB(perfilUsuarioApp, emailUsuarioApp);

    _snackBarRealizado();
  }

  _actualizarUsuarioAPPFB(PerfilModel perfilUsuarioApp, String emailUsuario) {
    SincronizarFirebase().actualizarUsuarioApp(perfilUsuarioApp, emailUsuario);
  }

  Future getImageGaleria(String usuarioAPP) async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      // SUBE LA FOTO A FIREBASE STORAGE
      String pathFireStore = '';

      if (usuarioAPP != '') {
        pathFireStore =
            await _subirImagenStorage(usuarioAPP, image!.path, myLogic);
      }

      return pathFireStore; //RETORNA LA DIRECCION DE LA FOTO EN STORAGE
    } catch (e) {
      print('Error de imagen $e');
    }
  }

  Future getImageFoto(String usuarioAPP) async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      // SUBE LA FOTO A FIREBASE STORAGE
      String pathFireStore = '';
      if (usuarioAPP != '') {
        pathFireStore =
            await _subirImagenStorage(usuarioAPP, image!.path, myLogic);
      }

      return pathFireStore; //RETORNA LA DIRECCION DE LA FOTO EN STORAGE
    } catch (e) {
      print('Error de imagen $e');
    }
  }

  _subirImagenStorage(usuarioAPP, image, myLogic) async {
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
          .ref('agendadecitas/$usuarioAPP/fotoPerfil')
          .putFile(file);
      print(taskSnapshot);
      // CONSULTA DE LA URL EN STORAGE
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print(downloadUrl);

      /*  myLogic.textControllerFoto.text = downloadUrl;
      setState(() {}); */

      cargandoImagen = false;
      const snackBar = SnackBar(
        content: Text('FOTO CARGADA CON EXITO'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return downloadUrl;
    } on FirebaseException catch (e) {
      var snackBar = SnackBar(
        content: Text('Error Store en la nube ${e.message}'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e.message);
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('ERROR AL CARGAR LA FOTO'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    }
  }

  void _snackBarRealizado() {
    const snackBar = SnackBar(content: Text('ACTUALIZACIÓN REALIZADA'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
