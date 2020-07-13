
import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa{

  String _idRemetente;
  String _idDestinatario;
  String _enviadoPor;
  String _nome;
  String _mensagem;
  String _caminhoFoto;
  String _tipoMensagem;//Text ou Imagem
  bool _visualizado;

  Conversa();

  void salvar() async {
    /*
        + conversas
          + Leonardo
            + ultima_conversa
              + Marcelo
                <...>
                idRe
                idDes
                ...
    */
    Firestore db = Firestore.instance;
    await db.collection("conversas")
      .document(this.getIdRemetente())
      .collection("ultima_conversa")
      .document(this.getIdDestinatario())
      .setData(this.toMap());
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idRemetente": this.getIdRemetente(),
      "idDestinatario": this.getIdDestinatario(),
      "nome": this.getNome(),
      "mensagem": this.getMensagem(),
      "caminhoFoto": this.getCaminhoFoto(),
      "tipoMensagem": this.getTipoMensagem(),
      "visualizado": this.getVisualizado(),
    };
    return map;
  }

  String getIdRemetente(){
    return this._idRemetente;
  }
  void setIdRemetente(String idRemetente){
    this._idRemetente = idRemetente;
  }

  String getIdDestinatario(){
    return this._idDestinatario;
  }
  void setIdDestinatario(String idDestinatario){
    this._idDestinatario = idDestinatario;
  }

  String getEnviadoPor(){
    return this._enviadoPor;
  }
  void setEnviadoPor(String enviadoPor){
    this._enviadoPor = enviadoPor;
  }

  String getNome(){
    return this._nome;
  }
  void setNome(String nome){
    this._nome = nome;
  }

  String getMensagem(){
    return this._mensagem;
  }
  void setMensagem(String mensagem){
    this._mensagem = mensagem;
  }

  String getCaminhoFoto(){
    return this._caminhoFoto;
  }
  void setCaminhoFoto(String caminhoFoto){
    this._caminhoFoto = caminhoFoto;
  }

  String getTipoMensagem(){
    return this._tipoMensagem;
  }
  void setTipoMensagem(String tipoMensagem){
    this._tipoMensagem = tipoMensagem;
  }

  bool getVisualizado(){
    return this._visualizado;
  }
  void setVisualizado(bool visualizado){
    this._visualizado = visualizado;
  }

}