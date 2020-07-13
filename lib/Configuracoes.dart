import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _nomeController = TextEditingController();
  String _idUser;
  File _image;
  bool _subindoImagem = false;
  String _urlImageRecuperada;

  Future _recuperarImagem(String origem) async {
    File img;
    switch (origem) {
      case "camera":
        img = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        img = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _image = img;
      if (_image != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo =
        pastaRaiz.child("perfil").child(_idUser + ".jpg");
    //Upload de Imagem
    StorageUploadTask task = arquivo.putFile(_image);
    //Controlar Progresso do Upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    //Recuperar URL da Imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlImagemFirestore(url);
    setState(() {
      _urlImageRecuperada = url;
    });
  }

  //Atualizar URL Imagem no Firestore
  _updateUrlImagemFirestore(String url){
    Firestore db = Firestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url,
    };
    db.collection("usuarios")
      .document(_idUser)
      .updateData(dadosAtualizar);
  }

  //Atualizar Nome no Firestore
  _updateNomeFirestore(){
    String nome = _nomeController.text.trim();
    Firestore db = Firestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "nome": nome,
    };
    db.collection("usuarios")
      .document(_idUser)
      .updateData(dadosAtualizar);
  }

  //Recuperar ID do Usuário
  _recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUser = user.uid;
    ///Recuperar informações do Usuário
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db
      .collection("usuarios")
      .document(_idUser)
      .get();
    Map<String, dynamic> dados = snapshot.data;
    _nomeController.text = dados["nome"];
    
    if(dados["urlImagem"] != null){
      setState(() {
        _urlImageRecuperada = dados["urlImagem"];
      });      
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarios();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: _subindoImagem
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      )
                    : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImageRecuperada != null
                      ? NetworkImage(_urlImageRecuperada)
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: _nomeController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20.0),
                    // onChanged: (text){
                    //   _updateNomeFirestore(text);
                    // },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    onPressed: () {
                      _updateNomeFirestore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
