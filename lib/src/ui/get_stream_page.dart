import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_stream_page/src/controller/connecty_controller.dart';
import 'package:get_stream_page/src/controller/get_stream_controller.dart';
import 'package:get_stream_page/src/ui/utils/functions.dart';

import 'infra/rx_get_type.dart';
import 'widgets/connecty_widget.dart';

class GetStreamPage<T> extends StatefulWidget {
  ///[listRx] If you want to add observable variables so that changes to
  ///them generate changes on the screen, add to the list of [RxItem] as
  ///an example.
  final List<RxItem> listRx;

  ///[stream] Just pass your stream and you will receive [streamObject] which is
  ///snapshot.data to build your page.
  final Stream<T> stream;

  /// [widgetErrorBuilder] Widget built by the Object error returned by the
  /// [stream] error.
  final WidgetsErrorBuilder widgetErrorBuilder;

  ///[widgetBuilder] This function is launched every time we receive
  ///snapshot.data through the stream. To set up your page you receive
  ///the context, the [streamObject] which is snapshot.data and an [RxGetSet]
  ///object to harvest the reactive variable by the tag. You can present
  ///something if the user is not logged in, for example.
  final GetWidgetBuilder<T> widgetBuilder;

  /// [widgetOffConnectyWaiting] Only shows something when it is disconnected
  /// and still doesn't have the first value in the stream. If the connection
  /// comes back starts showing [widgetWaiting] until it shows the first data
  final Widget widgetWaiting;
  final Widget widgetOffConnectyWaiting;

  /// [floatingActionButton] , [pageDrawer] ,
  /// [floatingActionButtonLocation] ,
  /// [floatingActionButtonAnimator]  ...
  /// ...
  /// are passed on to the Scaffold.
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final FloatingActionButtonAnimator floatingActionButtonAnimator;
  final List<Widget> persistentFooterButtons;
  final Widget pageDrawer;
  final Widget pageEndDrawer;
  final Widget pageBottomNavigationBar;
  final Widget pageBottomSheet;
  final Color pageBackgroundColor;
  final bool resizeToAvoidBottomPadding;
  final bool resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color drawerScrimColor;
  final double drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;

  ///AppBar parameters
  ///
  final Color appBarbackgroundColor;
  final Widget title;
  final bool centerTitle;
  final IconThemeData iconTheme;
  final double elevation;
  final List<Widget> actions;

  /// [iconConnectyOffAppBar] Displayed on the AppBar when the internet
  /// connection is switched off.
  /// It is always the closest to the center.
  final Widget iconConnectyOffAppBar;
  final Color iconConnectyOffAppBarColor;

  ///[iconConnectyOffAppBar] Appears when the connection status is off.
  ///There is already a default icon. If you don't want to present a choice
  ///[hideDefaultConnectyIconOffAppBar] = true; If you want to have a
  ///custom icon, do [hideDefaultConnectyIconOffAppBar] = true; and set the
  ///[iconConnectyOffAppBar]`.
  final bool hideDefaultConnectyIconOffAppBar;

  const GetStreamPage(
      {Key key,
      @required this.stream,
      @required this.widgetBuilder,
      this.listRx = const <RxItem>[],
      this.widgetErrorBuilder,
      this.widgetWaiting,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.floatingActionButtonAnimator,
      this.persistentFooterButtons,
      this.pageDrawer,
      this.pageEndDrawer,
      this.pageBottomNavigationBar,
      this.pageBottomSheet,
      this.pageBackgroundColor,
      this.resizeToAvoidBottomPadding,
      this.resizeToAvoidBottomInset,
      this.primary = true,
      this.drawerDragStartBehavior = DragStartBehavior.start,
      this.extendBody = false,
      this.extendBodyBehindAppBar = false,
      this.drawerScrimColor,
      this.drawerEdgeDragWidth,
      this.drawerEnableOpenDragGesture = true,
      this.endDrawerEnableOpenDragGesture = true,
      this.appBarbackgroundColor,
      this.title,
      this.centerTitle = false,
      this.elevation = 4.0,
      this.actions = const <Widget>[],
      this.iconTheme,
      this.widgetOffConnectyWaiting,
      this.iconConnectyOffAppBar,
      this.hideDefaultConnectyIconOffAppBar = false,
      this.iconConnectyOffAppBarColor})
      //: assert(S is List<DisposableInterface>),
      : super(key: key);

  @override
  _GetStreamPageState<T> createState() => _GetStreamPageState<T>();
}

class _GetStreamPageState<T> extends State<GetStreamPage<T>> {
  //List<DisposableInterface> _listControllers;

  //Rx<T> innerController;

  StreamSubscription<T> _subscription;

  GetStreamController<T> _controller;

  Widget _widgetWaiting;

  bool downConnectyWithoutData = false;

  Widget _widgetConnecty;

  StreamSubscription _subscriptionConnecty;
  ConnectController _connectyController;

  T objesctStream;

  Widget _iconConnectyOffAppBar;

  RxGetSet _rxSet;

  @override
  void initState() {
    _controller = GetStreamController();
    _rxSet = RxGetSet(widget.listRx);
    super.initState();
    _subscribeStream();
    _subscribeConnecty();
    _buildWidgetsDefault();
  }

  @override
  void dispose() {
    _controller.onClose();
    _unsubscribeConnecty();
    _unsubscribeStream();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GetStreamPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stream != widget.stream) {
      if (_subscription != null) {
        _unsubscribeStream();

        _controller.afterDisconnected();
      }

      _subscribeStream();
    }
  }

  void _subscribeStream() {
    _subscription = widget.stream.listen((data) {
      if (data == null) {
        _controller.afterError(Exception('It cannot return null. 😢'));
        return;
      } else {
        objesctStream ??= data;
        downConnectyWithoutData = false;
        _unsubscribeConnecty();
        _controller.afterData(data);
      }
    }, onError: (Object error) {
      _controller.afterError(error);
    }, onDone: () {
      _controller.afterDone();
    });

    //_controller.afterConnected();
  }

  void _unsubscribeStream() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  void _subscribeConnecty() {
    _connectyController = ConnectController();
    _subscriptionConnecty =
        _connectyController.connectStream.listen((bool isConnected) {
      if (!isConnected) {
        //lançar _widgetConnecty
        setState(() {
          downConnectyWithoutData = true;
        });
      } else if (isConnected && objesctStream == null) {
        setState(() {
          downConnectyWithoutData = false;
          _controller.afterConnected();
        });
      }
    });
  }

  void _unsubscribeConnecty() {
    if (_subscriptionConnecty != null) {
      _subscriptionConnecty.cancel();
      _subscriptionConnecty = null;
      _connectyController.onClose();
    }
  }

  void buildwidgetConnecty() {
    if (widget.iconConnectyOffAppBar == null &&
        !widget.hideDefaultConnectyIconOffAppBar) {
      _iconConnectyOffAppBar = ConnectyWidget(
        color: widget.iconConnectyOffAppBarColor,
      );
    } else if (widget.hideDefaultConnectyIconOffAppBar) {
      if (widget.iconConnectyOffAppBar != null) {
        _iconConnectyOffAppBar = widget.iconConnectyOffAppBar;
      }
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final increasedActions = <Widget>[];
    increasedActions.addAll(widget.actions);

    if (_iconConnectyOffAppBar != null) {
      increasedActions.insert(0, _iconConnectyOffAppBar);
    }

    return AppBar(
      backgroundColor:
          widget.appBarbackgroundColor ?? Theme.of(context).appBarTheme.color,
      iconTheme: widget.iconTheme ?? Theme.of(context).appBarTheme.iconTheme,
      title: widget.title,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      actions: increasedActions,
    );
  }

  /*List<RxItem> get list {

    List<RxItem> list = [];
    for (var i = 0; i < widget.listRx.length; ++i) {
      if(widget.listRx[i] is RxList){
        list.add(widget.listRx[i].rx as RxList);

      } else
        {
          list.add(widget.listRx[i]);
        }


    }
  }*/

  Widget buildBody() {
    return Obx(() {
      if (downConnectyWithoutData) {
        // Apenas anuncia quando nao tem a primeira data e esta sem conexao
        return _widgetConnecty;
      }

      if (_controller.snapshot.connectionState == ConnectionState.waiting) {
        return _widgetWaiting;
      }

      if (_controller.snapshot.hasError) {
        return buildWidgetError(_controller.snapshot.error);
      }

      return widget.widgetBuilder(
          //context, _controller.snapshot.data, widget.listRx);
          context,
          _controller.snapshot.data,
          _rxSet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: buildBody(),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.pageDrawer,
        endDrawer: widget.pageEndDrawer,
        bottomNavigationBar: widget.pageBottomNavigationBar,
        bottomSheet: widget.pageBottomSheet,
        backgroundColor: widget.pageBackgroundColor,
        resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture);
  }

  Widget buildWidgetError(Object error) {
    if (widget.widgetErrorBuilder == null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'We found an error.\n'
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ]);
    } else {
      return widget.widgetErrorBuilder(error);
    }

    //return _widgetError;
  }

  void _buildWidgetsDefault() {
    if (widget.widgetOffConnectyWaiting == null) {
      _widgetConnecty = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Check connection...',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      );
    } else {
      _widgetConnecty = widget.widgetOffConnectyWaiting;
    }
    if (widget.widgetWaiting == null) {
      _widgetWaiting = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      _widgetWaiting = widget.widgetWaiting;
    }
  }
}
