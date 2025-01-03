import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MaterialApp(
  home: DiceGame(),
));

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  int balance = 10;
  int wager = 0;
  int wins = 0;
  int losses = 0;
  String selectedGameType = "2 Alike";
  TextEditingController wageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Stake Dice Game',
          style: TextStyle(
            color: Colors.amber[400],
            fontWeight: FontWeight.bold,
            fontSize: 32.0
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black54,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Losses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$losses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        ' Wins ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$wins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Wallet Balance',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.50,
              ),
            ),
            Text(
              "$balance coins",
              style: TextStyle(
                color: Colors.amberAccent[200],
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.50,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: wageController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your wager',
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  wager = int.parse(value);
                });
              },
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              value: selectedGameType,
              dropdownColor: Colors.grey[800],
              items: <String>['2 Alike', '3 Alike', '4 Alike']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.25,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGameType = newValue!;
                });
              },
              style: TextStyle(color: Colors.amber),
              iconEnabledColor: Colors.amber,
              iconSize: 47,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                playGame();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.green,
                backgroundColor: Colors.grey[850],
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              child: Text('GO!'),
            ),
          ],
        ),
      ),
    );
  }

  void playGame() {
    if (!validateWager()) {
      Fluttertoast.showToast(msg: 'Invalid Wager', toastLength: Toast.LENGTH_SHORT);
      return;
    }

    List<int> diceRolls = rollDice();
    String result = getResult(diceRolls);
    updateBalance(result);

    if (result.contains('Win')) {
      setState(() {
        wins += 1;
      });
    } else {
      setState(() {
        losses += 1;
      });
    }

    Fluttertoast.showToast(
      msg: 'Dice: ${diceRolls.join(", ")} - $result',
      toastLength: Toast.LENGTH_LONG,
    );
    wageController.clear();
  }

  bool validateWager() {
    int maxWager;
    switch (selectedGameType) {
      case '2 Alike':
        maxWager = balance ~/ 2;
        break;
      case '3 Alike':
        maxWager = balance ~/ 3;
        break;
      case '4 Alike':
        maxWager = balance ~/ 4;
        break;
      default:
        maxWager = 0;
    }
    return wager > 0 && wager <= maxWager;
  }

  List<int> rollDice() {
    Random random = Random();
    return List<int>.generate(4, (_) => random.nextInt(6) + 1);
  }

  String getResult(List<int> dice) {
    Map<int, int> counts = {};
    for (var value in dice) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    if (selectedGameType == '4 Alike' && counts.values.contains(4)) {
      return 'Win 4x';
    } else if (selectedGameType == '3 Alike' && counts.values.contains(3)) {
      return 'Win 3x';
    } else if (selectedGameType == '2 Alike' && counts.values.contains(2)) {
      return 'Win 2x';
    } else {
      return 'Lose';
    }
  }

  void updateBalance(String result) {
    int multiplier = 1;
    if (result.contains('Win')) {
      multiplier = int.parse(result.split('x')[0].split(' ').last);
    } else {
      multiplier = -1;
    }

    setState(() {
      balance += wager * multiplier;
    });
  }
}
