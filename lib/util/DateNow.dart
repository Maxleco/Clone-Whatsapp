import 'dart:convert';

import 'package:http/http.dart' as  http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DateNow{

  static const String URL = "http://worldtimeapi.org/api/timezone/America/Argentina/Salta";

  static Future<Timestamp> getDate() async {
    http.Response response;
    response = await http.get(URL);
    var result = json.decode(response.body);
    String data = result["datetime"];
    DateTime dataConvertida = DateTime.tryParse(data);
    Timestamp datFinal = Timestamp.fromDate(dataConvertida);
    return datFinal;
  }

}