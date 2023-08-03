import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';
import '../screens.dart';
import 'utils/.estilos.dart';

class CreacionCitaConfirmar extends StatefulWidget {
  const CreacionCitaConfirmar({super.key});

  @override
  State<CreacionCitaConfirmar> createState() => _CreacionCitaConfirmarState();
}

class _CreacionCitaConfirmarState extends State<CreacionCitaConfirmar> {
  final clienteEjemplo = ClienteModel();

  @override
  Widget build(BuildContext context) {
    clienteEjemplo.nombre = 'pedro';
    clienteEjemplo.telefono = '8989898989';
    return SafeArea(
        child: Scaffold(
            body: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(28.0),
              child: Text(
                'Confirmar cita',
                style: titulo,
              ),
            ),
          ),
          Expanded(flex: 1, child: verclientes(context, [clienteEjemplo])),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('03 de agosto de 2023'),
                  ElevatedButton(onPressed: null, child: Text('Modificar'))
                ],
              )),
          Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.blue, // Color del borde izquierdo
                      width: 5, // Ancho del borde izquierdo
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'servicio ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [Text('19:00 - 20-00'), Text('1h')],
                      ),
                      Text('30€')
                    ],
                  ),
                ),
              )),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('añade otro servicio'),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.plus_one_sharp),
                  label: Text(''),
                )
              ],
            ),
          )),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Precio total 33€ (1h)'),
                ElevatedButton(onPressed: null, child: Text('Confirmar cita'))
              ],
            ),
          ),
        ],
      ),
    )));
  }

  _detallesCliente() {
    return Card(
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _foto(),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'nombre'!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          Comunicaciones.hacerLlamadaTelefonica(
                              'telefono'.toString());
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text(
                          'llamar',
                          style: TextStyle(fontSize: 12),
                        )),
                    ElevatedButton.icon(
                        onPressed: () {
                          Comunicaciones.enviarEmail('email'.toString());
                        },
                        icon: const Icon(Icons.mail),
                        label: const Text(
                          'Enviar un email',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  verclientes(context, List<ClienteModel> listaClientes) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Card(
            child: ClipRect(
              child: SizedBox(
                //Banner aqui -----------------------------------------------
                child: Column(
                  children: [
                    ListTile(
                      leading: /* _iniciadaSesionUsuario */
                          false && listaClientes[index].foto! != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(150.0),
                                  child: Image.network(
                                    listaClientes[index].foto!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(150.0),
                                  child: Image.asset(
                                    "./assets/images/nofoto.jpg",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      title: Text(listaClientes[index].nombre.toString()),
                      subtitle: Text(listaClientes[index].telefono.toString()),
                      trailing: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorbotones,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, 'creacionCitaServicio',
                                arguments: listaClientes[index]);
/*                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientaStep(
                                      clienteParametro: ClienteModel(
                                          nombre: listaClientes[index].nombre,
                                          telefono:
                                              listaClientes[index].telefono,
                                          email: listaClientes[index].email,
                                          nota: listaClientes[index].nota))),
                            ); */
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: const Text('CITAR')),
                    ),
                    Row(
                      children: [
                        //? BOTON TELEFONO DE EDICION RAPIDA DE NOMBRE Y TELEFONO
                        TextButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorbotones,
                            ),
                            onPressed: () => setState(() {
                                  /*  _cardConfigCliente(
                                      context, listaClientes[index]); */
                                }),
                            icon: const Icon(Icons.phonelink_setup_sharp),
                            label: const Text('')),
                        //? BOTON ACCESO A DATOS DEL CLIENTE Y SU HISTORIAL
                        TextButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorbotones,
                            ),
                            onPressed: () {
                              /*  //1ºrefresco los datos cliente por si han sido editados
                              datosClientes(_emailSesionUsuario);
                              //2ºn navega a Ficha Cliente con sus datos
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double>
                                                secondaryAnimation) =>
                                        FichaClienteScreen(
                                          clienteParametro: ClienteModel(
                                              id: listaClientes[index]
                                                  .id
                                                  .toString(),
                                              nombre:
                                                  listaClientes[index].nombre,
                                              telefono:
                                                  listaClientes[index].telefono,
                                              email: listaClientes[index].email,
                                              foto: listaClientes[index].foto,
                                              nota: listaClientes[index].nota),
                                        ),
                                    transitionDuration: // ? TIEMPO PARA QUE SE APRECIE EL HERO DE LA FOTO
                                        const Duration(milliseconds: 600)),
                              ); */
                            },
                            icon: const Icon(Icons.card_travel_outlined),
                            label: const Text(''))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  ClipRRect _foto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(150.0),
      child: /* foto != ''
          ? Image.network(
              foto,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          :  */
          Image.asset(
        "./assets/images/nofoto.jpg",
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}
