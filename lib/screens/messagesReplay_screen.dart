import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myluxurynewspaper/screens/sign_in_comunity_screen.dart';

class MessagesReplay extends StatelessWidget {
  final String firstDocID;
  final String secondDodId;
  final String username;
  final DocumentSnapshot replaysDoc;
  final String idToken;
  MessagesReplay(
      this.firstDocID, this.secondDodId, this.username, this.replaysDoc,this.idToken);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showModalBottomSheet(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      appBar: AppBar(
        title: Text('FORUM',
            style: GoogleFonts.abrilFatface(
              color: Colors.white,
              fontSize: 30.0,
            )),
        centerTitle: true,
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
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new ComunityScreen()));
              }),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/community.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('forumTopics')
                    .document('$firstDocID')
                    .collection('forumComments')
                    .document('$secondDodId')
                    .collection('forumCommentsReply')
                    .orderBy('commentNumber', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot topic =
                                snapshot.data.documents[index];
                            return MessageBox(
                              comment: '${topic['comment']}',
                              document: topic,
                              userName: this.username,
                              secondDocuID: secondDodId,
                              firstDocID: firstDocID,
                              replaysNum: this.replaysDoc,
                              idToken: this.idToken,
                            );
                          });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheet(context) {
    String newComment;
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
                      'Add Comment',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25.0, color: Colors.black87),
                    ),
                    TextField(
                      autofocus: true,
                      cursorColor: Colors.deepPurple,
                      textAlign: TextAlign.center,
                      onChanged: (newTitle) {
                        newComment = newTitle;
                      },
                    ),
                    FlatButton(
                      onPressed: () {
                        int queueOrder;
                        Firestore.instance
                            .collection('forumTopics')
                            .document('$firstDocID')
                            .collection('forumComments')
                            .document('$secondDodId')
                            .collection('forumCommentsReply')
                            .getDocuments()
                            .then((value) => {
                                  queueOrder = value.documents.length,
                                  Firestore.instance
                                      .collection('forumTopics')
                                      .document('$firstDocID')
                                      .collection('forumComments')
                                      .document('$secondDodId')
                                      .collection('forumCommentsReply')
                                      .add({
                                    'comment': newComment,
                                    'commentNumber': queueOrder + 1,
                                    'like': 0,
                                    'dislike': 0,
                                    'userName': username,
                                    'idToken': idToken,
                                  }),
                                  this.replaysDoc.reference.updateData(
                                      {'replaysNumber': queueOrder + 1})
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

class MessageBox extends StatefulWidget {
  final String comment;
  final String userName;
  final DocumentSnapshot document;
  final String secondDocuID;
  final String firstDocID;
  final DocumentSnapshot replaysNum;
  final String idToken;

  MessageBox(
      {@required this.comment,
      this.userName,
      this.document,
      this.firstDocID,
      this.secondDocuID,
      this.replaysNum,this.idToken});

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  bool dislike = false;
  bool like = false;
  int checkLike = 0;
  int checkDislike = 0;
  DocumentSnapshot userLikeDislike;
  int facebookAdmin= 4144842388889923;
  String gMailAdmin='GJ5gkdtPPgcqOBDWSzgJqivRyNj2';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    userLike();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 8.0,
        ),
        Container(
          height: 40.0,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 5.0),
                child: Icon(
                  FontAwesomeIcons.solidUserCircle,
                  color: Colors.black87,
                  size: 18.0,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.document['userName']}',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.solidThumbsUp,
                        color: like ? Colors.deepPurple : Colors.black87,
                        size: 18.0,
                      ),
                      onPressed: () {
                        _onPressedLike();
                      },
                    ),
                    Text(
                      '${widget.document['like']}',
                      style: TextStyle(color: Colors.black87, fontSize: 12.0),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.solidThumbsDown,
                        color: dislike ? Colors.deepPurple : Colors.black87,
                        size: 18.0,
                      ),
                      onPressed: () {
                        _onPressedDislike();
                      },
                    ),
                    Text(
                      '${widget.document['dislike']}',
                      style: TextStyle(color: Colors.black87, fontSize: 12.0),
                    ),
                    Visibility(
                      visible: '${widget.document['idToken']}' ==
                              '${widget.idToken}' || '${widget.idToken}' == facebookAdmin.toString() || '${widget.idToken}' == gMailAdmin
                          ? true
                          : false,
                      child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            int replyNo;
                            setState(() {
                              Firestore.instance
                                  .collection('forumTopics')
                                  .document('${widget.firstDocID}')
                                  .collection('forumComments')
                                  .document('${widget.secondDocuID}')
                                  .collection('forumCommentsReply')
                                  .getDocuments()
                                  .then((value) => {
                                        replyNo = value.documents.length,
                                        Firestore.instance
                                            .collection('forumTopics')
                                            .document('${widget.firstDocID}')
                                            .collection('forumComments')
                                            .document('${widget.secondDocuID}')
                                            .collection('forumCommentsReply')
                                            .document(
                                                '${widget.document.documentID}')
                                            .delete(),
                                        widget.replaysNum.reference.updateData(
                                            {'replaysNumber': replyNo - 1}),
                                      });
                            });
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.comment),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void userLike() async {
    try {
      DocumentSnapshot userLikes = await Firestore.instance
          .collection('forumTopics')
          .document('${widget.firstDocID}')
          .collection('forumComments')
          .document('${widget.secondDocuID}')
          .collection('forumCommentsReply')
          .document('${widget.document.documentID}')
          .collection('users')
          .document('${widget.idToken}')
          .get();
      setState(() {
        userLikeDislike = userLikes;
        checkLike = userLikeDislike.data['like'];
        checkDislike = userLikeDislike.data['dislike'];
      });
      if (checkLike == 0) {
        like = false;
      } else {
        like = true;
      }
      if (checkDislike == 0) {
        dislike = false;
      } else {
        dislike = true;
      }
    } catch (e) {}
  }

  _onPressedDislike() {
    setState(() {
      dislike = !dislike;
    });

    Firestore.instance
        .collection('forumTopics')
        .document('${widget.firstDocID}')
        .collection('forumComments')
        .document('${widget.secondDocuID}')
        .collection('forumCommentsReply')
        .document('${widget.document.documentID}')
        .collection('users')
        .document('${widget.idToken}')
        .setData({'like': 0, 'dislike': 1});

    if (like == false && dislike == false) {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 0});
      widget.document.reference
          .updateData({'dislike': widget.document['dislike'] - 1});
    } else if (like == false && dislike == true) {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 1});
      widget.document.reference
          .updateData({'dislike': widget.document['dislike'] + 1});
    } else if (like == true && dislike == false) {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 0});
      widget.document.reference
          .updateData({'dislike': widget.document['dislike'] - 1});
    } else {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 1});
      widget.document.reference
          .updateData({'dislike': widget.document['dislike'] + 1});
      widget.document.reference
          .updateData({'like': widget.document['like'] - 1});
      setState(() {
        like = false;
      });
    }
  }

  _onPressedLike() {
    setState(() {
      like = !like;
    });

    Firestore.instance
        .collection('forumTopics')
        .document('${widget.firstDocID}')
        .collection('forumComments')
        .document('${widget.secondDocuID}')
        .collection('forumCommentsReply')
        .document('${widget.document.documentID}')
        .collection('users')
        .document('${widget.idToken}')
        .setData({'like': 1, 'dislike': 0});

    if (like == false && dislike == false) {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 0});
      widget.document.reference
          .updateData({'like': widget.document['like'] - 1});
    } else if (like == true && dislike == false) {
      userLikeDislike.reference.updateData({'like': 1, 'dislike': 0});
      widget.document.reference
          .updateData({'like': widget.document['like'] + 1});
    } else if (like == false && dislike == true) {
      userLikeDislike.reference.updateData({'like': 0, 'dislike': 0});
      widget.document.reference
          .updateData({'like': widget.document['like'] - 1});
    } else {
      userLikeDislike.reference.updateData({'like': 1, 'dislike': 0});
      widget.document.reference
          .updateData({'like': widget.document['like'] + 1});
      widget.document.reference
          .updateData({'dislike': widget.document['dislike'] - 1});
      setState(() {
        dislike = false;
      });
    }
  }
}
