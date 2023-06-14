// anuncios interstitial   ca-app-pub-4178469533505255/1195354253

import 'package:flutter/material.dart';
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
  static publicidad(iniciadaSesionUsuario) async {
    InterstitialAd? interstitialAd;
    debugPrint(
        'Si hay iniciada sesion no hay publicidad ############### iniciada sesion: ${iniciadaSesionUsuario.toString()}');
    if (iniciadaSesionUsuario) {
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
