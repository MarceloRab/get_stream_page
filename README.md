# get_stream_page

A reactive page in GetX from a stream without the need to create a controller.

## Introduction

Would you like to have a reactive page with just your stream? Built with GetX, this widget offers 
this facility. You can add reactive resettables to rebuild your body as well. Like a change in auth. 
Errors, connectivity and standby widgets are configured in default mode. Change them if you wish. 
Check the example.

```dart
class TestGetStreamPage extends StatefulWidget {
  @override
  _TestGetStreamPageState createState() => _TestGetStreamPageState();
}

class _TestGetStreamPageState extends State<TestGetStreamPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      ///------------------------------------------
      /// Test to check the reactivity of the screen.
      ///------------------------------------------
      Get.find<Test2Controller>().changeAuth = true;
    });

    /*Future.delayed(const Duration(seconds: 15), () {
      Get
          .find<Teste2Controller>()
          .rxList
          .addAll(dataListPerson);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return GetStreamPage<List<Person>>(
      title: Text(
        'Stream Page',
        style: TextStyle(fontSize: 18),
      ),
      stream: streamListPerson,
      listRx: [
        ///------------------------------------------------------------------------
        /// Add the parameters you want to have reactivity in the body of your page.
        ///------------------------------------------------------------------------
        RxItem.input(Get.find<Test2Controller>().rxAuth, 'auth'),
        RxItem.input(Get.find<Test2Controller>().rxList, 'list_user'),
        RxItem.input(Get.find<Test3Controller>().rx_2, 'inter')
      ],
      widgetBuilder: (context, objesctStream, rxSet) {
        ///------------------------------------------
        /// Collect the reactive variable with .value
        ///------------------------------------------
        print(' TEST -- ${rxSet.getRx('auth').value.toString()} ');

        //print('RxList -- ${rxSet.getRx('list_user').value.length.toString()}');

        if (!rxSet.getRx('auth').value) {
          return Center(
            child: Text(
              'Please login.',
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        ///------------------------------------------
        /// Build your body from the stream data.
        ///------------------------------------------
        final list = objesctStream;
        if (list.isEmpty) {
          return Center(
              child: Text(
            'NOTHING FOUND',
            style: TextStyle(fontSize: 14),
          ));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, index) {
                  return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Name: ${list[index].name}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Age: ${list[index].age.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Stream<List<Person>> streamListPerson = (() async* {
  await Future<void>.delayed(Duration(seconds: 3));
  //yield null;
  yield dataListPerson;
  await Future<void>.delayed(Duration(seconds: 4));
  yield dataListPerson2;
  await Future<void>.delayed(Duration(seconds: 5));
  //throw Exception('Erro voluntario');
  yield dataListPerson3;
})();

class Test2Controller extends GetxController {
  final rxAuth = false.obs;

  set changeAuth(bool value) => rxAuth.value = value;

  get isAuth => rxAuth.value;

  final rxList = <Person>[].obs;
}

class Test3Controller extends GetxController {
  final rx_2 = ''.obs;

  set rx_2(value) => rx_2.value = value;
}

class Person {
  final String name;

  final int age;

  Person({this.name, this.age});

  @override
  String toString() {
    return 'Person{name: $name, age: $age}';
  }
}
```
