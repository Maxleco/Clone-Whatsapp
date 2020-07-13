
class Usuario{
  String _idUsuario;
  bool _status;
  String _nome;
  String _email;
  String _senha;
  String _urlImagem;  

  Usuario();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome": this.getNome(),
      "email": this.getEmail(),
      "urlImagem": this.getUrlImagem(),
      "status": this.getStatus(),
    };
    return map;
  }

  String getIdUsuario(){
    return _idUsuario;
  }
  void setIdUsuario(String idUsuario){
    this._idUsuario = idUsuario;
  }

  bool getStatus(){
    return _status;
  }
  void setStatus(bool status){
    this._status = status;
  }

  String getNome(){
    return _nome;
  }
  void setNome(String nome){
    this._nome = nome;
  }

  String getEmail(){
    return _email;
  }
  void setEmail(String email){
    this._email = email;
  }

  String getSenha(){
    return _senha;
  }
  void setSenha(String senha){
    this._senha = senha;
  }

  String getUrlImagem(){
    return _urlImagem;
  }
  void setUrlImagem(String urlImagem){
    this._urlImagem = urlImagem;
  }

}