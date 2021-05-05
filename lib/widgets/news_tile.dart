import 'package:flutter/material.dart';
import 'package:myluxurynewspaper/screens/article_view.dart';
import 'package:cached_network_image/cached_network_image.dart';



class NewsTile extends StatefulWidget {
  NewsTile(
      {@required this.newsTileTitle,
      @required this.newsTileImage,
      @required this.newsTileDesc,@required this.author});

  final String newsTileImage;
  final String newsTileTitle;
  final String newsTileDesc;
  final String author;


  @override
  _NewsTileState createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addStatusListener((status) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ArticleView(
                      articleDescription: widget.newsTileDesc,
                      articleTitle: widget.newsTileTitle,
                      imageUrl: widget.newsTileImage,
                      author: widget.author,
                    )));
      },
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: Color(0xFF272B4A),),
          child: new Row(
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child:Container(
                    height: 130,
                    child: CachedNetworkImage(
                      imageUrl: widget.newsTileImage,
                      height: 130.0,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              new SizedBox(
                width: 10.0,
              ),
              new Expanded(
                flex: 2,
                child: new Container(
                  color: Color(0xFF272B4A),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        widget.newsTileTitle,
                        maxLines: 1,
                        style: TextStyle(fontSize: 21.0, color: Colors.white),
                      ),
                      new SizedBox(
                        height: 10.0,
                      ),
                      new Text(
                        '${widget.newsTileDesc}',
                        maxLines: 3,
                        style: TextStyle(fontSize: 17.0, color: Colors.white),
                      ),
                      new SizedBox(
                        height: 5.0,
                      ),
                      new Container(
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.remove_red_eye,
                              color: Colors.orange,
                            ),
                            new SizedBox(
                              width: 5.0,
                            ),
                            new Text(
                              "View",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel(){
    _controller.reverse();
  }
}
