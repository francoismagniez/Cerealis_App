import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> sendData(String prenom, String email) async {
  var url = Uri.parse('https://cerealis-app.saas2.doliondemand.fr/api/index.php/contacts');

  var payload = {
    'lastname': prenom, // Utilisation du prénom comme "lastname"
    'email': email
  };

  var response = await http.post(
    url,
    headers: {
      'DOLAPIKEY': '146d79aa60fb3d852883badfab8377bcbd787bde',
      'Content-Type': 'application/json',
    },
    body: json.encode(payload),
  );

  if (response.statusCode == 200) {
    print('Données envoyées avec succès !');
    return true;
  } else {
    print('Erreur lors de l\'envoi des données : ${response.body}');
    return false;
  }
}