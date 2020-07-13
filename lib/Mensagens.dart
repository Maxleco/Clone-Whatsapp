import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp/util/DateNow.dart';

class Mensagens extends StatefulWidget {
  final Usuario contato;
  final bool visualizado;
  const Mensagens(this.contato, {this.visualizado});
  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _messageController = TextEditingController();
  Firestore db = Firestore.instance;
  String _idUserLogado;
  String _nomeUserLogado;
  String _urlImageUserLogado;
  String _idUserDestinatario;
  bool _subindoImagem = false;
  ScrollController _scrollController = ScrollController();
  //* StreamController: A sua vantagem se dá quando a tela so será recarregada se tiver um dado novo.
  final _controller = StreamController<QuerySnapshot>.broadcast();
  final _controllerOnline = StreamController<DocumentSnapshot>.broadcast();

  _sendMessage() async {
    String textMessage = _messageController.text.trim();
    _messageController.clear();
    if (textMessage.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.setIdUsuario(_idUserLogado);
      mensagem.setMensagem(textMessage);
      mensagem.setUrlImagem("");
      mensagem.setTipo("texto");
      mensagem.setData(await DateNow.getDate());
      //Salvando menssagem para o Remetente
      _saveMessage(_idUserLogado, _idUserDestinatario, mensagem);
      //Salvando menssagem para o Destinatário
      _saveMessage(_idUserDestinatario, _idUserLogado, mensagem);
      //Salvar Conversa
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem msg) {
    //Salvar conversa Remetente
    Conversa cRemetente = Conversa();
    cRemetente.setIdRemetente(_idUserLogado);
    cRemetente.setIdDestinatario(_idUserDestinatario);
    cRemetente.setMensagem(msg.getMensagem());
    cRemetente.setNome(widget.contato.getNome());
    cRemetente.setCaminhoFoto(widget.contato.getUrlImagem());
    cRemetente.setTipoMensagem(msg.getTipo());
    cRemetente.setVisualizado(true);
    cRemetente.salvar();

    //Salvar conversa Destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.setIdRemetente(_idUserDestinatario);
    cDestinatario.setIdDestinatario(_idUserLogado);
    cDestinatario.setMensagem(msg.getMensagem());
    cDestinatario.setNome(_nomeUserLogado);
    cDestinatario.setCaminhoFoto(_urlImageUserLogado);
    cDestinatario.setTipoMensagem(msg.getTipo());
    cDestinatario.setVisualizado(false);
    cDestinatario.salvar();
    _scrollDown(time: 300);
  }

  _saveMessage(String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
    _messageController.clear();
    /*
    *  + mensagens
    *    + Leonardo - ID
    *      + Marcelo - ID
    *        + IdentificadorFirebase
    ?          <Mensagem>
    **/
  }

  _sendPhoto() async {
    File auxFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path;
    //? String title = _titleController.text;
    String rand = Random().nextInt(100000).toString();

    Img.Image image = Img.decodeImage(auxFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 300);

    File compressImg = new File("$path/image_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 9));

    if (compressImg != null) {
      _subindoImagem = true;
      String nameImage = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      StorageReference pastaRaiz = storage.ref();
      StorageReference arquivo = pastaRaiz
          .child("perfil")
          .child(_idUserLogado)
          .child(nameImage + ".jpg");
      StorageUploadTask task = arquivo.putFile(compressImg);
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
        _insertUrlImagemFirestore(snapshot);
      });
    }
  }

  _insertUrlImagemFirestore(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    //Enviar para o Banco de Dados, uma imagem como Mensagem.
    Mensagem mensagem = Mensagem();
    mensagem.setIdUsuario(_idUserLogado);
    mensagem.setMensagem("");
    mensagem.setUrlImagem(url);
    mensagem.setTipo("imagem");
    mensagem.setData(await DateNow.getDate());
    //Salvando menssagem para o Remetente
    _saveMessage(_idUserLogado, _idUserDestinatario, mensagem);
    //Salvando menssagem para o Destinatário
    _saveMessage(_idUserDestinatario, _idUserLogado, mensagem);
    //Salvar Conversa
    _salvarConversa(mensagem);
  }

  void _addListenerMensagens() async {
    //Stream<QuerySnapshot>
    final stream = db
        .collection("mensagens")
        .document(_idUserLogado)
        .collection(_idUserDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      if (!_controller.isClosed) {
        _controller.add(dados);
      }
    });
  }

  //Recuperar ID do Usuário
  _carregarDadosIniciais() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUserLogado = user.uid;
    _idUserDestinatario = widget.contato.getIdUsuario();
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(_idUserLogado).get();
    Map<String, dynamic> dados = snapshot.data;
    if (dados["nome"] != null) {
      _nomeUserLogado = dados["nome"];
    } else {
      _nomeUserLogado = "";
    }
    if (dados["urlImagem"] != null) {
      _urlImageUserLogado = dados["urlImagem"];
    } else {
      _urlImageUserLogado = "";
    }
    _addListenerMensagens();
    _isUserDestinatarioOnline();
    _isNewMessage();
  }

  //Descendo o Scroll de Rolagem
  void _scrollDown({int index, int time}) {
    if (time != null) {
      Timer(Duration(milliseconds: time), () {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      });
    }
  }

  //* --------------------------------------------------------------------------
  //? --------------------------------------------------------------------------
  //! --------------------------------------------------------------------------
  //// --------------------------------------------------------------------------

  _isNewMessage({bool isOnlineInChat}) async {
    if(widget.visualizado == false){
      Firestore db = Firestore.instance;
      await db.collection("conversas")
        .document(_idUserLogado)
        .collection("ultima_conversa")
        .document(_idUserDestinatario)
        .setData({"visualizado": true}, merge: true);
    }
    else if(isOnlineInChat != null){
      if(isOnlineInChat = true){
        Firestore db = Firestore.instance;
        await db.collection("conversas")
          .document(_idUserLogado)
          .collection("ultima_conversa")
          .document(_idUserDestinatario)
          .setData({"visualizado": true}, merge: true);
      }
    }
  }

  void _isUserDestinatarioOnline() async {
    Firestore db = Firestore.instance;
    final stream =
        db.collection("usuarios").document(_idUserDestinatario).snapshots();
    stream.listen((dados) {
      if (!_controllerOnline.isClosed) {
        _controllerOnline.add(dados);
      }
    });
  } 

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
    _controllerOnline.close();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.getUrlImagem() != null
                  ? NetworkImage(widget.contato.getUrlImagem())
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              //child: Text(widget.contato.getNome()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.contato.getNome(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _controllerOnline.stream,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasError) {                                                                                 
                            return Container();
                          } else {
                            if (snapshot != null && snapshot.data != null) {                                                        
                                DocumentSnapshot user = snapshot.data;                                
                                bool status = user["status"];                                                            
                                if (status == true) {
                                  return Text(
                                    "Online",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 12),
                                  );
                                }else{
                                  return Container();
                                }
                            }else{
                              return Container();
                            }
                          }
                          break;
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Container(
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _streamBuilder(),
              _boxMessages(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _streamBuilder() {
    return StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(
                child: Center(
                  child: Text("Erro ao carregar os dados!"),
                ),
              );
            } else {
              return Expanded(
                //flex: 0,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    reverse: true,
                    controller: _scrollController,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: querySnapshot.documents.map((item) {
                        //Define cores e alinhamentos
                        AlignmentDirectional alignment =
                            AlignmentDirectional.centerEnd;
                        Color cor = Color(0xFFd2ffa5);
                        if (_idUserLogado != item["idUsuario"]) {
                          cor = Colors.white;
                          alignment = AlignmentDirectional.centerStart;
                          _isNewMessage(isOnlineInChat: true);
                        }
                        //Definindo largura máxima
                        double widthContianer =
                            MediaQuery.of(context).size.width * 0.8;

                        return Align(
                          alignment: alignment,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: widthContianer,
                              ),
                              padding: EdgeInsets.all(
                                  item["tipo"] == "texto" ? 16 : 6),
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: item["tipo"] == "texto"
                                  ? Text(
                                      item["mensagem"],
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Image.network(item["urlImagem"]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }
            break;
        }
      },
    );
  }

  Widget _boxMessages() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: TextField(
                controller: _messageController,
                autocorrect: false,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Digite uma mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: _subindoImagem
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        )
                      : IconButton(
                          icon: Icon(Icons.camera_alt, size: 18.0),
                          onPressed: _sendPhoto,
                        ),
                ),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _sendMessage,
                )
              : FloatingActionButton(
                  child: Icon(Icons.send, color: Colors.white),
                  backgroundColor: Color(0xFF075E54),
                  mini: true,
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}
