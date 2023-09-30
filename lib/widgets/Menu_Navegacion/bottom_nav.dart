import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BNavigator extends StatefulWidget {
  final int index;
  final Function currentIndex;
  const BNavigator({Key? key, required this.currentIndex, required this.index})
      : super(key: key);

  @override
  State<BNavigator> createState() => _BNavigatorState();
}

class _BNavigatorState extends State<BNavigator> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    int index = widget.index;
    Color colorTema = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            backgroundColor: Colors.transparent,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            gap: 8,
            duration: const Duration(milliseconds: 900),
            tabBackgroundColor: colorTema.withOpacity(0.3),
            color: Colors.grey,
            activeColor: Colors.white,
            curve: Curves.easeInCubic,
            tabBorderRadius: 15,

            //tabMargin: EdgeInsets.zero,
            tabs: const [
              GButton(
                icon: Icons.calendar_month_outlined,
                text: 'Citas',
              ),
              GButton(
                icon: Icons.bar_chart,
                text: 'Informe',
              ),
              GButton(
                icon: Icons.people_alt,
                text: 'Clientes',
              ),
              GButton(
                icon: Icons.menu,
                text: 'Menu',
              ),
            ],
            selectedIndex: index,
            onTabChange: (i) {
              setState(() {
                index = i;
                widget.currentIndex(i);
              });
            }),
      ),
    );
  }
}
