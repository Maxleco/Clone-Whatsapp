import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/MessageNotification.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:whatsapp/views/AbaContatos.dart';
import 'package:whatsapp/views/AbaConversas.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // final List<MessageNotification> messages =[];

  // Widget buildMessage(MessageNotification message){
  //   return ListTile(
  //     title: Text(message.title),
  //     subtitle: Text(message.body),
  //   );
  // }

  //*-------------------------------------------------------------------------------------------------
  //!-------------------------------------------------------------------------------------------------
  //?-------------------------------------------------------------------------------------------------
  //// -------------------------------------------------------------------------------------------------

  TabController _tabController;
  Usuario _user;
  List<String> listOptions = ["Configurações", "Sair", "Notification", "Notification Delay"];

  // FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // AndroidInitializationSettings _androidInitializationSettings;
  // IOSInitializationSettings _iosInitializationSettings;
  // InitializationSettings _initializationSettings;

  _escolhaMenuItem(String item) {
    switch (item) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Sair":
        _deslogarUsuario();
        break;
      case "Notification":
        //_showNotifications();
        break;
      case "Notification Delay":
        //_showNotificationsDelay();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    ///Recuperar informações do Usuário
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db
      .collection("usuarios")
      .document(user.uid)
      .get();
    Map<String, dynamic> dados = snapshot.data;

    _user = Usuario();
    _user.setIdUsuario(user.uid);
    _user.setNome(dados["nome"]);
    _user.setEmail(dados["email"]);
    _user.setUrlImagem(dados["urlImagem"]);

    if (user == null) {     
      Navigator.pushReplacementNamed(context, "/login");
    }
    else{
      _updateStatusUser("SignIn");
    }
  }


  Future _updateStatusUser(String sign) async {
    Firestore db = Firestore.instance;
    if(sign == "SignIn"){
      _user.setStatus(true);    
      await db.collection("usuarios")
        .document(_user.getIdUsuario())
        .setData(_user.toMap());
    }
    else if(sign == "SignOut"){
      _user.setStatus(false);
      await db.collection("usuarios").
        document(_user.getIdUsuario())
        .setData(_user.toMap());
    }    
  }  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
       _updateStatusUser("SignIn");
    }else if(state == AppLifecycleState.inactive){
      _updateStatusUser("SignOut");
    }else if(state == AppLifecycleState.paused){
      _updateStatusUser("SignOut");
    }
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    //*-------------------------------------------------------------------
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("OnMessage: $message");
    //     final notification = message["notification"];
    //     setState(() {
    //       messages.add(
    //         MessageNotification(notification["title"], notification["body"]),
    //       );
    //     });
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("OnLaunch: $message");
    //     final notification = message["notification"];
    //     setState(() {
    //       messages.add(
    //         MessageNotification("OnLaunch: " + notification["title"], "OnLaunch: " + notification["body"]),
    //       );
    //     });
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("OnResume: $message");
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //   const IosNotificationSettings(sound: true, badge: true, alert: true),
    // );
    // //*-------------------------------------------------------------------
    // initializing();
    WidgetsBinding.instance.addObserver(this);    
  }

  @override
  void dispose() {
    super.dispose();
    _updateStatusUser("SignOut");
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() async {
    super.deactivate();
    await _updateStatusUser("SignOut");
    WidgetsBinding.instance.removeObserver(this);

  }

  // void initializing() async {
  //   _androidInitializationSettings = AndroidInitializationSettings("app_icon");
  //   _iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  //   _initializationSettings = InitializationSettings(_androidInitializationSettings, _iosInitializationSettings);
  //   await _flutterLocalNotificationsPlugin.initialize(_initializationSettings, onSelectNotification: onSelectNotification);
  // }

  // Future onSelectNotification(String payLoad){
  //   if(payLoad != null){
  //     print(payLoad);
  //   }
  //   // We can set Navigator to navigate another screen
  // }

  // Future onDidReceiveLocalNotification(int id, String title, String body, String payLoad) async {
  //   return CupertinoAlertDialog(
  //     title: Text(title),
  //     content: Text(body),
  //     actions: <Widget>[
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: Text("Okay"),
  //         onPressed: (){
  //           print("Notification Enviada com sucesso!");
  //         },
  //       ),
  //     ],
  //   );
  // }

  // void _showNotifications() async {
  //   await notification();
  // }

  // void _showNotificationsDelay() async {
  //   await notificationAfterSec();
  // }

  // Future notification(){
  //   AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
  //     "Channel ID", "Channel title", "Channel body",
  //     priority: Priority.High,
  //     importance: Importance.Max,
  //     ticker: "test"
  //   );
  //   IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
  //   NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails, iosNotificationDetails);
  //   _flutterLocalNotificationsPlugin.show(1, "Eaw", "Notificação Teste", notificationDetails);
  // }

  // Future notificationAfterSec(){
  //   var timeDelayed = DateTime.now().add(Duration(seconds: 5));
  //   AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
  //     "second channel ID", "second Channel title", "second channel body",
  //     priority: Priority.High,
  //     importance: Importance.Max,
  //     ticker: "test"
  //   );
  //   IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
  //   NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails, iosNotificationDetails);
  //   _flutterLocalNotificationsPlugin.schedule(1, "Eaw", "Notificação Teste", timeDelayed, notificationDetails);
  // }

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Whatsapp"),
        elevation: Platform.isIOS ? 0 : 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 4,
          indicatorColor: Platform.isIOS ? Colors.grey[400] : Colors.white,
          labelStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          tabs: <Widget>[
            Tab(text: "Conversas"),
            Tab(text: "Contatos"),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return listOptions.map((String item) {
                return PopupMenuItem<String>(
                  child: Text(item),
                  value: item,
                );
              }).toList();
            },
          ),
        ],
      ),
      // body: ListView(
      //   children: messages.map(buildMessage).toList(),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AbaConversas(),
          AbaContatos(),
        ],
      ),
    );
  }
}
