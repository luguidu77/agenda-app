import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  TextStyle estilo = const TextStyle(fontSize: 8);
  static getTitleData() => FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          TextStyle estilo = const TextStyle(
            fontSize: 10,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          );
          switch (value.toString()) {
            case '0.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'ENE',
                  style: estilo,
                ),
              );
            case '2.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'MAR',
                  style: estilo,
                ),
              );
            case '4.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'MAY',
                  style: estilo,
                ),
              );
            case '6.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'JUL',
                  style: estilo,
                ),
              );
            case '8.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'SEP',
                  style: estilo,
                ),
              );
            case '10.0':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'NOV',
                  style: estilo,
                ),
              );
          }

          return const Text(
            '',
          );
        },
      )),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
        reservedSize: 45,
        interval: 0.1,
        getTitlesWidget: (value, meta) {
          TextStyle estilo = const TextStyle(
            fontSize: 12,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          );
          switch (value.toString()) {
            case '0.2':
              return Text(
                '200 €',
                style: estilo,
              );
            case '0.4':
              return Text(
                '400 €',
                style: estilo,
              );
            case '0.6':
              return Text(
                '600 €',
                style: estilo,
              );
            case '0.8':
              return Text(
                '800 €',
                style: estilo,
              );

            case '1.0':
              return Text(
                '1000 €',
                style: estilo,
              );
            case '1.2':
              return Text(
                '1200 €',
                style: estilo,
              );
            case '1.4':
              return Text(
                '1400 €',
                style: estilo,
              );
            case '1.6':
              return Text(
                '1600 €',
                style: estilo,
              );
            case '1.8':
              return Text(
                '1800 €',
                style: estilo,
              );
            case '2.0':
              return Text(
                '2000 €',
                style: estilo,
              );
          }
          return const Text('');
        },
      )),
      topTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
      )),
      rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 30)));
}
