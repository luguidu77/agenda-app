import 'package:flutter/material.dart';

class ItemsFiltersCitas extends StatefulWidget {
  final Function(String) onFilterChange;

  const ItemsFiltersCitas({Key? key, required this.onFilterChange})
      : super(key: key);

  @override
  State<ItemsFiltersCitas> createState() => _ItemsFiltersCitasState();
}

class _ItemsFiltersCitasState extends State<ItemsFiltersCitas> {
  var _isSelectedTodas = true;
  var _isSelectedPendiente = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Wrap(spacing: 5, children: [
            const SizedBox(height: 30),
            FilterChip(
              selected: _isSelectedTodas,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: Colors.blue,
                ),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8.0),
              label: const Text(
                'VER TODAS',
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.4,
                  fontWeight: FontWeight.normal,
                  color: Colors.blue,
                ),
              ),
              onSelected: (bool value) {
                setState(() {});
                _isSelectedTodas = value;
                _isSelectedPendiente = !value;
                widget.onFilterChange('TODAS');
              },
            ),
            FilterChip(
              selected: _isSelectedPendiente,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: Colors.blue,
                ),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8.0),
              label: const Text(
                'VER PENDIENTES',
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.4,
                  fontWeight: FontWeight.normal,
                  color: Colors.blue,
                ),
              ),
              onSelected: (bool value) {
                setState(() {});
                _isSelectedPendiente = value;
                _isSelectedTodas = !value;

                widget.onFilterChange('PENDIENTES');
              },
            ),
          ]),
        ],
      ),
    );
  }
}
