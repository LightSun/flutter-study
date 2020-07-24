import 'package:flutter/widgets.dart';

typedef ShowCallback = Future Function(bool);
typedef DismissDelegate = Future Function();
//typedef VoidCallback = void Function();

class _PendingAction{
  int showTimeMsec = -1;
  OverlayEntry below;
  OverlayEntry above;
}
///the pending work mode for show.
enum PendingWorkMode{
  /// when show is called, but window is pending. this request will be dropped.
  DROP,
  /// hen show is called, but window is pending. this request will cause dismiss and then continue show.
  DISMISS_BEFORE,
  /// hen show is called, but window is pending. this request will cause [DismissDelegate] call and then continue show.
  DISMISS_DELEGATE_BEFORE
}

class BaseWindow {
  OverlayEntry _overlayEntry;
  BuildContext _context;
  bool _showing = false;
  final ShowCallback _showCallback;
  final DismissDelegate _dismissDelegate;
  bool _pending = false;

  PendingWorkMode _mode;
  _PendingAction _pendingAction;

  OverlayEntry get overlayEntry => _overlayEntry;
  BuildContext get buildContext => _context;

  //private constructor
  BaseWindow._(this._context, this._overlayEntry, this._showCallback, this._dismissDelegate, this._mode);

  ///
  /// create base window by context , widget and callback.
  /// * context: the build context
  /// * child: the widget to display
  /// * top: margin top for this window to show. if < 0 means, use child to show directly, or else use Positioned.
  /// * showCallback: callback on shown or not.return a [Future].
  /// * dismissDelegate: called when you want to dismiss window.
  /// eg: animation. you should return a [Future].
  ///
  factory BaseWindow.of(BuildContext context, Widget child,
      {PendingWorkMode mode = PendingWorkMode.DISMISS_BEFORE,
        double top = 0.0,
        showCallback,
        dismissDelegate}) {
    //AnimatedOpacity
    OverlayEntry entry = OverlayEntry(
        builder: (BuildContext context) => top >= 0 ? Positioned(
              //top effect the position of widget
              top: top,
              child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: child),
            ) :
        OverlayEntry(builder: (BuildContext context) => child)
    );
    return BaseWindow._(context, entry, showCallback, dismissDelegate, mode);
  }

  ///
  /// show the window right-now.
  /// * showTimeMsec: if you want to auto-dismiss window. you may set this value.
  /// * below:  the below [OverlayEntry].
  /// * above: the above [OverlayEntry].
  void show({int showTimeMsec = -1, OverlayEntry below, OverlayEntry above}) async{
    assert(!isDisposed());
    if(_pending){
      switch(_mode){
        case PendingWorkMode.DROP:
          return;

        case PendingWorkMode.DISMISS_BEFORE:
          _pendingAction = new _PendingAction()
            ..showTimeMsec = showTimeMsec
            ..below = below
            ..above = above;
          _showing = false;
          _dismissImpl();
          return;

        case PendingWorkMode.DISMISS_DELEGATE_BEFORE:
          _pendingAction = new _PendingAction()
            ..showTimeMsec = showTimeMsec
            ..below = below
            ..above = above;
          dismiss();
          return;
      }
      print("_pendingDismiss = true. drop this request.");
      return;
    }
    OverlayState overlayState = Overlay.of(_context);
    //overlap on top
    _showing = true;
    overlayState.insert(_overlayEntry, below: below, above: above);
    Future future;
    if (_showCallback != null) {
      future = _showCallback.call(true);
    }
    //if has show time. auto-dismiss
    if(showTimeMsec > 0){
      if(future != null) {
        _pending = true;
        future.then((value) async {
          if(_pending){
            _pending = false;
            await Future.delayed(Duration(milliseconds: showTimeMsec));
            dismiss();
          }
        });
      }else{
        await Future.delayed(Duration(milliseconds: showTimeMsec));
        dismiss();
      }
    }
  }

  void markNeedsBuild() {
    if (_overlayEntry != null) {
      _overlayEntry.markNeedsBuild();
    }
  }

  void dismiss({bool useDelegate = true}) {
    if (_showing) {
      _showing = false;
      if(useDelegate && _dismissDelegate != null){
        _pending = true;
        _dismissDelegate.call().then((value) {
          if(_pending){
            _dismissImpl();
          }
        });
      }else{
        _dismissImpl();
      }
    }
  }
  void _dismissImpl(){
    _pending = false;
    if (_overlayEntry != null) {
      _overlayEntry.remove();
    }
    if (_showCallback != null) {
      _showCallback.call(false);
    }
    if(_pendingAction != null){
      final _PendingAction ac = _pendingAction;
      _pendingAction = null;
      show(showTimeMsec: ac.showTimeMsec,
          below: ac.below,
          above: ac.above);
    }
  }
  /// is pending showing or dismiss.
  bool isPending() => _pending;
  /// is shown or not
  bool isShown() => _showing;
  /// is disposed or not
  bool isDisposed() => _context == null;

  /// dispose
  void dispose() {
    dismiss(useDelegate: false);
    _overlayEntry = null;
    _context = null;
  }
}

typedef WindowCreator = BaseWindow Function(BuildContext context);

class Window {
  final WindowCreator _creator;

  Window(this._creator);

  BaseWindow _window;

  BaseWindow baseWindow(BuildContext context) => _window ??= _creator.call(context);

  void show(BuildContext context,
      {int showTimeMsec = -1, OverlayEntry below,
      OverlayEntry above}) {
    baseWindow(context).show(showTimeMsec: showTimeMsec, below: below, above: above);
  }

  bool isShown() => _window != null && _window.isShown();

  void dispose() {
    if (_window != null) {
      _window.dispose();
      _window = null;
    }
  }

  void dismiss() {
    if (_window != null) {
      _window.dismiss();
    }
  }

  /// toggle show state of window.
  void toggleShow(BuildContext context,
      {int showTimeMsec = -1, OverlayEntry below,
      OverlayEntry above}) {
    if (isShown()) {
      _window.dismiss();
    } else {
      baseWindow(context).show(showTimeMsec: showTimeMsec, below: below,above: above);
    }
  }
}
