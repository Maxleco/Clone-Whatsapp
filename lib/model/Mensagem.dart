import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem{
  String _idUsuario;
  String _mensagem;
  String _urlImagem;
  //Definir o tipo da mensagem, que pode ser "Texto" ou "Imagem"
  String _tipo;
  Timestamp _data;

  Mensagem();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idUsuario": this.getIdUsuario(),
      "mensagem": this.getMensagem(),
      "urlImagem": this.getUrlImagem(),
      "tipo": this.getTipo(),
      "data": this.getData(),
    };
    return map;
  }

  String getIdUsuario(){
    return _idUsuario;
  }
  void setIdUsuario(String idUsuario){
    this._idUsuario = idUsuario;
  }

  String getMensagem(){
    return _mensagem;
  }
  void setMensagem(String mensagem){
    this._mensagem = mensagem;
  }

  String getUrlImagem(){
    return _urlImagem;
  }
  void setUrlImagem(String urlImagem){
    this._urlImagem = urlImagem;
  }

  String getTipo(){
    return _tipo;
  }
  void setTipo(String tipo){
    this._tipo = tipo;
  }

  Timestamp getData(){
    return _data;
  }
  void setData(Timestamp data){
    this._data = data;
  }
}