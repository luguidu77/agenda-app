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

class _SelectionDialogState extends State<SelectionDialogContacts> {
  /// this is useful for filtering purpose
  List<Contact> filteredElements = [];

  @override
  Widget build(BuildContext context) => SimpleDialog(
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
                            ...widget.favoriteElements
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
                    : filteredElements.map((e) => SimpleDialogOption(
                          key: Key(e.displayName),
                          child: _buildOption(e),
                          onPressed: () {
                            _selectItem(e);
                          },
                        )),
              ])),
        ],
      );

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

    return const Center(child: Text('No hay contactos en su agenda'));
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements =
          widget.elements.where((e) => e.displayName.contains(s)).toList();
    });
  }

  void _selectItem(Contact e) {
    Navigator.pop(context, e);
  }
}
