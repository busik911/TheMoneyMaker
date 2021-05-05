import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'file:///C:/Users/zahar/Desktop/flutter%20apps/my_luxury_newspaper/lib/widgets/first_page_reusable_card.dart';
import 'sign_in_comunity_screen.dart';
import 'podcast_screen.dart';
import 'news_screen.dart';




class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Image img1=Image.asset('images/rolls.jpg');
  Image img2=Image.asset('images/audioBook.jpg');
  Image img3=Image.asset('images/comunity.jpg');



  @override
  void initState() {
    super.initState();

      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Center(
          child: Text(
            'THE MONEY MAKER',
            style: GoogleFonts.abrilFatface(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/community.jpg'), fit: BoxFit.cover)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: FirstPageReusableCard(
                imageName: img1,
                categoryText: 'Luxury news',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NewsScreen();
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: FirstPageReusableCard(
                imageName: img2,
                categoryText: 'Podcast',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PodcastScreen();
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: FirstPageReusableCard(
                imageName: img3,
                categoryText: 'Enter comunity',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ComunityScreen();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}


