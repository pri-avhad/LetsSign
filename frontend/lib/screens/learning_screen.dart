import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_pro/carousel_pro.dart';

class LearningScreen extends StatefulWidget {
  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String searchedWord = "";
  List<Widget> alphabets = [];

  void learn(String word, double imgSize, double textSize) {
    word.runes.forEach((int rune) {
      var ch = new String.fromCharCode(rune);
      ch = ch.toLowerCase();
      if (ch != " ") {
        setState(() {
          alphabets.add(
            Column(
              children: [
                Image(
                  height: imgSize,
                  image: AssetImage("assets/images/$ch.png"),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  ch.toUpperCase(),
                  style: TextStyle(fontSize: textSize),
                )
              ],
            ),
          );
        });
      }
    });
  }

  Widget alpha() {
    if (alphabets.length != 0)
      return Carousel(
          boxFit: BoxFit.cover,
          images: alphabets,
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: Duration(milliseconds: 1500),
          showIndicator: false);
    else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF2EC4B6), size: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'LetsSign',
          style: TextStyle(color: Colors.black, fontSize: 26),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: constraints.maxHeight * 0.02,
                          top: constraints.maxHeight * 0.02,
                          right: constraints.maxHeight * 0.02),
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: constraints.maxHeight * 0.04),
                            width: constraints.maxWidth * 0.8,
                            height: constraints.maxHeight * 0.069,
                            child: TextField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: constraints.maxHeight * 0.024,
                              ),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.5)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.5)),
                                contentPadding: EdgeInsets.fromLTRB(
                                    constraints.maxHeight * 0.014,
                                    constraints.maxWidth * 0.014,
                                    0,
                                    constraints.maxWidth * 0.014),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                    size: constraints.maxHeight * 0.027,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      learn(
                                          searchedWord,
                                          constraints.maxHeight * 0.5,
                                          constraints.maxHeight * 0.1);
                                    });
                                  },
                                ),
                                labelText: 'Text Input',
                                labelStyle: TextStyle(
                                  fontSize: constraints.maxHeight * 0.02,
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (value) {
                                searchedWord = value;
                                if (value == "")
                                  setState(() {
                                    alphabets = [];
                                  });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0),
                      width: constraints.maxWidth * 0.8,
                      height: constraints.maxHeight * 0.7,
                      child: alpha(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}
