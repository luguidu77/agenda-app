import 'package:agendacitas/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/personaliza_model.dart';
import '../providers/providers.dart';
import 'style/estilo_pantalla.dart';

class InformesScreen extends StatefulWidget {
  const InformesScreen({Key? key}) : super(key: key);

  @override
  State<InformesScreen> createState() => _InformesScreenState();
}

class _InformesScreenState extends State<InformesScreen> {
  PersonalizaModel personaliza = PersonalizaModel();

  Color colorBotonFlecha = Colors.amber;
  List citas = [];
  //datosInforme son los datos para representarlos por meses
  List<double> datosInforme = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  //facturaMes son los datos que envio al grafico
  List facturaMes = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];

  DateFormat dateFormat = DateFormat("yyyy");
  double preciototal = 0.0;
  bool ocultarPrecios = true;

  int contador = 0;

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  }

  leerBasedatos() async {
    await getPersonaliza();

    var fecha = dateFormat.format(fechaElegida);

    if (_iniciadaSesionUsuario) {
      citas =
          await FirebaseProvider().cargarCitasAnual(_emailSesionUsuario, fecha);
      debugPrint('TRAE LAS CITAS ANUALES GUARDADAS EN FIREBASE');
    } else {
      citas = await CitaListProvider().cargarCitasAnual(fecha);
      debugPrint('TRAE LAS CITAS ANUALES GUARDADAS EN DISPOSITIVO');
    }

    List faux = citas.map((e) => e['fecha']).toList();
    List paux = citas.map((e) => e['precio']).toList();

    await cantidadPorMes(faux, paux);
    setState(() {});
    // await precioTotal(citas);
  }

  cantidadPorMes(List fecha, List precio) {
    fecha.map((e) {
      String mes = e.split('-')[1];

      switch (mes) {
        case '01': // ENERO

          funcionSuma(citas, '01');

          break;
        case '02': // FEBRERO
          funcionSuma(citas, '02');

          break;
        case '03': // MARZO
          funcionSuma(citas, '03');

          break;
        case '04': // ABRIL
          funcionSuma(citas, '04');

          break;
        case '05': // MAYO
          funcionSuma(citas, '05');

          break;
        case '06': // JUNIO
          funcionSuma(citas, '06');
          break;
        case '07': // JULIO
          funcionSuma(citas, '07');

          break;
        case '08': // AGOSTO
          funcionSuma(citas, '08');

          break;
        case '09': // SEPTIEMBRE
          funcionSuma(citas, '09');

          break;
        case '10': // OCTUBRE
          funcionSuma(citas, '10');

          break;
        case '11': //NOVIEMBRE
          funcionSuma(citas, '11');

          break;
        case '12': // DICIEMBRE
          funcionSuma(citas, '12');

          break;
      }
    }).toList();
  }

  void funcionSuma(citas, mes) {
    // CREA UNA LISTA CON LOS PRECIOS DE LA CITA SIEMPRE Y CUANDO LA FECHA COINCIDA CON EL MES EN CUESTION
    List precios = citas.map((e) {
      if (e['fecha'].split('-')[1] == mes) {
        return e['precio'].toDouble();
      } else {
        return 0.0;
      }
    }).toList();
    double cantidad = 0.0;
    List preciosAux = precios;

    // SUMA DE TODOS LOS PRECIOS DE LA LISTA
    cantidad = preciosAux
        .reduce((valorAnterior, valorActual) => valorAnterior + valorActual);

    // AGREGA AL MES CORRESPONDIENTE LA CANTIDAD TOTAL
    datosInforme[int.parse(mes) - 1] = cantidad;
    facturaMes[int.parse(mes) - 1] = cantidad / 100; // formatea dos decimales
  }

  DateFormat formatDay = DateFormat('yyyy', 'es_ES');
  DateTime fechaElegida = DateTime.now();
  String fechaTexto = '';
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();
    //Publicidad().publicidad();
    fechaTexto = formatDay.format(fechaElegida);
    leerBasedatos();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _fecha(),
            _grafico(),
            const Divider(),
            Text('GANANCIAS MENSUALES', style: subTituloEstilo),
            _datos(),
          ],
        ),
      ),
    );
  }

  _fecha() {
    // List<ClienteModel> nombreCliente = clientes();
    // DateTime initialDate = DateTime.now();
    // DateTime firstDate = initialDate.subtract(const Duration(days: 365));
    // DateTime lastDate = initialDate.add(const Duration(days: 365));
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => {
              setState(() {
                fechaTexto = formatDay
                    .format(fechaElegida.subtract(const Duration(days: 365)));
                fechaElegida = fechaElegida.subtract(const Duration(days: 365));
                _resetListasDatos();
                leerBasedatos();
              })
            },
            icon: const Icon(Icons.arrow_left_outlined),
            iconSize: 50,
            color: colorBotonFlecha,
          ),
          GestureDetector(
            onTap: () {
              //todo picker date
              /* showMaterialDatePicker(
                context: context,
                title: 'Buscar Citas',
                selectedDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                onChanged: (value) {
                  setState(() {
                    fechaTexto = formatDay.format(value);
                    fechaElegida = (value);
                    leerBasedatos();
                  });
                }); */
            },
            child: Text(
              fechaTexto,
              style: const TextStyle(fontSize: 22.0),
            ),
          ),
          IconButton(
            onPressed: () => {
              setState(() {
                fechaTexto = formatDay
                    .format(fechaElegida.add(const Duration(days: 365)));
                fechaElegida = fechaElegida.add(const Duration(days: 365));
                _resetListasDatos();
                leerBasedatos();
              })
            },
            icon: const Icon(Icons.arrow_right_outlined),
            iconSize: 50,
            color: colorBotonFlecha,
          ),
        ],
      ),
    );
  }

  _grafico() {
    return Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 162, 238, 166),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: SizedBox(
              width: 200,
              child: LineChartWidget(
                data: facturaMes,
              ),
            ),
          ),
        ));
  }

  _datos() {
    return Expanded(
        flex: 7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: datosInforme.length,
            itemBuilder: (context, index) {
              return _tarjetasMensuales(index);
            },
          ),
        ));
  }

  _tarjetasMensuales(index) {
    return Card(
      color: const Color.fromARGB(87, 173, 247, 247),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ' ${(DateFormat.LLLL('es_ES').format(DateTime(2017, index + 1, 1))).toUpperCase()}',
              style: textoEstilo,
            ),
            Text(
              '${datosInforme[index]}  ${personaliza.moneda}',
              style: textoEstilo,
            )
          ],
        ),
      ),
    );
  }

  void _resetListasDatos() {
    datosInforme = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    facturaMes = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    setState(() {});
  }
}
