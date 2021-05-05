import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myluxurynewspaper/widgets/category_card.dart';
import 'package:myluxurynewspaper/constructors/category_list.dart';
import 'package:myluxurynewspaper/widgets/news_tile.dart';
import 'package:provider/provider.dart';
import 'package:myluxurynewspaper/provider_data.dart';


class NewsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'LUXURY NEWS',
          style: GoogleFonts.abrilFatface(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /// Categories
            Container(
              padding: EdgeInsets.only(left: 16.0,right: 16.0,top: 10.0),
              height: 70,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: getCategories().length,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      imageAssetUrl:
                          getCategories()[index].imageAssetUrl,
                      categoryName: getCategories()[index].categoryName,
                    );
                  }),
            ),

            /// News Article
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('${Provider.of<Data>(context).myCategory}').orderBy("ArticleNumber",descending: true).snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                 switch (snapshot.connectionState) {
                   case ConnectionState.waiting: return new Text('Loading...');
                   default:
                     return Container(
                       height: MediaQuery.of(context).size.height,
                       margin: EdgeInsets.only(top: 10.0,right: 10.0),
                       child: new ListView.builder(
                           scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.documents.length,
                           itemBuilder: (context, index) {
                             DocumentSnapshot category=snapshot.data.documents[index];
                             return NewsTile(
                               newsTileImage: '${category['Image']}',
                               newsTileTitle: '${category['Title']}',
                               newsTileDesc: '${category['Description']}',
                               author: '${category['Author']}',
                             );
                           }),
                     );
                 }
            }
            ),
          ],
        ),
      ),
    );
  }
}


