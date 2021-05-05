import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstPageReusableCard extends StatefulWidget {
  FirstPageReusableCard({@required this.categoryText,@required this.imageName,this.onTap});
  final  imageName;
  final String categoryText;
  final VoidCallback onTap;

  @override
  _FirstPageReusableCardState createState() => _FirstPageReusableCardState();
}

class _FirstPageReusableCardState extends State<FirstPageReusableCard> with SingleTickerProviderStateMixin{
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
      onTap: widget.onTap  ,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 5.0),
                    blurRadius: 30.0),
              ],
              image: DecorationImage(
                image: widget.imageName.image,
                fit: BoxFit.cover,
              )),
          child: Text(
            widget.categoryText,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 25.0,fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
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
