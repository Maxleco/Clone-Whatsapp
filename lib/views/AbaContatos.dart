import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Usuario.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String _idUser;
  String _emailUser;
  Firestore db = Firestore.instance;
  //* StreamController: A sua vantagem se dá quando a tela so será recarregada se tiver um dado novo.
  final _controller = StreamController<QuerySnapshot>.broadcast();

  void _addListenerConversas() {
    //Stream<QuerySnapshot>
    final stream = db.collection("usuarios").snapshots();
    stream.listen((dados) {
      if(! _controller.isClosed){
        _controller.add(dados);
      }
    });
  }

  _carregarDadosIniciais() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUser = user.uid;
    _emailUser = user.email;
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
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                    "Você não tem nenhuma contato ainda :( ",
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
                  List<DocumentSnapshot> contatos =
                      querySnapshot.documents.toList();
                  DocumentSnapshot item = contatos[index];
                  //Evitar que o usuário tenha um contato dele mesmo
                  String email = item["email"];
                  if (email.trim().toLowerCase() !=
                      _emailUser.trim().toLowerCase()) {
                    Usuario usuario = Usuario();
                    usuario.setIdUsuario(item.documentID);
                    usuario.setEmail(item["email"]);
                    usuario.setNome(item["nome"]);
                    usuario.setUrlImagem(item["urlImagem"]);

                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: usuario.getUrlImagem() != null
                            ? NetworkImage(usuario.getUrlImagem())
                            : null,
                      ),
                      title: Text(
                        usuario.getNome(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        //Abrir tela de mensagens
                        Navigator.pushNamed(
                          context,
                          "/mensagens",
                          arguments: [usuario, true],
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }
        }
      },
    );
  }
}
