import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myluxurynewspaper/constructors/user_details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myluxurynewspaper/screens/messages_screen.dart';
import 'package:myluxurynewspaper/screens/sign_in_comunity_screen.dart';


class CommunityForum extends StatefulWidget {
  final UserDetails detailsUser;

  CommunityForum({Key key, @required this.detailsUser,}) : super(key: key);

  @override
  _CommunityForumState createState() => _CommunityForumState();
}

class _CommunityForumState extends State<CommunityForum>
    with TickerProviderStateMixin {
  AnimationController _hideFabAnimation;

  @override
  initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }




  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation,
          child: Visibility(
            visible: false,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showModalBottomSheet(context);
              },
              icon:Icon(
                Icons.add,
                size: 20.0,
              ),
              label:Text(
                'Add Topic',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.deepPurple,
            ),
          ),
        ),
        appBar: AppBar(
          title: Center(
            child: Text(
              'FORUM',
              style: GoogleFonts.abrilFatface(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  FontAwesomeIcons.signOutAlt,
                  size: 20.0,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  signOutGoogle();
                  facebookLogOut();
                  Navigator.pop(context);
                }),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/community.jpg'),
                  fit: BoxFit.cover)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome',
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                if(widget.detailsUser.image!=null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.detailsUser.image),
                  ),
                Text(
                  widget.detailsUser.name,
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
                SizedBox(height:10.0 ,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Topic',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('forumTopics')
                        .orderBy('artNumber', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return new Center(child: CircularProgressIndicator(),);
                        default:
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot topic =
                                    snapshot.data.documents[index];
                                return TopicTile(
                                  topicTitle: '${topic['title']}',
                                  messagesReplays: topic['comments'],
                                  views: topic['views'],
                                  document: topic,
                                  userName: widget.detailsUser.name,
                                  idToken: widget.detailsUser.idToken,
                                );
                              });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(context) {
    String newForumTitle;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.transparent.withOpacity(1.0),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 25.0,
                    right: 25.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Add Title',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25.0, color: Colors.black87),
                    ),
                    TextField(
                      autofocus: true,
                      cursorColor: Colors.deepPurple,
                      textAlign: TextAlign.center,
                      onChanged: (newTitle) {
                        newForumTitle = newTitle;
                      },
                    ),
                    FlatButton(
                      onPressed: () {
                        int queueOrder;
                        Firestore.instance
                            .collection('forumTopics')
                            .getDocuments()
                            .then((value) => {
                                  queueOrder = value.documents.length,
                                  Firestore.instance
                                      .collection('forumTopics')
                                      .add({
                                    'title': newForumTitle,
                                    'artNumber': queueOrder + 1,
                                    'views': 0,
                                    'comments': 0,
                                  }),
                                });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class TopicTile extends StatefulWidget {
  final String topicTitle;
  final int views;
  final int messagesReplays;
  final DocumentSnapshot document;
  final String userName;
  final String idToken;
  TopicTile(
      {this.messagesReplays,
      this.topicTitle,
      this.views,
      this.document,
      this.userName,this.idToken});

  @override
  _TopicTileState createState() => _TopicTileState();
}

class _TopicTileState extends State<TopicTile>
    with SingleTickerProviderStateMixin {
  String documentID;
  String title;


  AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1 - _animationController.value;
    return GestureDetector(
      onTap: () {
        widget.document.reference.updateData({
          'views': widget.document['views'] + 1,
        });
        documentID = widget.document.documentID;
        title = widget.topicTitle;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessagesScreen(
                    documentID: documentID,
                    title: title,
                    userName: widget.userName,
                    documentSnapshot: widget.document,
                idToken: widget.idToken,
                  )),

        );

      },
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 10.0),
          height: 70.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(FontAwesomeIcons.searchDollar)],
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.topicTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.0),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.views.toString()),
                      SizedBox(
                        width: 2.0,
                      ),
                      Icon(Icons.remove_red_eye),
                    ],
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.messagesReplays.toString()),
                      SizedBox(
                        width: 2.0,
                      ),
                      Icon(FontAwesomeIcons.commentsDollar),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  onTapCancel() {
    _animationController.reverse();
  }
}
