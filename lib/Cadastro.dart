import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  String _mensageErro = "";
  Future<AuthResult> _isLoading;

  void _cadastrarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;
    _isLoading =  auth
        .createUserWithEmailAndPassword(
      email: usuario.getEmail().trim().toLowerCase(),
      password: usuario.getSenha().trim().toLowerCase(),
    )
    .then((firebaseUser) {
      if (firebaseUser.user != null) {
        //Adicionando informações do Usuário
        /// firebaseUser.user.uid -> Id gerado na autenticação do Usuário
        Firestore db = Firestore.instance;
        db.collection("usuarios")
          .document(firebaseUser.user.uid)
          .setData(usuario.toMap());
        
        Navigator.pushNamedAndRemoveUntil(
          context, "/home",  (Route<dynamic> route) => false,
        );
      } else {
        setStatusErro("Erro ao cadastrar usuário!");
      }
    }).catchError((err) {
      print("Erro ao Cadastrar: " + err.toString());
      setStatusErro(
          "Erro ao cadastrar usuário, verifique os campos e tente novamente!");
    });
  }

  void _validarCampos() {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _senhaController.text;

    Usuario user = Usuario();
    user.setNome(nome);
    user.setEmail(email);
    user.setSenha(senha);

    if (nome.length >= 3) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length > 6) {
          setStatusErro("");
          _cadastrarUsuario(user);
        } else {
          setStatusErro("Preencha a Senha! Digite mais de 6 caracteres!");
        }
      } else {
        setStatusErro("Preencha o E-mail utilizando @");
      }
    } else {
      setStatusErro("O Nome precisa ter mais que 3 caracteres!");
    }
  }

  setStatusErro(String mensagem) {
    setState(() {
      _mensageErro = mensagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF075E54),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: Image.asset(
                    "images/usuario.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: _nomeController,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20.0),
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
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _senhaController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    style: TextStyle(fontSize: 20.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
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
                      "Cadastrar",
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
                      _validarCampos();
                    },
                  ),
                ),
                FutureBuilder(
                  future: _isLoading,
                  builder: (context, snapshot) {
                    Widget defaultWidget;
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        defaultWidget = Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        );
                        break;
                      default:
                        defaultWidget = Text(
                          _mensageErro,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        );
                    }
                    return defaultWidget;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
