import 'package:get/get.dart';

class RxGetSet {
  final List<RxItem> listRx;

  RxGetSet(this.listRx);

  RxItem getRx(String tag) =>
      listRx.where((element) => element.tag == tag).first;

/*@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RxGetSet &&
          runtimeType == other.runtimeType &&
          listRx == other.listRx;

  @override
  int get hashCode => listRx.hashCode;*/
}

class RxItem {
  final RxInterface rx;
  final String tag;
  final bool isRxList;

  dynamic get value => !isRxList ? rx.value : (rx as RxList);

  const RxItem._(this.rx, this.tag, this.isRxList)
      : assert(rx != null),
        assert(tag != null);

  // assert(tag != null && tag.isNotEmpty);

  const RxItem.input(RxInterface rx, String tag)
      : this._(rx, tag, rx is RxList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RxItem && runtimeType == other.runtimeType && tag == other.tag;

  @override
  int get hashCode => tag.hashCode;
}
