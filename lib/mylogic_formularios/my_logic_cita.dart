import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/perfil_model.dart';
import 'package:agendacitas/providers/cita_list_provider.dart';
import 'package:flutter/material.dart';

class MyLogicNoDisponible {
  MyLogicNoDisponible(this.citaInicio, this.citaFin, this.asunto);
  final CitaModel citaInicio;
  final CitaModel citaFin;
  final String asunto;

  // fecha inicio
  final textControllerDiaInicio = TextEditingController();
  final textControllerHoraInicio = TextEditingController();

  //fecha final
  final textControllerDiaFinal = TextEditingController();
  final textControllerHoraFinal = TextEditingController();

  //fecha asunto
  final textControllerAsunto = TextEditingController();

  void save() {}

  void init() {
    if (citaInicio.dia == null) {
      textControllerDiaInicio.text = '';
      textControllerHoraInicio.text = '';
      textControllerDiaFinal.text = '';
      textControllerHoraFinal.text = '';
      textControllerAsunto.text = '';
    } else {
      textControllerDiaInicio.text = citaInicio.dia.toString();
      textControllerHoraInicio.text = citaInicio.horaFinal.toString();
      textControllerDiaFinal.text = citaFin.dia.toString();
      textControllerHoraFinal.text = citaFin.horaFinal.toString();
      textControllerAsunto.text = asunto.toString();
    }
  }
}

class MyLogicCliente {
  MyLogicCliente(this.cliente);
  final ClienteModel? cliente;

  final textControllerNombre = TextEditingController();
  final textControllerTelefono = TextEditingController();
  final textControllerEmail = TextEditingController();
  final textControllerFoto = TextEditingController();
  final textControllerNota = TextEditingController();

  void save() {}

  void init() {
    if (cliente!.nombre == null) {
      textControllerNombre.text = '';
      textControllerTelefono.text = '';
      textControllerEmail.text = '';
      textControllerFoto.text = '';
      textControllerNota.text = '';
    } else {
      textControllerNombre.text = cliente!.nombre.toString();
      textControllerTelefono.text = cliente!.telefono.toString();
      textControllerEmail.text = cliente!.email.toString();
      textControllerFoto.text = cliente!.foto.toString();
      textControllerNota.text = cliente!.nota.toString();
    }
  }

  void dispose() {
    textControllerNombre.dispose();
    textControllerTelefono.dispose();
    textControllerEmail.dispose();
    textControllerFoto.dispose();
    textControllerNota.dispose();

    debugPrint(
        '-------------------------------------------Al cerrar confirmar_step.dart -> dispose---------libero memoria textController formulario step cliente');
  }
}

class MyLogicServicio {
  MyLogicServicio(this.servicio);
  final ServicioModel servicio;

  final textControllerPrecio = TextEditingController();
  final textControllerServicio = TextEditingController();
  final textControllerTiempo = TextEditingController();
  final textControllerDetalle = TextEditingController();

  void save() {}

  void init() {
    if (servicio.servicio == null) {
      textControllerPrecio.text = '';
      textControllerServicio.text = '';
      textControllerTiempo.text = '';
      textControllerDetalle.text = '';
    } else {
      textControllerPrecio.text = servicio.precio.toString();
      textControllerServicio.text = servicio.servicio.toString();
      textControllerTiempo.text = servicio.tiempo.toString();
      textControllerDetalle.text = servicio.detalle.toString();
    }
  }

  void dispose() {
    textControllerPrecio.dispose();
    textControllerServicio.dispose();
    textControllerTiempo.dispose();
    textControllerDetalle.dispose();

    debugPrint(
        '-------------------------------------------Al cerrar confirmar_step.dart -> dispose---------libero memoria textController formulario step servicio');
  }
}

class MyLogicCita {
  MyLogicCita(this.cita);
  final CitaModel cita;

  var citaContext = CitaListProvider().getCitaElegida;

  final textControllerDia = TextEditingController();
  final textControllerHora = TextEditingController();

  void save() {}

  void init() {
    if (cita.dia == null) {
      textControllerDia.text = '';
      textControllerHora.text = '';
    } else {
      textControllerDia.text = cita.dia.toString();
      textControllerHora.text = cita.horaInicio.toString();
      //  textControllerHora.text = cita.horaFinal.toString();
    }
  }

  void dispose() {
    textControllerDia.dispose();
    textControllerHora.dispose();

    debugPrint(
        '-------------------------------------------Al cerrar confirmar_step.dart -> dispose---------libero memoria textController formulario step cita');
  }
}



class MyLogicUsuarioAPP {
  MyLogicUsuarioAPP(this.perfilUsuarioApp);
  final PerfilModel? perfilUsuarioApp;

  final textControllerDenominacion = TextEditingController();
  final textControllerTelefono = TextEditingController();
  final textControllerFoto = TextEditingController();
  final textControllerDescripcion = TextEditingController();
  final textControllerFacebook = TextEditingController();
  final textControllerInstagram = TextEditingController();
  final textControllerWebsite = TextEditingController();
  final textControllerUbicacion = TextEditingController();

  final textControllerMoneda = TextEditingController();
  final textControllerServicios = TextEditingController();
  final textControllerCiudad = TextEditingController();
  final textControllerHorarios = TextEditingController();
  final textControllerInformacion = TextEditingController();
  final textControllerNormas = TextEditingController();
  final textControllerLatitud = TextEditingController();
  final textControllerLongitud = TextEditingController();

  void save() {}

  void init() {
    if (perfilUsuarioApp!.denominacion == null) {
      textControllerDenominacion.text = '';
      textControllerTelefono.text = '';
      textControllerFoto.text = '';
      textControllerDescripcion.text = '';
      textControllerFacebook.text = '';
      textControllerInstagram.text = '';
      textControllerWebsite.text = '';
      textControllerUbicacion.text = '';
    } else {
      textControllerDenominacion.text =
          perfilUsuarioApp!.denominacion.toString();
      textControllerTelefono.text = perfilUsuarioApp!.telefono.toString();
      textControllerFoto.text = perfilUsuarioApp!.foto.toString();
      textControllerDescripcion.text = perfilUsuarioApp!.descripcion.toString();
      textControllerFacebook.text = perfilUsuarioApp!.facebook.toString();
      textControllerInstagram.text = perfilUsuarioApp!.instagram.toString();
      textControllerWebsite.text = perfilUsuarioApp!.website.toString();
      textControllerUbicacion.text = perfilUsuarioApp!.ubicacion.toString();
    }
  }
}


class MyLogicServicioFB {
  MyLogicServicioFB(this.servicioFB);
  final ServicioModelFB servicioFB;

  final textControllerPrecio = TextEditingController();
  final textControllerServicio = TextEditingController();
  final textControllerTiempo = TextEditingController();
  final textControllerDetalle = TextEditingController();
  final textControllerCategoria = TextEditingController();

  void save() {}

  void init() {
    if (servicioFB.servicio == null) {
      textControllerPrecio.text = '';
      textControllerServicio.text = '';
      textControllerTiempo.text = '';
      textControllerDetalle.text = '';
      textControllerCategoria.text = '';
    } else {
      textControllerPrecio.text = servicioFB.precio.toString();
      textControllerServicio.text = servicioFB.servicio.toString();
      textControllerTiempo.text = servicioFB.tiempo.toString();
      textControllerDetalle.text = servicioFB.detalle.toString();
      textControllerCategoria.text = servicioFB.idCategoria.toString();
    }
  }
}

class MyLogicCategoriaServicio {
  MyLogicCategoriaServicio(this.categoria);
  final CategoriaServicioModel categoria;

  final textControllerNombreCategoria = TextEditingController();
  final textControllerDetalle = TextEditingController();

  void save() {}

  void init() {
    if (categoria.nombreCategoria == null) {
      textControllerNombreCategoria.text = '';
      textControllerDetalle.text = '';
    } else {
      textControllerNombreCategoria.text = categoria.nombreCategoria.toString();
      textControllerDetalle.text = categoria.detalle.toString();
    }
  }
}

/*

class MyDetailLogicRecordatorio{
  MyDetailLogicRecordatorio(this.recordatorio);
  final RecordatorioModel recordatorio;

  final textControllerFecha = TextEditingController();
  final textControllerOdometro= TextEditingController();
  final textControllerTarea = TextEditingController();
  
 
 void save(){
   
 }
 

 void init() {
    if ( recordatorio !=null){
        textControllerFecha.text   = recordatorio.fecha;
        textControllerOdometro.text= recordatorio.odometro;
        textControllerTarea.text   = recordatorio.tarea;
        
    }
  }    
} */
