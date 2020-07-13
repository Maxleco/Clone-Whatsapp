import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'model/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  String _mensageErro = "";
  Future<AuthResult> _isLoading;

  void _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    print(usuario.getSenha());
    _isLoading = auth
        .signInWithEmailAndPassword(
      email: usuario.getEmail().trim().toLowerCase(),
      password: usuario.getSenha().trim().toLowerCase(),
    )
        .then((firebaseUser) {
      if (firebaseUser.user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setStatusErro("Erro ao autenticar usuário!");
      }
    }).catchError((err) {
      print("Erro ao Cadastrar: " + err.toString());
      setStatusErro(
          "Erro ao autenticar usuário, verifique E-amil e Senha, tente novamente!");
    });
  }

  void _validarCampos() {
    String email = _emailController.text;
    String senha = _senhaController.text;
    print(senha);

    Usuario user = Usuario();
    user.setEmail(email);
    user.setSenha(senha);

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty) {
        setStatusErro("");
        _logarUsuario(user);
      } else {
        setStatusErro("Preencha a Senha!");
      }
    } else {
      setStatusErro("Preencha o E-mail utilizando @");
    }
  }

  setStatusErro(String mensagem) {
    setState(() {
      _mensageErro = mensagem;
    });
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (user != null) {
      //Navigator.pushReplacementNamed(context, RouteGenerator.ROUTA_HOME);
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "images/logo.png",
                    width: 200,
                    height: 150,
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
                      "Entrar",
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
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? Cadastra-se!",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cadastro()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FutureBuilder(
                    future: _isLoading,
                    builder: (context, snapshot) {
                      Widget defaultWidget;
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          defaultWidget = Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}