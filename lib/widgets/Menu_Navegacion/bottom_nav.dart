import 'package:flutter/material.dart';

class BNavigator extends StatefulWidget {
  final Function currentIndex;
  const BNavigator({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<BNavigator> createState() => _BNavigatorState();
}

class _BNavigatorState extends State<BNavigator> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    Color colorTema = Theme.of(context).primaryColor;
    return Builder(
      builder: (context) => BottomAppBar(
          shape: const CircularNotchedRectangle(), //shape of notch
          notchMargin: 5,
          //color: Colors.blueGrey,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 78.0),
                  child: BottomNavigationBar(
                    selectedItemColor: colorTema,
                      currentIndex: index,
                      onTap: (int i) {
                        setState(() {
                          index = i;
                          widget.currentIndex(i);
                        });
                      },
                      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                      elevation: 0.0,
                      type: BottomNavigationBarType.fixed,
                      iconSize: 35.0,
                      selectedFontSize: 14.0,
                      unselectedFontSize: 12.0,
                      //  backgroundColor: Colors.red,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.calendar_month_outlined),
                            label: 'Citas'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.bar_chart), label: 'Informe'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.people_alt), label: 'Clientes'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.menu), label: 'Menu'),
                      ]),
                ),
              ),
            ],
          )),
    );
  }
}
