import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ParentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ParentWidget();
  }
}

class _ParentWidget extends State<ParentWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TapboxC());
  }
}
//-----------------

//----------------------------- TapboxC ------------------------------
class TapboxC extends StatefulWidget {
  TapboxC({Key key})
      : super(key: key);
  _TapboxCState createState() => new _TapboxCState();
}

class _TapboxCState extends State<TapboxC> {

  void _onVerDragStart(DragStartDetails dsd) {
    //TODO
    double dy = dsd.localPosition.dy;
    print("_onVerDragStart >>> dy = $dy");
  }

  void _onVerDragEnd(DragEndDetails dsd) {
    print("_onVerDragEnd ! ");
  }

  void _onVerDragUpdate(DragUpdateDetails dsd) {
    //TODO
    double dy = dsd.localPosition.dy;
    print("_onVerDragUpdate>>> dy = $dy");
  }

  Widget build(BuildContext context) {
    // This example adds a green border on tap down.
    // On tap up, the square changes to the opposite state.
    /* return  GestureDetector(
      onTapDown: _handleTapDown, // Handle the tap events in the order that
      onTapUp: _handleTapUp,     // they occur: down, up, tap, cancel
      onTap: _handleTap,
      onTapCancel: _handleTapCancel,
      child:  Container(
        child:  Center(
          child:  Text(
            widget.active ? 'Active' : 'Inactive',
            style:  TextStyle(fontSize: 32.0, color: Colors.white),
          ),
        ),
        width: 200.0,
        height: 200.0,
        decoration:  BoxDecoration(
          color: widget.active ? Colors.lightGreen[700] : Colors.grey[600],
          border: _highlight
              ?  Border.all(color: Colors.teal[700], width: 10.0,)
              : null,
        ),
      ),
    );*/
    return GestureDetector(
        onVerticalDragStart: _onVerDragStart,
        onVerticalDragEnd: _onVerDragEnd,
        onVerticalDragUpdate: _onVerDragUpdate,
        child: Container(
            child: Center(
              child: Text(
                'Scroll',
                style: TextStyle(fontSize: 32.0, color: Colors.amberAccent),
              ),
            ),
            width: 200.0,
            height: 200.0));
  }
}

//---------- main ---------------
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Demo'),
        ),
        body: Center(
          child: ParentWidget(),
        ),
      ),
    );
  }
}
