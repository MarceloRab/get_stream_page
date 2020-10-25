import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_stream_page/src/controller/get_stream_controller.dart';
import 'package:get_stream_page/src/ui/utils/functions.dart';
import 'infra/rx_get_type.dart';

class GetStreamWidget<T> extends StatefulWidget {
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

  ///[obxWidgetBuilder] This function is launched every time we receive
  ///snapshot.data through the stream. To set up your page you receive
  ///the context, the [streamObject] which is snapshot.data and an [RxGetSet]
  ///object to harvest the reactive variable by the tag. You can present
  ///something if the user is not logged in, for example.
  final GetWidgetBuilder<T> obxWidgetBuilder;

  /// Start showing [widgetWaiting] until it shows the first data
  final Widget widgetWaiting;

  const GetStreamWidget(
      {Key key,
      @required this.stream,
      this.widgetErrorBuilder,
      this.listRx = const <RxItem>[],
      this.obxWidgetBuilder,
      this.widgetWaiting})
      : super(key: key);

  @override
  _GetStreamWidgetState<T> createState() => _GetStreamWidgetState<T>();
}

class _GetStreamWidgetState<T> extends State<GetStreamWidget<T>> {
  StreamSubscription<T> _subscription;

  GetStreamController<T> _controller;

  Widget _widgetWaiting;

  RxGetSet _rxSet;

  @override
  void initState() {
    _controller = GetStreamController();
    _rxSet = RxGetSet(widget.listRx);
    super.initState();
    _subscribeStream();
    _buildWidgetsDefault();
  }

  @override
  void dispose() {
    _controller.onClose();
    _unsubscribeStream();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GetStreamWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    /*if (oldWidget.listRx != widget.listRx) {
      _rxSet = RxGetSet(widget.listRx);
    }*/

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
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.snapshot.connectionState == ConnectionState.waiting) {
        return _widgetWaiting;
      }

      if (_controller.snapshot.hasError) {
        return buildWidgetError(_controller.snapshot.error);
      }

      return widget.obxWidgetBuilder(
          //context, _controller.snapshot.data, widget.listRx);
          context,
          _controller.snapshot.data,
          _rxSet);
    });
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
  }

  void _buildWidgetsDefault() {
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
