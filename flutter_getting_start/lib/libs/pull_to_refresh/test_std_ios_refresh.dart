import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  runApp(BaseApp());
}

class BaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PullToRrFresh api Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new IosTest(),
    );
  }
}

class IosTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<IosTest> {

  var _list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("--- get more data");
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: new Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              // If left unspecified, the [CustomScrollView] appends an
              // [AlwaysScrollableScrollPhysics]. Behind the scene, the ScrollableState
              // will attach that [AlwaysScrollableScrollPhysics] to the output of
              // [ScrollConfiguration.of] which will be a [ClampingScrollPhysics]
              // on Android.
              // To demonstrate the iOS behavior in this demo and to ensure that the list
              // always scrolls, we specifically use a [BouncingScrollPhysics] combined
              // with a [AlwaysScrollableScrollPhysics]
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    largeTitle: const Text("Hot news"),
                  ),
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      setState(() {
                        _list.add(_list.length + 1);
                      });
                    },
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((content, index) {
                      return ListTile(
                        title: Text('google ${_list[index]}'),
                      );
                    }, childCount: _list.length),
                  )
                ],
    )
        )
    );
  }
}

///It's due to the ScrollPhysics which is used on Android. iOS uses BouncingScrollPhysics which doesn't
///apply any boundary conditions when applyBoundaryConditions is called i.e.
/// it allows for under/overscrolling.
class CustomClampingScrollPhysics extends ClampingScrollPhysics {
  const CustomClampingScrollPhysics({
    ScrollPhysics parent,
    this.canUnderscroll = false,
    this.canOverscroll = false,
  }) : super(parent: parent);

  final bool canUnderscroll;

  final bool canOverscroll;

  @override
  CustomClampingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomClampingScrollPhysics(
        parent: buildParent(ancestor),
        canUnderscroll: canUnderscroll,
        canOverscroll: canOverscroll);
  }

  /// Removes the overscroll and underscroll conditions from the original
  /// [ClampingScrollPhysics.applyBoundaryConditions].
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll
      return canUnderscroll ? 0.0 : value - position.pixels;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overscroll
      return canOverscroll ? 0.0 : value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }
}
