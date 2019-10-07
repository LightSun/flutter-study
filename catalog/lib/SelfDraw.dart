import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


void main() {
  runApp(Wrapper());
}

num degToRad(num deg) => deg * (pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / pi);

//CustomPaint包装CustomPainter为widget
class MyPainter extends CustomPainter {
  double _startAngle = -90; //0-360
  final double _sweepAngle;
  Color _defaultColor = Colors.black45;
  Color _processColor = Colors.amberAccent;
  final Paint _paint = Paint();
  final double _strokeWidth;

  MyPainter(this._strokeWidth, this._sweepAngle):
      assert(_strokeWidth > 0),
      assert(_sweepAngle >= 0);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    _paint
      ..color = _processColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final Rect rect = Rect.fromLTWH(_strokeWidth / 2, _strokeWidth / 2, size.width - _strokeWidth, size.height - _strokeWidth);
    canvas.drawArc(rect, degToRad(_startAngle), degToRad(_sweepAngle), false, _paint);

    _paint..color = _defaultColor;
   /* canvas.drawArc(
        rect, _startAngle + _sweepAngle, 360 - _startAngle, false, _paint);*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //print("shouldRepaint");
    return oldDelegate != this;
  }
}

class Wrapper extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return WrapperState();
  }
}

class WrapperState extends State<Wrapper> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  double _sweepAngle = 180;

  @override
  void initState() {
    super.initState();
    /*_controller =
    AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
      ..repeat()
      ..addListener(() {
        addAngle(_controller.value);
      });*/
  }
  @override
  void dispose() {
    super.dispose();
   // _controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return CustomPaint(size: Size(200, 200),
        painter: MyPainter(10, _sweepAngle) ,
    child: GestureDetector(onPanEnd: _onPanEnd,),);
  }

  void _onPanEnd(DragEndDetails dud){
    addAngle(30);
  }
 //数据的更新必须放在状态里面
  void addAngle(double angle){
    setState(() {
      _sweepAngle += angle;
      _sweepAngle = _sweepAngle % 360;
    });
  }
}
