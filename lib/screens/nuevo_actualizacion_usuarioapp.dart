import 'dart:io';

import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';

// ignore: must_be_immutable
class NuevoAcutalizacionUsuarioApp extends StatefulWidget {
  dynamic perfilUsuarioApp;
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

    PerfilAdministradorModel perfilUsuarioApp = PerfilAdministradorModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDICIÓN'),
        actions: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).primaryColor,
              )),
              label: const Text('GUARDAR'),
              onPressed: () {
                perfilUsuarioApp.denominacion =
                    myLogic.textControllerDenominacion.text;

                perfilUsuarioApp.foto = myLogic.textControllerFoto.text;
                perfilUsuarioApp.telefono = myLogic.textControllerTelefono.text;

                perfilUsuarioApp.descripcion =
                    myLogic.textControllerDescripcion.text;
                perfilUsuarioApp.facebook = myLogic.textControllerFacebook.text;
                perfilUsuarioApp.instagram =
                    myLogic.textControllerInstagram.text;
                perfilUsuarioApp.website = myLogic.textControllerWebsite.text;
                perfilUsuarioApp.ubicacion =
                    myLogic.textControllerUbicacion.text;

                /*  perfilUsuarioApp.moneda = myLogic.textControllerMoneda.text;
          perfilUsuarioApp.servicios = myLogic.textControllerServicios.text;
          perfilUsuarioApp.ciudad = myLogic.textControllerCiudad.text;
          perfilUsuarioApp.horarios = myLogic.textControllerHorarios.text;
          perfilUsuarioApp.informacion = myLogic.textControllerInformacion.text;
          perfilUsuarioApp.normas = myLogic.textControllerNormas.text;
          perfilUsuarioApp.latitud = myLogic.textControllerLatitudtext;
          perfilUsuarioApp.longitud = myLogic.textControllerLongitud.text; */

                setState(() {});

                _refrescaFicha(perfilUsuarioApp, usuarioAPP, myLogic);
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 110,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: myLogic.textControllerFoto.text.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              fit: BoxFit.cover,
                              height: 150,
                              placeholder: './assets/icon/galeria-de-fotos.gif',
                              image: myLogic.textControllerFoto.text,
                            )
                          : Image.asset(
                              "./assets/images/nofoto.jpg",
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(
                      width: 16), // Espaciado entre la imagen y los íconos
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          cargandoImagen = true;
                          final image = await getImageGaleria(usuarioAPP);
                          myLogic.textControllerFoto.text = image;
                          setState(() {});
                          cargandoImagen = false;
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.blue, // Color del botón
                          padding: const EdgeInsets.all(16), // Tamaño del botón
                          elevation: 5,
                        ),
                        child: const Icon(Icons.image,
                            size: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          cargandoImagen = true;
                          final image = await getImageFoto(usuarioAPP);
                          myLogic.textControllerFoto.text = image;
                          setState(() {});
                          cargandoImagen = false;
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.green, // Color del botón
                          padding: const EdgeInsets.all(16), // Tamaño del botón
                          elevation: 5,
                        ),
                        child: const Icon(Icons.photo_camera,
                            size: 30, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 50,
              ),
              //todo: NO HAY FORM PARA VALIDAR LAS ENTRADAS?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: myLogic.textControllerDenominacion,
                    decoration: InputDecoration(
                      labelText: 'Denominación de tu negocio',
                      prefixIcon: Icon(Icons.business,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: myLogic.textControllerTelefono,
                    decoration: InputDecoration(
                      labelText: 'Teléfono de contacto',
                      prefixIcon: Icon(Icons.phone,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    controller: textControllerEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    controller: myLogic.textControllerFoto,
                    decoration: InputDecoration(
                      labelText: 'Foto',
                      prefixIcon: Icon(Icons.photo,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: myLogic.textControllerFacebook,
                    decoration: InputDecoration(
                      labelText: 'Facebook',
                      prefixIcon:
                          const Icon(Icons.facebook, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: myLogic.textControllerInstagram,
                    decoration: InputDecoration(
                      labelText: 'Instagram',
                      prefixIcon:
                          const Icon(Icons.camera_alt, color: Colors.pink),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: myLogic.textControllerWebsite,
                    decoration: InputDecoration(
                      labelText: 'Website',
                      prefixIcon: Icon(Icons.language,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    controller: myLogic.textControllerUbicacion,
                    decoration: InputDecoration(
                      labelText: 'Ubicación',
                      prefixIcon: Icon(Icons.location_on,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _refrescaFicha(PerfilAdministradorModel perfilUsuarioApp,
      String emailUsuarioApp, myLogic) async {
    // ACTUALIZA CLIENTE DE FIREBASE SI HAY USUARIO

    await _actualizarUsuarioAPPFB(perfilUsuarioApp, emailUsuarioApp);

    _snackBarRealizado();
  }

  _actualizarUsuarioAPPFB(
      PerfilAdministradorModel perfilUsuarioApp, String emailUsuario) {
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
        content: Text('GUARDA CAMBIOS'),
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
    mensajeSuccess(context, 'ACTUALIZACIÓN REALIZADA');
  }
}
