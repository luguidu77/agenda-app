import 'package:flutter/material.dart';


class BarraProgreso {
  progreso(context, double progreso, Color color) {
    return SizedBox(
      width: 290,
      child: Column(
        children: [
          const SizedBox(
            child: Text(
              'Creando una cita',
              style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: SizedBox(
                  child: LinearProgressIndicator(
                    color: color,
                    minHeight: 10,
                    value: progreso,
                    backgroundColor: const Color.fromARGB(255, 245, 230, 230),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', ModalRoute.withName('/'))
                },
                icon: Image.asset(
                  './assets/icon/cancelar-evento.png',
                  width: 50,
                  height: 50,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
