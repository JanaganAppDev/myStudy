import 'package:flutter/material.dart';

class ScreenLifecyle extends StatefulWidget {
  late ScreenLifecyleState state;

  //createState(): When the Framework is instructed to build a StatefulWidget, it immediately calls createState()
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScreenLifecyleState();
  }
}

class ScreenLifecyleState extends State<ScreenLifecyle> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print("didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    print("build");

    // TODO: implement build
    return Container();
  }

  @override
  void didUpdateWidget(ScreenLifecyle oldWidget) {
    print("didUpdateWidget");

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(fn) {
    print("setState");

    // TODO: implement setState
    super.setState(fn);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    print("deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;

      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }
}
