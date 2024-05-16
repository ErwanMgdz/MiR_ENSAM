import 'package:flutter/material.dart';
import 'package:mirensam/controlscreen.dart';
import 'package:mirensam/statescreen.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  Color Pourpre = Color.fromRGBO(165, 21, 105, 1.0);
  Color Orange = Colors.orange;
  Color Blanc = Colors.white;

  static final List<Widget> _widgetOptions = <Widget>[
    const controlscreen(), // Écran de commande
    statescreen(), // Écran d'état
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Pourpre,
          toolbarHeight: 60,
          elevation: 0,
          titleSpacing: 15,
          title: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Arts&Métiers',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'MiR250',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        body: _widgetOptions.elementAt(_selectedIndex), // Afficher l'écran correspondant à l'index sélectionné
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Pourpre,
          iconSize: 50,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.games_outlined),
              label:
              'Commande',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label:'Etat',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Orange,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle( fontWeight:FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),

        ),
      ),
    );
  }
}

