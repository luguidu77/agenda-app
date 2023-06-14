// anuncios interstitial   ca-app-pub-4178469533505255/1195354253

import 'package:google_mobile_ads/google_mobile_ads.dart';

class PublicidadId {
  static String get interstitialAdUnitIdPueba {
    return "ca-app-pub-3940256099942544/1033173712";
  }

  static String get interstitialAdUnitId {
    return "ca-app-pub-4178469533505255/9833582829";
  }
}

class Publicidad {
  static publicidad(estadoPagadaApp) async {
    InterstitialAd? interstitialAd;

    if (estadoPagadaApp == 'COMPRADA' || estadoPagadaApp == 'PRUEBA_ACTIVA') {
      return null;
    } else {
      InterstitialAd.load(
        adUnitId: PublicidadId
            .interstitialAdUnitId, //interstitialAdUnitIdPueba o interstitialAdUnitId
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAd = null;

            //publicidad();
          },
        ),
      );
      return interstitialAd;
    }
  }
}
