import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myluxurynewspaper/constructors/user_details.dart';
import 'package:myluxurynewspaper/screens/community_screen.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email'
  ],
);
var facebookLogin=new FacebookLogin();


class ComunityScreen extends StatefulWidget {

  @override
  _ComunityScreenState createState() => _ComunityScreenState();
}

class _ComunityScreenState extends State<ComunityScreen> {

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();



  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            'COMMUNITY',
            style: GoogleFonts.abrilFatface(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/community.jpg'), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SignInContainer(
                    authButton: SignInButton(
                      onPressed:  () {
                        _googleSignUp(context);
                      },
                      color: Colors.lightBlueAccent,
                      icon: Container(
                        width: 25.0,
                        height: 30.8,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/google_icon.png'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      text: 'Sign in with Google',
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SignInContainer(
                    authButton: SignInButton(
                      onPressed: (){
                        singInWithFacebook();
                      },
                      color: Colors.blueAccent,
                      icon: Icon(
                       FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                      text: 'Sign in with Facebook',
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _googleSignUp(BuildContext context) async {
    try {

      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      UserDetails userDetails=UserDetails(name:user.displayName, image: user.photoUrl,idToken: user.uid);
      if(user!=null){
        Navigator.push(context, new MaterialPageRoute(builder: (context)=> new CommunityForum(detailsUser:userDetails),
        ),);
      }
      return user;
    }catch (e) {
      print(e.message);
    }


  }
  Future<void>singInWithFacebook()async{
    try{

      var result=await facebookLogin.logIn(['email']);
      if(result.status==FacebookLoginStatus.loggedIn){
        print('User logged in');
        final AuthCredential credential=FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );

        final FirebaseUser user=(await FirebaseAuth.instance.signInWithCredential(credential)).user;

        UserDetails userDetails=UserDetails(name:user.displayName, image: user.photoUrl,idToken: result.accessToken.userId);
        if(user!=null){
          Navigator.push(context, new MaterialPageRoute(builder: (context)=> new CommunityForum(detailsUser:userDetails),
          ),);
        }
        return user;
      }
    }
    catch(e){
      print(e);
    }
  }
}

class SignInContainer extends StatelessWidget {
  final Color color;
  final Widget authButton;
  SignInContainer({this.color, @required this.authButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        color: color,
      ),
      child: authButton,
    );
  }
}

class SignInButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;
  SignInButton(
      {this.text, this.icon, this.color, @required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: color,
      padding: EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          SizedBox(
            width: 40.0,
          ),
          Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
void signOutGoogle() async{
  await _googleSignIn.signOut();
  print('google log out');

}
void facebookLogOut()async{
  await facebookLogin.logOut();
  print('facebook log out');
}