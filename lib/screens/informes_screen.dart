import 'package:agendacitas/widgets/change_theme_button.dart';
import 'package:agendacitas/widgets/line_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/personaliza_model.dart';
import '../providers/estado_pago_app_provider.dart';
import '../providers/providers.dart';

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
  List datosInforme = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
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

    // La aplicación se está ejecutando en un dispositivo móvil

    if (iniciadaSesionUsuario) {
      citas =
          await FirebaseProvider().cargarCitasAnual(emailSesionUsuario, fecha);
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
    double ene = 0;
    double feb = 0;
    double mar = 0;
    double abr = 0;
    double may = 0;
    double jun = 0;
    double jul = 0;
    double ago = 0;
    double sep = 0;
    double oct = 0;
    double nov = 0;
    double dic = 0;

    fecha.map((e) {
      String mes = e.split('-')[1];

      switch (mes) {
        case '01':
          print('mes de enero');
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          ene += double.parse(paux);

          datosInforme[0] = ene;
          facturaMes[0] = ene / 100;
          //setState(() {});

          break;
        case '02':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          feb += double.parse(paux);

          datosInforme[1] = feb;
          facturaMes[1] = feb / 100;
          setState(() {});
          break;
        case '03':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          mar += double.parse(paux);

          datosInforme[2] = mar;
          facturaMes[2] = mar / 100;
          setState(() {});
          break;
        case '04':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          abr += double.parse(paux);

          datosInforme[3] = abr;
          facturaMes[3] = abr / 100;
          setState(() {});
          break;
        case '05':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          may += double.parse(paux);

          datosInforme[4] = may;
          facturaMes[4] = may / 100;
          setState(() {});
          break;
        case '06':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          jun += double.parse(paux);

          datosInforme[5] = jun;
          facturaMes[4] = jun / 100;
          setState(() {});
          break;
        case '07':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          jul += double.parse(paux);

          datosInforme[6] = jul;
          facturaMes[4] = jul / 100;
          setState(() {});
          break;
        case '08':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          ago += double.parse(paux);

          datosInforme[7] = ago;
          facturaMes[7] = ago / 100;
          setState(() {});
          break;
        case '09':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          sep += double.parse(paux);

          datosInforme[8] = sep;
          facturaMes[8] = sep / 100;
          setState(() {});
          break;
        case '10':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          oct += double.parse(paux);

          datosInforme[9] = oct;
          facturaMes[9] = oct / 100;
          setState(() {});
          break;
        case '11':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          nov += double.parse(paux);

          datosInforme[10] = nov;
          facturaMes[10] = nov / 100;
          setState(() {});
          break;
        case '12':
          int indice = fecha.indexOf(e);
          var paux = precio[indice].toString();
          dic += double.parse(paux);

          datosInforme[11] = dic;
          facturaMes[11] = dic / 100;
          setState(() {});
          break;
      }
    }).toList();
  }

  DateFormat formatDay = DateFormat('yyyy', 'es_ES');
  DateTime fechaElegida = DateTime.now();
  String fechaTexto = '';
  bool? pagado;
  bool iniciadaSesionUsuario = false;
  String emailSesionUsuario = '';

  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar
   
    emailSesionUsuario = context.read<EstadoPagoAppProvider>().emailUsuarioApp;
    iniciadaSesionUsuario = emailSesionUsuario != '' ? true : false;
    pagado = context.read<EstadoPagoAppProvider>().estadoPagoApp != 'GRATUITA'
        ? true
        : false;
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
      // drawer: const MenuDrawer(), //menuDrawer(context),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Informes'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: const [ChangeThemeButtonWidget()]),
      body: Column(
        children: [
          _fecha(),
          _grafico(),
          _facturaTotal(),
          _datos(),
        ],
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
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: LineChartWidget(
            data: facturaMes,
          ),
        ));
  }

  _facturaTotal() {
    return const Expanded(
      flex: 1,
      child: Text('GANANCIAS MENSUALES'),
    );
  }

  _datos() {
    return Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: datosInforme.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    ' ${(DateFormat.LLLL('es_ES').format(DateTime(2017, index + 1, 1))).toUpperCase()}'),
                trailing: Text('${datosInforme[index]} ${personaliza.moneda}'),
              );
            },
          ),
        ));
  }

  void _resetListasDatos() {
    datosInforme = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    facturaMes = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    setState(() {});
  }
}
