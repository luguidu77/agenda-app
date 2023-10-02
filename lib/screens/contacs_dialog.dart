import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialogContacts extends StatefulWidget {
  final List<Contact> elements;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final WidgetBuilder? emptySearchBuilder;

  /// elements passed as favorite
  final List<Contact> favoriteElements;

  SelectionDialogContacts(
    this.elements,
    this.favoriteElements, {
    Key? key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
  })  : searchDecoration =
            searchDecoration.copyWith(prefixIcon: const Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

List<Contact> ordenadoFavoritos = [];

class _SelectionDialogState extends State<SelectionDialogContacts> {
  /// this is useful for filtering purpose
  List<Contact> filteredElements = [];

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: <Widget>[
          TextField(
            style: widget.searchStyle,
            decoration: widget.searchDecoration,
            onChanged: _filterElements,
          ),
        ],
      ),
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView(children: [
              widget.favoriteElements.isEmpty
                  ? const DecoratedBox(decoration: BoxDecoration())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          ...ordenadoFavoritos
                              .map(
                                (f) => SimpleDialogOption(
                                  child: _buildOption(f),
                                  onPressed: () {
                                    _selectItem(f);
                                  },
                                ),
                              )
                              .toList(),
                          const Divider()
                        ]),
              ...filteredElements.isEmpty
                  ? [_buildEmptySearchWidget(context)]
                  : filteredElements.map((e) {
                      return SimpleDialogOption(
                        key: Key(e.displayName),
                        child: _buildOption(e),
                        onPressed: () {
                          _selectItem(e);
                        },
                      );
                    }),
            ])),
      ],
    );
  }

  Widget _buildOption(Contact e) {
    return SizedBox(
      width: 400,
      child: Row(
        //direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: (e.displayName.isNotEmpty)
                ? CircleAvatar(
                    child: Text(e.displayName[0] +
                        ((e.structuredName!.middleName != '')
                            ? e.structuredName!.middleName[0]
                            : '')))
                : CircleAvatar(child: Text(e.displayName)),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            flex: 4,
            child: Text(
              e.displayName,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(
        child: Column(
      children: [
        const Text('No hay coincidencias en su agenda'),
        Image.asset(
          'assets/images/caja-vacia.png',
          width: 100,
        )
      ],
    ));
  }

  @override
  void initState() {
    ordenar(widget.elements);

    // filteredElements = widget.elements;
    // Antes de construir los elementos del diálogo, ordena la lista por orden alfabético.

    super.initState();
  }

  ordenar(List<Contact> elementos) async {
    // print(elementos.map((e) => e.displayName));
    elementos.sort((a, b) {
      // Filtrar elementos sin nombre.
      if (a.displayName.isEmpty && b.displayName.isNotEmpty) {
        return 1;
      } else if (a.displayName.isNotEmpty && b.displayName.isEmpty) {
        return -1;
      } else {
        // Comparar elementos con nombres no vacíos.
        return a.displayName.compareTo(b.displayName);
      }
    });

    // quito los contactos sin telefono
    final contactosSinTelefonosNulos = elementos
        .where((element) => element.phones.nonNulls.isNotEmpty)
        .toList();

    // quito los contactos con los primeros num. telefonos vacios
    final contactosQueTienenPrimerNumero =
        contactosSinTelefonosNulos.where((e) {
      return e.phones.first.number.isNotEmpty;
    }).toList();

    // Les paso los nombres de los contactos
    contactosQueTienenPrimerNumero.map((e) => e.displayName).toList();

    filteredElements = contactosQueTienenPrimerNumero;
    ordenadoFavoritos = contactosQueTienenPrimerNumero;

    print(contactosQueTienenPrimerNumero.map((e) => e.displayName));
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements =
          // widget.elements.where((e) => e.displayName.contains(s)).toList();
          widget.elements
              .where((element) => element.displayName.toUpperCase().contains(s))
              .toList();
    });
  }

  void _selectItem(Contact e) {
    Navigator.pop(context, e);
  }
}
