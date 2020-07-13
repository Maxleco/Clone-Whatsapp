import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Mensagens.dart';

class RouteGenerator{

  //static const String ROUTA_HOME = "/home";

  static Route<dynamic> generateRoute(RouteSettings settings){

    var args;
    if(settings.arguments.runtimeType.toString() == "List<Object>"){
      List param = settings.arguments;
      args = param;
    }
    else{
      var param = settings.arguments;
      args = param;
    } 

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
        break;
      case "/login":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
        break;
      case "/cadastro":
        return MaterialPageRoute(
          builder: (_) => Cadastro(),
        );
        break;
      case "/home"://ROUTA_HOME:
        return MaterialPageRoute(
          builder: (_) => Home(),
        );
        break;
      case "/configuracoes":
        return MaterialPageRoute(
          builder: (_) => Configuracoes(),
        );
        break;
      case "/mensagens":
        return MaterialPageRoute(
          builder: (_) => Mensagens(args[0], visualizado: args[1]),
        );
        break;
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada")),
          body: Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      }
    );
  }
}