import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class controlscreen extends StatefulWidget {
  const controlscreen({super.key});

  @override
  State<controlscreen> createState() => controlscreenState();
}


class controlscreenState extends State<controlscreen> {
  int _selectedIndex = 0; // Déclaration de _selectedIndex
  Color Pourpre = const Color.fromRGBO(165, 21, 105, 1.0);
  Color Orange = Colors.orange;
  Color Blanc = Colors.white;
  String host = "http://mir.com/api/v2.0.0/";
  String token =
      'Basic QWRtaW5pc3RyYXRvcjpjOTI5ZmE1MTljYzFiMzJkMTExOWYwNzRjMzgzYjUwMDIwMmE1YzczNGRmZjJlYzI0ZGVlMDRkYTJmZWQ4OTk1';
  int _selectedMissionIndex = -1; // Variable pour stocker l'index de la mission sélectionnée

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final TextEditingController _keywordController;
  List<String> _missions = [];

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _searchMissions() async {
    String url = 'missions';
    http.Response response = await http.get(
      Uri.parse(host + url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> missionsJson = jsonDecode(response.body);
      setState(() {
        _missions.clear();
        String searchKeyword = _keywordController.text.toLowerCase();
        for (var mission in missionsJson) {
          String missionName = mission['name'];
          if (searchKeyword.isEmpty ||
              missionName.toLowerCase().contains(searchKeyword)) {
            _missions.add(missionName);
          }
        }
      });
    } else {
      setState(() {
        _missions.clear();
        _missions.add('Erreur de connexion');
      });
    }
  }

  // Fonction pour ajouter une mission à la file de missions
  Future<void> ajouterMission(String missionName) async {
    String url1 = 'missions';
    http.Response response = await http.get(
      Uri.parse(host + url1),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> missionsJson = jsonDecode(response.body);
      String? guidMission=null;
      for (var mission in missionsJson) {
        if (mission['name'] == missionName) {
          guidMission = mission['guid'];
          break;
        }
      }
      if (guidMission != null) {
        Map<String, dynamic> missionSelectionnee = {'mission_id': guidMission};
        String url2 = 'mission_queue';
        await http.post(
          Uri.parse(host + url2),
          body: jsonEncode(missionSelectionnee),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );
        // Vous pouvez mettre à jour l'interface utilisateur ici si nécessaire
      } else {
        print('La mission sélectionnée n\'a pas été trouvée.');
      }
    } else {
      print('Erreur lors de la récupération des missions.');
    }
  }

  Future<void> pause() async {
    String url = 'status';
    Map<String, dynamic> data = {'state_id': 4};
    await http.put(
      Uri.parse(host + url),
      body: jsonEncode(data),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );
  }

  Future<void> run() async {
    String url = 'status';
    Map<String, dynamic> data = {'state_id': 3};
    await http.put(
      Uri.parse(host + url),
      body: jsonEncode(data),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
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
              padding: EdgeInsets.symmetric(vertical: 50),
              child : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: run,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Orange,
                      surfaceTintColor: Pourpre,
                    ),
                    icon: Icon(
                      Icons.play_circle,
                      color: Blanc,
                      size: 40,
                    ),
                    label:Text(
                      'Run',
                      style: TextStyle(
                        color: Blanc,
                        fontSize: 20,
                      ),
                    ),

                  ),
                  SizedBox(width:60,),
                  ElevatedButton.icon(
                    onPressed: pause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Orange,
                      surfaceTintColor: Pourpre,
                    ),
                    icon: Icon(
                      Icons.stop_circle_sharp,
                      color: Blanc,
                      size: 40,
                    ),
                    label : Text(
                      'Stop',
                      style: TextStyle(
                          color: Blanc,
                          fontSize: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color:Pourpre,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              child: TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Blanc,
                  hintText: 'Recherche',
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
                    onPressed: _searchMissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Orange,
                      surfaceTintColor: Pourpre,
                    ),
                    icon: Icon(
                      Icons.search,
                      color: Blanc,
                      size: 40,
                    ),
                    label : Text(
                      'Rechercher',
                      style: TextStyle(
                          color: Blanc,
                          fontSize: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Pourpre, // Couleur de fond pourpre
                padding: EdgeInsets.all(20),
                child: ListView.builder(
                    itemCount: _missions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMissionIndex = index; // Mise à jour de l'index de la mission sélectionnée
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          color: Blanc,
                          child: Text(
                            _missions[index],
                            style: TextStyle(
                              color: Pourpre,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    }

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
                      if (_selectedMissionIndex != -1) {
                        ajouterMission(_missions[_selectedMissionIndex]);
                        // Remettre à zéro l'index de la mission sélectionnée
                        setState(() {
                          _selectedMissionIndex = -1;
                        });
                      } else {
                        // Afficher un message à l'utilisateur pour lui indiquer de sélectionner une mission
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Orange,
                      surfaceTintColor: Pourpre,
                    ),
                    icon: Icon(
                      Icons.list,
                      color: Blanc,
                      size: 40,
                    ),
                    label : Text(
                      'Ajouter',
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