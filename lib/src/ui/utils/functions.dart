import 'package:flutter/material.dart';
import 'package:get_stream_page/src/ui/infra/rx_get_type.dart';

typedef GetWidgetBuilder<T> = Widget Function(
    BuildContext context, T streamObject, RxGetSet rxSet);

typedef WidgetsErrorBuilder<T> = Widget Function(Object error);
