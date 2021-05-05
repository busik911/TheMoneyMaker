import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:myluxurynewspaper/provider_data.dart';
import 'screens/start_screen.dart';
import 'package:provider/provider.dart';
import 'screens/podcast_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await queue1();
  runApp(MaterialApp(home:MyApp(),),);}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final SnackBar snackBar=SnackBar(
          content: Container(
            height: 50,
            child: Column(
              children: [
                Text(message['notification']['title'],maxLines: 2,),
                Text(message['notification']['body'],maxLines: 2,),],
            ),
          ),
          action: SnackBarAction(label: 'CLOSE', onPressed: () => {
            _scaffoldKey.currentState.removeCurrentSnackBar(),
          }),
          duration: Duration(seconds:20),
        );
//        Scaffold.of(context).showSnackBar(snackBar);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
    _firebaseMessaging.subscribeToTopic("all");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<Data>(
        create: (context)=>Data(),
        child: MaterialApp(
          theme: ThemeData(primaryColor: Colors.grey.shade900,backgroundColor: Colors.black87),
          home: AudioServiceWidget(child: StartScreen()),
        ),
      ),
      key: _scaffoldKey,
    );
  }
}

