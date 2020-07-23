
import 'package:flutter/widgets.dart';

class BaseWindow{
  static OverlayEntry _overlayEntry;
  bool _showing;

  void show(BuildContext context, Widget widget, {top: -1}){
     OverlayState overlayState = Overlay.of(context);
      //TODO handle base window
     _showing = true;
     _overlayEntry = OverlayEntry(
         builder: (BuildContext context) => Positioned(
           //top effect the position of widget
           top: top,
           child: Container(
               alignment: Alignment.center,
               width: MediaQuery.of(context).size.width,
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 40.0),
                 child: AnimatedOpacity(
                   opacity: _showing ? 1.0 : 0.0, //目标透明度
                   duration: _showing
                       ? Duration(milliseconds: 100)
                       : Duration(milliseconds: 400),
                   child: widget,
                 ),
               )),
         ));
     //overlap on top
     overlayState.insert(_overlayEntry);
  }
}