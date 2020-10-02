import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './resultpage.dart';
import './widgets/loading.dart';
// import 'package:quizstar/resultpage.dart';

// ignore: must_be_immutable
class GetJson extends StatelessWidget {
  // accept the langname as a parameter

  final quizOption;
  GetJson(this.quizOption);

  String _assetToLoad;

  // a function
  // sets the asset to a particular JSON file
  // and opens the JSON
  setasset() {
    if (quizOption == "antonym") {
      _assetToLoad = "assets/antonym.json";
    } else {
      _assetToLoad = "assets/synonym.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    // this function is called before the build so that
    // the string assettoload is avialable to the DefaultAssetBuilder
    setasset();
    // and now we return the FutureBuilder to load and decode JSON
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString(_assetToLoad, cache: false),
      builder: (context, snapshot) {
        List quizData = json.decode(snapshot.data.toString());
        // if (quizData == null) {
        //   return Scaffold(
        //     body: Center(
        //       child: Text(
        //         "Loading",
        //       ),
        //     ),
        //   );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Loading(),
            ),
          );
        } else {
          // return Scaffold(
          //   body: Center(
          //     child: Text('Here now'),
          //   ),
          // );
          return QuizPage(quizData: quizData);
        }
      },
    );
  }
}

class QuizPage extends StatefulWidget {
  final List quizData;

  QuizPage({Key key, @required this.quizData}) : super(key: key);
  @override
  _QuizPageState createState() => _QuizPageState(quizData);
}

class _QuizPageState extends State<QuizPage> {
  final List quizData;
  _QuizPageState(this.quizData);

  Color colorToShow = Colors.indigoAccent;
  Color right = Colors.green;
  Color wrong = Colors.red;
  int marks = 0;
  int i = 1;
  bool disableAnswer = false;
  // extra varibale to iterate
  int j = 1;
  int timer = 30;
  String showTimer = "30";
  // var random_array;

  Map<String, Color> btnColor = {
    "a": Colors.indigoAccent,
    "b": Colors.indigoAccent,
    "c": Colors.indigoAccent,
    "d": Colors.indigoAccent,
  };

  bool cancelTimer = false;

  // code inserted for choosing questions randomly
  // to create the array elements randomly use the dart:math module
  // -----     CODE TO GENERATE ARRAY RANDOMLY

  // genrandomarray() {
  //   var distinctIds = [];
  //   var rand = new Random();
  //   for (int i = 0;;) {
  //     distinctIds.add(rand.nextInt(10));
  //     random_array = distinctIds.toSet().toList();
  //     if (random_array.length < 10) {
  //       continue;
  //     } else {
  //       break;
  //     }
  //   }
  //   print(random_array);
  // }

  //   var random_array;
  //   var distinctIds = [];
  //   var rand = new Random();
  //     for (int i = 0; ;) {
  //     distinctIds.add(rand.nextInt(10));
  //       random_array = distinctIds.toSet().toList();
  //       if(random_array.length < 10){
  //         continue;
  //       }else{
  //         break;
  //       }
  //     }
  //   print(random_array);

  // ----- END OF CODE
  // var random_array = [1, 6, 7, 2, 4, 10, 8, 3, 9, 5];

  // overriding the initstate function to start timer as this screen is created
  @override
  void initState() {
    startTimer();
    // genrandomarray();
    super.initState();
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void startTimer() async {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
          nextQuestion();
        } else if (cancelTimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
        showTimer = timer.toString();
      });
    });
  }

  void nextQuestion() {
    cancelTimer = false;
    timer = 30;
    setState(() {
      if (i < 10) {
        i++;
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: marks),
        ));

        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => HomePage(),
        // ));
      }
      btnColor["a"] = Colors.indigoAccent;
      btnColor["b"] = Colors.indigoAccent;
      btnColor["c"] = Colors.indigoAccent;
      btnColor["d"] = Colors.indigoAccent;
      disableAnswer = false;
    });
    startTimer();
  }

  void _skipQuetion() {
    setState(() {
      // applying the changed color to the particular button that was selected
      cancelTimer = true;
      disableAnswer = true;
    });
    // changed timer duration to 1 second
    Timer(Duration(seconds: 1), nextQuestion);
  }

  void checkAnswer(String k) {
    // in the previous version this was
    // quizData[2]["1"] == quizData[1]["1"][k]
    // which i forgot to change
    // so nake sure that this is now corrected
    if (quizData[2][i.toString()] == quizData[1][i.toString()][k]) {
      // just a print sattement to check the correct working
      // debugPrint(quizData[2][i.toString()] + " is equal to " + quizData[1][i.toString()][k]);
      marks = marks + 5;
      // changing the color variable to be green
      colorToShow = right;
    } else {
      // just a print sattement to check the correct working
      // debugPrint(quizData[2]["1"] + " is equal to " + quizData[1]["1"][k]);
      colorToShow = wrong;
    }
    setState(() {
      // applying the changed color to the particular button that was selected
      btnColor[k] = colorToShow;
      cancelTimer = true;
      disableAnswer = true;
    });
    // nextQuestion();
    // changed timer duration to 1 second
    Timer(Duration(seconds: 1), nextQuestion);
  }

  Widget _multiChoiceButton(String k) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: MaterialButton(
        onPressed: () => checkAnswer(k),
        child: Text(
          quizData[1][i.toString()][k],
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Alike",
            fontSize: 16.0,
          ),
          maxLines: 1,
        ),
        color: btnColor[k],
        splashColor: Colors.indigo[700],
        highlightColor: Colors.indigo[700],
        minWidth: 200.0,
        height: 45.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Quizstar",
                  ),
                  content: Text("You Can't Go Back At This Stage."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok',
                      ),
                    )
                  ],
                ));
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            // Question
            Expanded(
              flex: 3,
              child: Card(
                elevation: 10,
                margin: EdgeInsets.only(
                    left: 20, right: 20, top: appBar.preferredSize.height),
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  // alignment: Alignment.bottomLeft,
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        quizData[0][i.toString()],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Quando",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //Answers Section
            Expanded(
              flex: 6,
              child: AbsorbPointer(
                absorbing: disableAnswer,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _multiChoiceButton('a'),
                      _multiChoiceButton('b'),
                      _multiChoiceButton('c'),
                      SizedBox(height: 20),
                      FlatButton(
                          onPressed: _skipQuetion,
                          child: Text(
                            'Skip Question',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),

            // TImer Section
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Text(
                    showTimer,
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
