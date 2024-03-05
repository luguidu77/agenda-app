import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/config/config_personalizar_screen.dart';
import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/elimina_cita.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../utils/utils.dart';

class Bienvenida extends StatefulWidget {
  const Bienvenida({Key? key}) : super(key: key);

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  bool leidoPrivacidad = false;
  final introKey = GlobalKey<IntroductionScreenState>();

  void toggleLeido() {
    setState(() {
      leidoPrivacidad = !leidoPrivacidad;
    });
  }

  void _irInicioSesion(context, String inicioCrear) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => RegistroUsuarioScreen(
                registroLogin: inicioCrear,
                usuarioAPP: '',
              )),
    );
  }

  void _irHomeScreen(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => HomeScreen(
                index: 0,
                myBnB: 0,
              )),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 450]) {
    return Padding(
      padding: const EdgeInsets.only(top: 58.0),
      child: Image.asset('./assets/bienvenida_img/$assetName', width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    var pageDecoration = PageDecoration(
      imageFlex: 1,
      titlePadding: const EdgeInsets.only(top: 24.0),
      bodyFlex: 5,
      titleTextStyle: GoogleFonts.bebasNeue(
          fontSize:
              40), //TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
      pageColor: colorFondo,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.grey[300],
      allowImplicitScrolling: true,
      //autoScrollDuration: 500, // este da error  PageController.page cannot be accessed before a PageView is built with it

      /*  globalHeader: Align(
        alignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildImage('icon.png', 150),
          ),
        ),
      ), */
      globalFooter: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => leidoPrivacidad
                        ? _irInicioSesion(context, 'Login')
                        : mensajeError(context,
                            'No se ha aceptado la política de privacidad'),
                    //

                    child: Container(
                      height: 60,
                      color: const Color.fromARGB(255, 167, 219, 157),
                      child: Center(
                        child: Text('INICIA SESION',
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => leidoPrivacidad
                        ? _irInicioSesion(context, 'Registro')
                        : mensajeError(context,
                            'No se ha aceptado la política de privacidad'),
                    //

                    child: Container(
                      height: 60,
                      color: Colors.deepPurple[200],
                      child: Center(
                        child: Text('PRUEBA GRATUITA',
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // Bordes cuadrados
                ),
              ),
              child: Text('Prefiero cuenta gratuita con publicidad',
                  style: GoogleFonts.bebasNeue(fontSize: 18)),
              onPressed: () {
                //al por primera vez al Home, guada las variables pertinenes para que la proxima vaya al Home sin pasar por la bienvenida
                // pagoProvider(); //guarda en pago (pago= false, email= prueba)

                leidoPrivacidad
                    ? _irHomeScreen(context)
                    : mensajeError(
                        context, 'No se ha aceptado la política de privacidad');
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(value: leidoPrivacidad, onChanged: null),
                CheckConsentimiento(
                  onPolicyAccepted: (accepted) {
                    setState(() {});
                    leidoPrivacidad = accepted;
                  },
                )
              ],
            ),
          ),
        ],
      ),
      pages: [
        PageViewModel(
          title: "Te presento la aplicación para citas profesionales",
          body:
              "Fideliza a más clientes y tenlo todo bajo control con los informes, la cartera de clientes y mucho más!.",
          image: _buildImage('icon.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Waaau, estoy visible en la marketplace!",
          body:
              "Publica tus servicios o tus habilidades online para que nuevos clientes te conozcan, te valoren y reserven contigo.",
          image: _buildImage('markets.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Una nueva cita online! chachi piruli!",
          body:
              "Desde el market place o de desde la app para clientes, cualquiera puede reservar en cualquier momento del día.",
          image: _buildImage('reserva.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Cita reservada! y ahora que?",
          body:
              "Envía a tus clientes un email, un whatsapp o un sms con la cita concertada. ¿Y si programamos el envío de un email el día anterior para recordarsela?",
          image: _buildImage('compartir.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Vamos a configurar lo básico",
          // body:

          image: _buildImage('configurar.png'),
          bodyWidget: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Un color que te guste, el código telefónico de tu país, tiempo de recordatorio para tu próxima cita... y poco más!',
                style: TextStyle(fontSize: 19),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  introKey.currentState?.animateScroll(0);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConfigPersonalizar()));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Personalizar ahora',
                    style:
                        GoogleFonts.lobster(fontSize: 24, color: Colors.white)),
              ),
              const SizedBox(
                height: 10,
              ),
              /*  ElevatedButton(
                onPressed: () {
                  introKey.currentState?.animateScroll(0);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'El código telefónico de tu país',
                  style: TextStyle(color: Colors.white),
                ),
              ), */
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 9,
            imageFlex: 2,
            safeArea: 0,
          ),
        ),
        /*  PageViewModel(
          title: "Title of last page - reversed",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Click on ", style: bodyStyle),
              Icon(Icons.edit),
              Text(" to edit a post", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('img1.jpg'),
          reverse: true,
        ), */
        /*  PageViewModel(
          title: "Full Screen Page",
          body:
              "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
          image: _buildFullscreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 4,
            imageFlex: 3,
            safeArea: 100,
          ),
        ), */
      ],
      onDone: () => _irInicioSesion(context, 'Login'),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      //back:
      /* const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ) */

      skip:
          Container(), //const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next:
          Container() /*  const Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ) */
      ,
      done:
          Container(), //const Text('Listo', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(68.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        colors: [
          // ? colores para cada punto, debe ser IGUAL en numero que numero de paginas tenga
          Colors.white,
          Colors.white,
          Colors.white,
          Colors.white,
          Colors.white,
        ],
        activeColor: Colors.white,
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      /*   dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ), */
    );
  }

  pagoProvider() async {
    await PagoProvider().guardaPagado(false, 'prueba');
  }
}

class CheckConsentimiento extends StatefulWidget {
  final Function(bool) onPolicyAccepted;
  const CheckConsentimiento({super.key, required this.onPolicyAccepted});

  @override
  State<CheckConsentimiento> createState() => _CheckConsentimientoState();
}

class _CheckConsentimientoState extends State<CheckConsentimiento> {
  bool leido = false;
  void toggleLeido() {
    leido = !leido;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _mostrarDialogo(context);
      },
      child: const Text('Política de Privacidad'),
    );
  }

  _mostrarDialogo(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Política de Privacidad',
                style: GoogleFonts.bebasNeue(fontSize: 18)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                    child: ListBody(
                  children: [
                    const Text(
                      'Esta página se utiliza para informar a los visitantes sobre mis políticas con respecto a la recopilación, uso y divulgación de Información Personal en caso de que alguien decida utilizar mi Servicio.\n\n'
                      'Juan Manuel Lugo Durán creó la aplicación Agenda de Citas como una aplicación gratuita con publicidad de Admob almacenando los datos en tu propio dispositivo y con la opción de la compra de la misma, la cual almacena los datos en Firestore de Google.\n\n'
                      'Si decides utilizar mi Servicio, aceptas la recopilación y uso de información en relación con esta política. La Información Personal que recolecto se utiliza para proporcionar y mejorar el Servicio. No utilizaré ni compartiré tu información con nadie, excepto según se describe en esta Política de Privacidad.\n\n'
                      'Recopilación y Uso de Información\n\n'
                      'Entre los tipos de Datos Personales que recopila esta Aplicación, por sí misma o a través de terceros, se encuentran: permiso de contactos; permiso de cámara; cookies; Datos de uso; dirección de correo electrónico; contraseña; identificadores únicos de dispositivos para publicidad (ID de anunciante de Google o IDFA, por ejemplo).\n\n'
                      'Detalles completos sobre cada tipo de Datos Personales recopilados se proporcionan en las secciones dedicadas de esta política de privacidad o mediante textos de explicación específicos mostrados antes de la recopilación de Datos. Los Datos Personales pueden ser proporcionados libremente por el Usuario, o, en caso de Datos de Uso, recopilados automáticamente al utilizar esta Aplicación. A menos que se especifique lo contrario, todos los Datos solicitados por esta Aplicación son obligatorios y la falta de provisión de estos Datos puede hacer imposible que esta Aplicación proporcione sus servicios. En casos en los que esta Aplicación especifique expresamente que algunos Datos no son obligatorios, los Usuarios son libres de no comunicar estos Datos sin que ello tenga consecuencias para la disponibilidad o el funcionamiento del Servicio. Los Usuarios que no estén seguros acerca de qué Datos Personales son obligatorios pueden contactar al Propietario. Cualquier uso de Cookies – o de otras herramientas de seguimiento – por esta Aplicación o por los propietarios de servicios de terceros utilizados por esta Aplicación tiene como fin proporcionar el Servicio requerido por el Usuario, además de cualquier otro fin descrito en el presente documento.\n\n'
                      'Los Usuarios son responsables de cualquier Datos Personales de terceros obtenidos, publicados o compartidos a través de esta Aplicación.\n\n'
                      'Enlace a la política de privacidad de los proveedores de servicios de terceros utilizados por la aplicación:\n\n'
                      'Servicios de Google Play\n'
                      'AdMob\n'
                      'Google Analytics para Firebase\n'
                      'Datos de Registro\n\n'
                      'Quiero informarte que cada vez que utilizas mi Servicio, en caso de un error en la aplicación, recolecto datos e información (a través de productos de terceros) en tu teléfono llamados Datos de Registro. Estos Datos de Registro pueden incluir información como la dirección IP de tu dispositivo, nombre del dispositivo, versión del sistema operativo, la configuración de la aplicación al utilizar mi Servicio, la fecha y hora de tu uso del Servicio y otras estadísticas.\n\n'
                      'Cookies\n\n'
                      'Las cookies son archivos con una pequeña cantidad de datos que son comúnmente utilizados como identificadores únicos anónimos. Estos son enviados a tu navegador desde los sitios web que visitas y se almacenan en la memoria interna de tu dispositivo.\n\n'
                      'Este Servicio no utiliza estas «cookies» explícitamente. Sin embargo, la aplicación puede utilizar código y bibliotecas de terceros que utilizan «cookies» para recolectar información y mejorar sus servicios. Tienes la opción de aceptar o rechazar estas cookies y saber cuándo se está enviando una cookie a tu dispositivo. Si optas por rechazar nuestras cookies, es posible que no puedas utilizar algunas partes de este Servicio.\n\n'
                      'Proveedores de Servicios\n\n'
                      'Puedo emplear a empresas e individuos de terceros por las siguientes razones:\n\n'
                      'Para facilitar nuestro Servicio;\n'
                      'Para proporcionar el Servicio en nuestro nombre;\n'
                      'Para realizar servicios relacionados con el Servicio; o\n'
                      'Para ayudarnos a analizar cómo se utiliza nuestro Servicio.\n\n'
                      'Quiero informar a los usuarios de este Servicio que estos terceros tienen acceso a su Información Personal. La razón es realizar las tareas asignadas a ellos en nuestro nombre. Sin embargo, están obligados a no divulgar ni utilizar la información para ningún otro fin.\n\n'
                      'Modo y lugar de procesamiento de los Datos\n\n'
                      'Métodos de procesamiento Los Datos se procesan a través de Firestore de Google, siguiendo procedimientos organizativos y modos estrictamente relacionados con los propósitos indicados. El Propietario toma medidas de seguridad adecuadas para evitar el acceso no autorizado, la divulgación, modificación o destrucción no autorizada de los Datos. Además del Propietario, en algunos casos, los Datos pueden ser accesibles para ciertos tipos de personas a cargo, involucradas en la operación de esta Aplicación (administración, ventas, marketing, legal, administración del sistema) o partes externas (como proveedores de servicios técnicos de terceros, transportistas de correo, proveedores de alojamiento, empresas de TI, agencias de comunicación) designadas, si es necesario, como Procesadores de Datos por parte del Propietario. La lista actualizada de estas partes puede ser solicitada en cualquier momento al Propietario.\n\n'
                      'Dependiendo de la ubicación del Usuario, las transferencias de datos pueden implicar la transferencia de los Datos del Usuario a un país distinto al suyo. Para obtener más información sobre el lugar de procesamiento de dichos Datos transferidos, los Usuarios pueden consultar la sección que contiene detalles sobre el procesamiento de Datos Personales.\n\n'
                      'Tiempo de retención A menos que se especifique lo contrario en este documento, los Datos Personales se procesarán y almacenarán durante el tiempo que sea necesario para los fines para los que se recopilaron y pueden conservarse por más tiempo debido a una obligación legal aplicable o basada en el consentimiento de los Usuarios.\n\n'
                      'Permisos del dispositivo para el acceso a Datos Personales\n\n'
                      'Dependiendo del dispositivo específico del Usuario, esta Aplicación puede solicitar ciertos permisos que le permitan acceder a los Datos del dispositivo del Usuario, según se describe a continuación.\n\n'
                      'Por defecto, estos permisos deben ser otorgados por el Usuario antes de que la información respectiva pueda ser accedida. Una vez otorgado el permiso, el Usuario puede revocarlo en cualquier momento. Para revocar estos permisos, los Usuarios pueden consultar la configuración del dispositivo o contactar al Propietario para obtener soporte en los detalles de contacto proporcionados en el presente documento. El procedimiento exacto para controlar los permisos de la aplicación puede depender del dispositivo y del software del Usuario.\n\n'
                      'Por favor, ten en cuenta que la revocación de dichos permisos puede afectar el funcionamiento adecuado de esta Aplicación.\n\n'
                      'Si el Usuario otorga alguno de los permisos enumerados a continuación, los respectivos Datos Personales pueden ser procesados (es decir, accedidos, modificados o eliminados) por esta Aplicación.\n\n'
                      'Permiso de ubicación aproximada (continua)\n\n'
                      'Se utiliza para acceder a la ubicación aproximada del dispositivo del Usuario. Esta Aplicación puede recopilar, utilizar y compartir Datos de ubicación del Usuario para proporcionar servicios basados en la ubicación.\n\n'
                      'Permiso de cámara\n\n'
                      'Se utiliza para acceder a la cámara o capturar imágenes y videos desde el dispositivo.\n\n'
                      'Permiso de contactos\n\n'
                      'Se utiliza para acceder a los contactos y perfiles en el dispositivo del Usuario, incluido el cambio de entradas.\n\n'
                      'Seguridad\n\n'
                      'Valoramos tu confianza al proporcionarnos tu Información Personal, por lo que nos esforzamos por utilizar medios comercialmente aceptables para protegerla. Pero recuerda que ningún método de transmisión por internet o método de almacenamiento electrónico es 100% seguro y confiable, y no puedo garantizar su absoluta seguridad.\n\n'
                      'Enlaces a Otros Sitios\n\n'
                      'Este Servicio puede contener enlaces a otros sitios. Si haces clic en un enlace de un tercero, serás dirigido a ese sitio. Ten en cuenta que estos sitios externos no son operados por mí. Por lo tanto, te recomiendo encarecidamente que revises la Política de Privacidad de estos sitios web. No tengo control sobre y no asumo ninguna responsabilidad por el contenido, las políticas de privacidad o las prácticas de sitios web o servicios de terceros.\n\n'
                      'Publicidad\n\n'
                      'Este tipo de servicio permite que los Datos del Usuario se utilicen con fines de comunicación publicitaria. Estas comunicaciones se muestran en forma de banners y otros anuncios en esta Aplicación, posiblemente basados en los intereses del Usuario.\n'
                      'Esto no significa que todos los Datos Personales se utilicen para este fin. La información y condiciones de uso se muestran a continuación.\n'
                      'Algunos de los servicios enumerados a continuación pueden utilizar Trackers para identificar a los Usuarios o pueden utilizar la técnica de retargeting conductual, es decir, mostrar anuncios adaptados a los intereses y comportamiento del Usuario, incluso aquellos detectados fuera de esta Aplicación. Para obtener más información, consulte las políticas de privacidad de los servicios pertinentes.\n'
                      'Los servicios de este tipo suelen ofrecer la posibilidad de optar por no ser rastreados. Además de cualquier función de exclusión ofrecida por alguno de los servicios a continuación, los Usuarios pueden obtener más información sobre cómo optar de manera general por no participar en la publicidad basada en intereses dentro de la sección dedicada «Cómo optar por no participar en la publicidad basada en intereses» en este documento.\n\n'
                      'AdMob\n'
                      'AdMob es un servicio de publicidad proporcionado por Google LLC o por Google Ireland Limited, dependiendo de cómo el Propietario gestiona el procesamiento de Datos.\n'
                      'Para comprender el uso de Datos de Google, consulte la política de socios de Google.\n'
                      'Datos Personales procesados: Cookies; identificadores únicos de dispositivos para publicidad (ID de anunciante de Google o IDFA, por ejemplo); Datos de uso.\n\n'
                      'Lugar de procesamiento: Estados Unidos – Política de privacidad – Optar por excluirse; Irlanda – Política de privacidad.\n\n'
                      'Google Ad Manager\n'
                      'Google Ad Manager es un servicio de publicidad proporcionado por Google LLC o por Google Ireland Limited, dependiendo de cómo el Propietario gestiona el procesamiento de Datos, que permite al Propietario ejecutar campañas publicitarias junto con redes publicitarias externas con las que el Propietario, a menos que se especifique lo contrario en este documento, no tiene una relación directa. Para optar por no ser rastreado por varias redes publicitarias, los Usuarios pueden hacer uso de Youronlinechoices. Para comprender el uso de datos de Google, consulte la política de socios de Google.\n'
                      'Este servicio utiliza la «Cookie DoubleClick», que realiza un seguimiento del uso de esta Aplicación y del comportamiento del Usuario con respecto a los anuncios, productos y servicios ofrecidos. Los Usuarios pueden decidir desactivar todas las Cookies de DoubleClick visitando: Configuración de anuncios de Google.\n'
                      'Datos Personales procesados: Cookies; Datos de uso.\n\n'
                      'Lugar de procesamiento: Estados Unidos – Política de privacidad; Irlanda – Política de privacidad.\n\n'
                      'Privacidad de los Niños\n\n'
                      'Estos Servicios no están dirigidos a personas menores de 13 años. No recolecto conscientemente información de identificación personal de niños menores de 13 años. En caso de que descubra que un niño menor de 13 años me ha proporcionado información personal, eliminaré inmediatamente esa información de nuestros servidores. Si eres padre o tutor y estás al tanto de que tu hijo nos ha proporcionado información personal, contáctame para que pueda tomar las acciones necesarias.\n\n'
                      'Cambios en Esta Política de Privacidad\n\n'
                      'Puedo actualizar nuestra Política de Privacidad de vez en cuando. Por lo tanto, se te recomienda que revises esta página periódicamente para cualquier cambio. Te notificaré cualquier cambio publicando la nueva Política de Privacidad en esta página.\n\n'
                      'Esta política es efectiva a partir del 28 de febrero de 2024.\n\n'
                      'Contáctanos\n\n'
                      'Si tienes alguna pregunta o sugerencia sobre nuestra Política de Privacidad, no dudes en contactarnos en agendadecitaspro@gmail.com',
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: leido,
                            onChanged: (value) {
                              setState(() {});
                              toggleLeido();
                            }),
                        TextButton(
                          child: Text(
                              leido ? 'Estoy deacuerdo' : 'No estoy deacuerdo',
                              style: GoogleFonts.bebasNeue(fontSize: 18)),
                          onPressed: () {
                            //al por primera vez al Home, guada las variables pertinenes para que la proxima vaya al Home sin pasar por la bienvenida
                            // pagoProvider(); //guarda en pago (pago= false, email= prueba)

                            Navigator.of(context).pop();
                            widget.onPolicyAccepted(leido);
                          },
                        ),
                      ],
                    ),
                  ],
                ));
              },
            ),
          );
        });
  }
}




/* class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text("This is the screen after Introduction")),
    );
  }
} */
