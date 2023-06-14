import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/config/config_personalizar_screen.dart';
import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Bienvenida extends StatefulWidget {
  const Bienvenida({Key? key}) : super(key: key);

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  final introKey = GlobalKey<IntroductionScreenState>();
  

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
      MaterialPageRoute(builder: (_) =>  HomeScreen(index: 0,)),
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
      pageColor: Colors.grey[300],
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.grey[300],
      allowImplicitScrolling: true,
      autoScrollDuration: 1,
      

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
                    onTap: () => _irInicioSesion(context, 'Login'),
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
                    onTap: () => _irInicioSesion(context, 'Registro'),
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
              child: Text('Prefiero continuar sin cuenta online',
                  style: GoogleFonts.bebasNeue(fontSize: 18)),
              onPressed: () {
                //al por primera vez al Home, guada las variables pertinenes para que la proxima vaya al Home sin pasar por la bienvenida
                // pagoProvider(); //guarda en pago (pago= false, email= prueba)

                _irHomeScreen(context);
              },
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
