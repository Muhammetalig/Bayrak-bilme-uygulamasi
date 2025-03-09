import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(FlagGameApp());
}

class FlagGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlagGameScreen(),
    );
  }
}

class FlagGameScreen extends StatefulWidget {
  @override
  _FlagGameScreenState createState() => _FlagGameScreenState();
}

class _FlagGameScreenState extends State<FlagGameScreen> {
  List countries = [];
  Map<String, dynamic>? currentCountry;
  TextEditingController answerController = TextEditingController();
  String message = "";
  double zoomLevel = 5.0;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
    if (response.statusCode == 200) {
      setState(() {
        countries = json.decode(response.body);
        pickRandomCountry();
      });
    }
  }

  void pickRandomCountry() {
    if (countries.isNotEmpty) {
      final random = Random();
      setState(() {
        currentCountry = countries[random.nextInt(countries.length)];
        message = "";
        zoomLevel = 5.0;
        answerController.clear();
      });
    }
  }

  void checkAnswer() {
    if (currentCountry == null) return;
    String userAnswer = answerController.text.trim().toLowerCase();
    String correctAnswer =
        currentCountry!["name"]["common"].toString().toLowerCase();

    setState(() {
      if (userAnswer == correctAnswer) {
        message = "Tebrikler! Doğru cevap.";
      } else {
        message = "Yanlış! Biraz daha uzaklaşıyoruz...";
        if (zoomLevel > 1.0) {
          zoomLevel -= 1.0;
        }
      }
    });
  }

  void showAnswer() {
    if (currentCountry != null) {
      setState(() {
        message = "Doğru cevap: ${currentCountry!["name"]["common"]}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bayrak Tahmin Oyunu")),
      body: currentCountry == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Ekranın kaydırılabilir olmasını sağladık
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      widthFactor: 1 / zoomLevel,
                      heightFactor: 1 / zoomLevel,
                      child: Image.network(
                        currentCountry!["flags"]["png"],
                        width: 300,
                        fit: BoxFit
                            .contain, // Resmi ekran boyutuna uyacak şekilde ölçeklendirir
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: answerController,
                      decoration: InputDecoration(
                        labelText: "Ülke adını yaz",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: checkAnswer,
                    child: Text("Cevabı Kontrol Et"),
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickRandomCountry,
                    child: Text("Yeni Bayrak"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: showAnswer,
                    child: Text("Cevabı Gör"),
                  ),
                ],
              ),
            ),
    );
  }
}
