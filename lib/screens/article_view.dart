import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ArticleView extends StatelessWidget {
  ArticleView({@required this.imageUrl, @required this.articleTitle,@required this.articleDescription,@required this.author});
 final String imageUrl;
 final String articleTitle;
 final String articleDescription;
 final String author;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Center(
          child: Text(
            'The Money-Maker',
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
                    child: ListView(
                      children: <Widget>[
                        //start first container..
                        new Container(
                          height: 250.0,
                          margin: EdgeInsets.all(10.0),
                          child: new ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: new Image.network(
                              this.imageUrl,
                              height: 250.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        //end first container..

                        new Container(
                          margin: EdgeInsets.all(10.0),
                          height: MediaQuery.of(context).size.height,
                          color: Color(0xFF272B4A),
                          child: SingleChildScrollView(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //first container...
                                new Container(
                                  margin: EdgeInsets.only(left:10.0),
                                  child: new Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        child:
                                        new Text('Logo'),
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                      new SizedBox(
                                        width: 8.0,
                                      ),
                                      new Container(
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: new Text(
                                            this.articleTitle,
                                            style: TextStyle(fontSize: 20.0, color: Colors.white,fontWeight: FontWeight.w700),
                                          ))
                                    ],
                                  ),
                                ), //end of first container
                                new SizedBox(
                                  height: 10.0,
                                ),
                               Padding(
                                 padding: const EdgeInsets.only(right:20.0),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
                                   children: [
                                     Text('By Teodor Kadiyski',style: TextStyle(fontSize: 15.0,color: Colors.yellow),),
                                   ],
                                 ),
                               ),
                                SizedBox(height: 10.0,),
                                new Text(
                                  this.articleDescription,
                                  style: TextStyle(fontSize: 17.0, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),  ),
    );
  }
}
