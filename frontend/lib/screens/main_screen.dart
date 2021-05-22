import 'package:abc/screens/learning_screen.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'package:abc/screens/VC_index.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final carousel = Carousel(
    boxFit: BoxFit.cover,
    images: [
      AssetImage('assets/images/c1.png'),
      AssetImage('assets/images/c2.png'),
      AssetImage('assets/images/c3.png')
    ],
    animationCurve: Curves.fastOutSlowIn,
    animationDuration: Duration(milliseconds: 1500),
  );
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'LetsSign',
            style: TextStyle(color: Colors.black, fontSize: 26),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                    child: new ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: carousel),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    height: constraints.maxHeight * 0.3,
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.065,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RawMaterialButton(
                          elevation: 10,
                          fillColor: Color(0xffFF9F1C),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                              width: constraints.maxWidth * 0.4,
                              height: constraints.maxHeight * 0.2,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        image: AssetImage(
                                            'assets/images/camera.png'),
                                        height: constraints.maxHeight * 0.07,
                                        width: constraints.maxHeight * 0.07),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'Camera',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )
                                  ])),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CameraScreen()));
                          }),
                      RawMaterialButton(
                          elevation: 10,
                          fillColor: Color(0xffE71D36),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                              width: constraints.maxWidth * 0.4,
                              height: constraints.maxHeight * 0.2,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        image: AssetImage(
                                            'assets/images/video-call.png'),
                                        height: constraints.maxHeight * 0.07,
                                        width: constraints.maxHeight * 0.07),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'Video Call',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )
                                  ])),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VCIndexPage()));
                          })
                    ],
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.04,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    RawMaterialButton(
                        elevation: 10,
                        fillColor: Color(0xFF2EC4B6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Container(
                            width: constraints.maxWidth * 0.4,
                            height: constraints.maxHeight * 0.2,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                      image: AssetImage(
                                          'assets/images/presentation.png'),
                                      height: constraints.maxHeight * 0.07,
                                      width: constraints.maxHeight * 0.07),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      'Learn',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )
                                ])),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LearningScreen()));
                        })
                  ])
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
