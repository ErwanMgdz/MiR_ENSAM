import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class statescreen extends StatefulWidget {
  const statescreen({super.key});

  @override
  _statescreenState createState() => _statescreenState();
}

class _statescreenState extends State<statescreen> {
  int _selectedIndex = 1;
  int _selectedMissionIndex = -1;// Déclaration de _selectedIndex
  Color Pourpre = Color.fromRGBO(165, 21, 105, 1.0);
  Color Orange = Colors.orange;
  Color Blanc = Colors.white;
  String host = "http://mir.com/api/v2.0.0/";
  String token =
      'Basic QWRtaW5pc3RyYXRvcjpjOTI5ZmE1MTljYzFiMzJkMTExOWYwNzRjMzgzYjUwMDIwMmE1YzczNGRmZjJlYzI0ZGVlMDRkYTJmZWQ4OTk1';

  Future<String> getMirStatus() async {
    String url = 'status';
    http.Response response = await http.get(
      Uri.parse(host + url),
      headers:  <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> statusData = jsonDecode(response.body);
      int batteryPercentage = statusData['battery_percentage'];
      String batteryTxt = 'Batterie Restante(%): $batteryPercentage';
      String stateText = statusData['state_text'];
      String status = '$batteryTxt    Etat: $stateText';
      return status;
    } else {
      return 'Erreur lors de la récupération du statut';
    }
  }

  Future<String> getNomMissionEnCours() async {
    String url = 'mission_queue';
    http.Response response = await http.get(
      Uri.parse(host + url),
      headers:  <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token,

      },
    );
    if (response.statusCode == 200) {
      List<dynamic> missionQueueDict = jsonDecode(response.body);
      for (int i = 0; i < missionQueueDict.length; i++) {
        if (missionQueueDict[i]['state'] == 'Executing') {
          int num = i + 1;
          String identifiant = num.toString();
          http.Response missionIdResponse = await http.get(
            Uri.parse(host + 'mission_queue/' + identifiant),
            headers:<String, String>{
                'Content-Type': 'application/json',
                'Authorization': token,

            },
          );
          Map<String, dynamic> missionIdDict = jsonDecode(missionIdResponse.body);
          String missionId = missionIdDict['mission_id'];
          http.Response missionResponse = await http.get(
            Uri.parse(host + 'missions/' + missionId),
            headers:<String, String>{
                'Content-Type': 'application/json',
                'Authorization': token,

            },
          );
          Map<String, dynamic> missionDict = jsonDecode(missionResponse.body);
          String nom = missionDict['name'];
          return nom;
        }
      }
    }
    return 'Aucune mission en cours';
  }


  Future<List<String>> getMissionsEnAttente() async {
    http.Response missionQueueResponse = await http.get(
      Uri.parse(host + 'mission_queue'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (missionQueueResponse.statusCode == 200) {
      List<dynamic> missionQueueDict = jsonDecode(missionQueueResponse.body);
      List<String> listeMissionsEnAttente = [];

      for (int i = 0; i < missionQueueDict.length; i++) {
        if (missionQueueDict[i]['state'] == "Pending") {
          int num = i + 1;
          String identifiant = num.toString();

          http.Response missionIdResponse = await http.get(
            Uri.parse(host + 'mission_queue/' + identifiant),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': token,
            },
          );

          Map<String, dynamic> missionIdDict = jsonDecode(missionIdResponse.body);
          String missionId = missionIdDict['mission_id'];

          http.Response missionResponse = await http.get(
            Uri.parse(host + 'missions/' + missionId),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': token,
            },
          );

          Map<String, dynamic> missionDict = jsonDecode(missionResponse.body);
          String nom = missionDict['name'];
          listeMissionsEnAttente.add(nom);
        }
      }
      return listeMissionsEnAttente;
    } else {
      throw Exception('Erreur lors de la récupération des missions en attente');
    }
  }

  Future<void> deleteMission(int selectedMissionIndex) async {
    String url = 'mission_queue';

    // Récupération de la file de missions en attente
    http.Response missionQueueResponse = await http.get(
      Uri.parse(host + url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (missionQueueResponse.statusCode == 200) {
      List<dynamic> missionQueueDict = jsonDecode(missionQueueResponse.body);
      List<String> missionsPending = [];

      // Parcourir la file de missions pour récupérer les missions en attente
      for (var x in missionQueueDict) {
        if (x['state'] == 'Pending') {
          missionsPending.add(x['id']);
        }
      }

      // Vérification que la sélection est valide
      if (selectedMissionIndex >= 0 && selectedMissionIndex < missionsPending.length) {
        String identifiant = missionsPending[selectedMissionIndex];
        String identifiantUrl = identifiant.toString();

        // Suppression de la mission en attente
        await http.delete(
          Uri.parse(host + url + '/' + identifiantUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );

        // Affichage d'un message pour indiquer que la mission a été supprimée
        print('Mission supprimée avec succès.');

        // Mise à jour de l'interface utilisateur ici si nécessaire

        // Vous pouvez ajouter ici d'autres actions à effectuer après la suppression de la mission

      } else {
        print('L\'indice de la mission sélectionnée est invalide.');
      }
    } else {
      print('Erreur lors de la récupération de la file de missions en attente.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 10,
              color: Pourpre,
            ),
            Container(
              height:5,
              color: Blanc,
            ),
            Container(
              color: Pourpre,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: FutureBuilder<String>(
                future: getMirStatus(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
                    );
                  } else {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erreur Connexion'), // Afficher un message d'erreur s'il y a eu un problème
                      );
                    } else {
                      return Center(
                        child: Text(
                          snapshot.data ?? 'Aucune donnée reçue', // Afficher le texte renvoyé par la fonction getMirStatus
                          style: TextStyle(
                            color: Blanc,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            Container(
              color: Pourpre,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Text(
                'Mission en cours',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Blanc,
                  fontSize: 20,
                ),
              ),
            ),
            Container(
              color: Pourpre, // Utilisez la couleur pourpre ici
              padding: EdgeInsets.all(10),
              child: FutureBuilder<String>(
                future: getNomMissionEnCours(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erreur de connexion'), // Afficher un message d'erreur s'il y a eu un problème
                      );
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Text(
                            snapshot.data ?? 'Aucune mission en cours', // Afficher le texte renvoyé par getNomMissionEnCours
                            style: TextStyle(
                              color: Blanc,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
            ),
            Container(
              color: Pourpre,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Text(
                'Missions en attente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Blanc,
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child : Container(
                color: Pourpre,
                padding: EdgeInsets.all(10),
                child: FutureBuilder<List<String>>(
                  future: getMissionsEnAttente(),
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur de connexion'), // Afficher un message d'erreur s'il y a eu un problème
                        );
                      } else {
                        List<String> missionsEnAttente = snapshot.data ?? [];
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: missionsEnAttente.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              // Ajout de la fonctionnalité de sélection de la mission
                              onTap: () {
                                setState(() {
                                  _selectedMissionIndex = index;
                                });
                              },
                              title: Text(
                                missionsEnAttente[index], // Afficher le nom de la mission en attente
                                style: TextStyle(
                                  color: Blanc,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Pourpre,
              padding: EdgeInsets.symmetric(vertical:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Vérifier si une mission est sélectionnée avant de supprimer
                      if (_selectedMissionIndex != -1) {
                        // Appeler la fonction de suppression de mission avec l'indice sélectionné
                        deleteMission(_selectedMissionIndex);
                        // Remettre à zéro l'indice de la mission sélectionnée après la suppression
                        setState(() {
                          _selectedMissionIndex = -1;
                        });
                      } else {
                        // Afficher un message à l'utilisateur pour lui indiquer de sélectionner une mission à supprimer
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Orange,
                      surfaceTintColor: Pourpre,
                    ),
                    icon: Icon(
                      Icons.cancel,
                      color: Blanc,
                      size: 40,
                    ),
                    label : Text(
                      'Supprimer',
                      style: TextStyle(
                          color: Blanc,
                          fontSize: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}