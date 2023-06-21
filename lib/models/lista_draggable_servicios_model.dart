class DraggableList {
  final String header;
  final List<DraggableListItem> items;

  const DraggableList({required this.header, required this.items});
}

class DraggableListItem {
  final int index;
  final String id;
  final String detalle;
  final String tiempo;
  final String title;
  final String leading;
  final String subtitle;
  final String trailing;
  final String idCategoria;

  const DraggableListItem({
    required this.id,
    required this.detalle,
    required this.tiempo,
    required this.idCategoria,
    required this.index,
    required this.title, // nombre servicio
    required this.leading, // url imagen
    required this.subtitle, // tiempo servicio
    required this.trailing, // icono mover
  });
}
