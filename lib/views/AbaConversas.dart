import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> listaConversas;
  Conversa conversa = Conversa();
  String _idUser;
  Firestore db = Firestore.instance;
  //* StreamController: A sua vantagem se dá quando a tela so será recarregada se tiver um dado novo.
  final _controller = StreamController<QuerySnapshot>.broadcast();

  void _addListenerConversas() {
    //Stream<QuerySnapshot>
    final stream = db
        .collection("conversas")
        .document(_idUser)
        .collection("ultima_conversa")
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
    _idUser = user.uid;
    _addListenerConversas();
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(child: Text("Erro ao carregar os dados!"));
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda :( ",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: querySnapshot.documents.length,
                itemBuilder: (context, index) {
                  List<DocumentSnapshot> conversas =
                      querySnapshot.documents.toList();
                  DocumentSnapshot item = conversas[index];

                  String urlImage = item["caminhoFoto"];
                  String tipo = item["tipoMensagem"];
                  String mensagem = item["mensagem"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];
                  bool visualizado = item["visualizado"];


                  Usuario usuario = Usuario();
                  usuario.setIdUsuario(idDestinatario);
                  usuario.setNome(nome);
                  usuario.setUrlImagem(urlImage);

                  return ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          urlImage != null ? NetworkImage(urlImage) : null,
                    ),
                    title: Text(
                      nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: tipo == "texto"
                        ? Text(
                            mensagem,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          )
                        : Row(
                            children: <Widget>[
                              Icon(Icons.image, color: Colors.grey, size: 18),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text(
                                  "Foto",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    onTap: () {
                      //Abrir tela de mensagens
                      Navigator.pushNamed(
                        context,
                        "/mensagens",
                        arguments: [usuario, visualizado],
                      );
                    },
                    trailing: visualizado == true
                        ? Container(width: 10,
                            height: 10,)
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                  );
                },
              );
            }
            break;
        }
      },
    );
  }
}
