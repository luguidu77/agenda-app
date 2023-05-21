import 'dart:io';

import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/screens/nuevo_actualizacion_cliente.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../models/personaliza_model.dart';
import '../providers/providers.dart';

class FichaClienteScreen extends StatefulWidget {
  final ClienteModel clienteParametro;
  const FichaClienteScreen({Key? key, required this.clienteParametro})
      : super(key: key);

  @override
  State<FichaClienteScreen> createState() => _FichaClienteScreenState();
}

class _FichaClienteScreenState extends State<FichaClienteScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _citas = [];
  PagoProvider? data;
  bool? pagado;
  String? usuarioAPP;
  bool iniciadaSesionUsuario = false;
  XFile? _image;
  PersonalizaModel personaliza = PersonalizaModel();

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  } 

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
    debugPrint(
        'datos gardados en tabla Pago (fichaClienteScreen.dart) PAGO: $pagado // EMAIL:$usuarioAPP ');
  }

  @override
  void initState() {
    getPersonaliza();
    compruebaPago();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //FOTO CLIENTE

    String foto = widget.clienteParametro.foto!;
    print("foto de la cliente $foto");

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  //  Navigator.pushNamed(context, 'clientesScreen'),
                  icon: const Icon(Icons.arrow_back)),
              actions: [iconoModificar()],
              elevation: 0.0,
              pinned: true,
              // backgroundColor: Colors.deepPurple,
              expandedHeight: 250,
              //imagenes guardada en Storage Firebase
              //https://medium.flutterdevs.com/firebase-storage-in-flutter-1f06742472b1
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                expandedTitleScale: 1.5,
                background:
                    iniciadaSesionUsuario && widget.clienteParametro.foto! != ''
                        ? SizedBox(
                            child: Image.network(
                            widget.clienteParametro.foto!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ))
                        : Image.asset(
                            "./assets/images/nofoto.jpg",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            const SliverAppBar(
              // backgroundColor: Color.fromARGB(59, 119, 117, 117),
              automaticallyImplyLeading: false,
              pinned: true,
              primary: false,
              elevation: 8.0,

              // backgroundColor: Colors.deepPurple,
              title: Align(
                alignment: AlignmentDirectional.center,
                child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        text: 'Datos',
                      ),
                      Tab(
                        text: 'Historial',
                      ),
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 800,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TabBarView(
                      // physics: ScrollPhysics(),
                      children: [
                        _datos(widget.clienteParametro, pagado!,
                            widget.clienteParametro.id),
                        _historial(context, _citas, widget.clienteParametro.id),
                      ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future getImage(myLogic) async {
    try {
      var image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      setState(() {
        _image = image;

        print('Image Path ${_image!.path}');
      });

      _subirImagenStorage(_image!.path, myLogic);
    } catch (e) {
      print('Error de imagen $e');
    }
  }

//https://medium.com/unitechie/how-to-upload-files-to-firebase-storage-in-flutter-873fd764a39b
  void _subirImagenStorage(image, myLogic) async {
    try {
      //1º INICIALIZAR
      await Firebase.initializeApp();
      var storage = FirebaseStorage.instance;
      //2º FILE LLEVA LA RUTA DE LA FOTO EN EL DISPOSITIVO
      final file = File(image);

      //3º SUBIR FOTO AL STORAGE
      //TASKSHAPSHOT ES PARA USAR EN POSTERIOR CONSULTA AL STORAGE
      //TaskSnapshot taskSnapshot =
      await storage
          // GUARDO LAS FOTO DE FICHA CLIENTE EN LA SIGUIENTE DIRECCION DEL STORAGE FIREBASE
          .ref('agendadecitas/clientes/$usuarioAPP/foto')
          .putFile(file);
      // CONSULTA DE LA URL EN STORAGE
      // final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  iconoModificar() {
    return IconButton(
      iconSize: 50,
      onPressed: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoActualizacionCliente(
              cliente: widget.clienteParametro,
              pagado: pagado,
              usuarioAPP: usuarioAPP,
            ),
          ),
        );
      },
      icon: const Icon(
        Icons.settings,
        color: Colors.black12,
      ),
    );
  }

  _datos(ClienteModel cliente, bool pagado, idCliente) {
    BoxDecoration decorationTarjetaNombre = BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(colors: [
          Color.fromARGB(0, 111, 179, 210),
          Color.fromARGB(73, 111, 179, 210),
        ]));
    var estiloTelEmail = const TextStyle(fontSize: 14);
    var estiloNombre = const TextStyle(fontSize: 18);
    // int numCitas = citas.length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //nivelCliente(iniciadaSesionUsuario, usuarioAPP, cliente),
          Text(
            '${cliente.nombre}',
            style: estiloNombre,
          ),
          const SizedBox(height: 50),
          Row(
            children: [
              const Icon(Icons.phone),
              const SizedBox(
                width: 20,
              ),
              Text(
                '${cliente.telefono}',
                style: estiloTelEmail,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Icon(Icons.mail),
              const SizedBox(
                width: 20,
              ),
              Text(
                cliente.email ?? '---',
                style: estiloTelEmail,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Información:'),
                ],
              ),
              Text(
                cliente.nota ?? '---',
              ),
            ],
          ),
        ],
      ),
    );
  }

  _historial(context, List<Map<String, dynamic>> citas, idCliente) {
    return FutureBuilder<dynamic>(
        future: iniciadaSesionUsuario
            ? FirebaseProvider().cargarCitasPorCliente(usuarioAPP!, idCliente)
            : CitaListProvider().cargarCitasPorCliente(idCliente),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 5,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 80,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            );
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            //#### SNAPSHOT TRAE LAS CITAS, LAS CUALES LAS PASO POR ORDEN DE FECHAS A LA VARIABLE  citas
            List citas = listaCitasOrdenadasPorFecha(snapshot.data);

            if (snapshot.hasError) {
              return const Text('Error');

              //###################    SI HAY DATOS Y LA CITAS NO ESTA VACIA ###########################
            } else if (snapshot.hasData && citas.isNotEmpty) {
              return Column(
                children: [
                  SizedBox(
                    // tarjeta con numero de citas concertadas

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${citas.length} citas concertadas ',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 110, 108, 108),
                              fontSize: 24)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: citas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: (DateTime.now().isBefore(
                                  DateTime.parse(citas[index]['dia'])))
                              ? const Color.fromARGB(255, 245, 197, 194)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    //? FECHA LARGA EN ESPAÑOL

                                    Text(DateFormat.MMMMEEEEd('es_ES').format(
                                        DateTime.parse(
                                            citas[index]['dia'].toString()))),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(citas[index]['servicio']
                                        .toString()
                                        .toUpperCase()),
                                    Text(
                                        '${citas[index]['precio'].toString()} ${personaliza.moneda}'),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text('No tienes citas para este cliente'),
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'assets/images/caja-vacia.png',
                    width: MediaQuery.of(context).size.width - 250,
                  ),
                ],
              );
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
  }

  List listaCitasOrdenadasPorFecha(List<dynamic> citas) {
    citas.sort((b, a) {
      //sorting in ascending order
      return DateTime.parse(a['dia']).compareTo(DateTime.parse(b['dia']));
    });

    return citas;
  }
}

Widget nivelCliente(iniciadaSesionUsuario, usuarioAPP, cliente) {
  return FutureBuilder<dynamic>(
      future: iniciadaSesionUsuario
          ? FirebaseProvider().cargarCitasPorCliente(usuarioAPP!, cliente.id)
          : CitaListProvider().cargarCitasPorCliente(cliente.id),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SkeletonParagraph(
            style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 6,
                lineStyle: SkeletonLineStyle(
                  height: 40,
                  borderRadius: BorderRadius.circular(5),
                )),
          );
        } else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          List citas = snapshot.data;

          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData && citas.isNotEmpty) {
            return ClipRect(
              child: // si la clienta tiene mas de una cita ya no es nueva clienta
                  Banner(
                color: const Color.fromARGB(255, 217, 235, 153),
                message: 'NIVEL', // todo: SERA NUEVO,  VIP...
                //color: , // todo: CAMBIA SEGUN MESSAGE...
                location: BannerLocation.topEnd,
                child: SizedBox(
                  //decoration: decorationTarjetaNombre,
                  width: double.infinity,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [Image.asset('assets/icon/favorito.png')],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      });
}
