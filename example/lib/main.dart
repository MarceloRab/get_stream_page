import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_stream_page/get_stream_page.dart';

void main() {
  runApp(MyApp());
}

class MyBinddings extends Bindings {
  @override
  void dependencies() {
    Get.put(Test2Controller());
    Get.put(Test3Controller());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: MyBinddings(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

abstract class Routes {
  static const HOME = '/home';
  static const PAGE_1 = '/page_1';
  static const PAGE_2 = '/page_2';
  static const PAGE_3 = '/page_3';
}

class AppPages {
  static const INITIAL = Routes.HOME;
  static final routes = [
    GetPage(name: Routes.HOME, page: () => HomePage()),

    /// ## ✳️ There are two ways to add reactive variables.

    ///--------------------------------------------
    /// ✅ 1) Add the reactive parameters to a list.
    ///---------------------------------------------
    GetPage(
        name: Routes.PAGE_1,
        page: () {
          changeAuth();
          return TestGetStreamPage();
        }),

    ///-------------------------------------------------------------------
    /// ✅ 2) Boot your controller into a StatefulWidget.
    ///-------------------------------------------------------------------
    GetPage(name: Routes.PAGE_2, page: () => TestGetStreamPageStateful()),
    GetPage(
        name: Routes.PAGE_3,
        page: () {
          changeAuth();
          return TestGetStreamWidget();
        }),
  ];
}

void changeAuth() {
  Future.delayed(const Duration(seconds: 8), () {
    ///------------------------------------------
    /// Test to check the reactivity of the screen.
    ///------------------------------------------
    /// 1) 👇🏼
    Get.find<Test2Controller>().rxList.addAll(dataListPerson);
    if (!Get.find<Test2Controller>().isAuth) {
      Get.find<Test2Controller>().changeAuth = true;
    }
  });
}

// ignore: must_be_immutable
class TestGetStreamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.find<Test2Controller>().changeAuth = false;
        Get.find<Test2Controller>().rxList.clear();
        return Future.value(true);
      },
      child: GetStreamPage<List<Person>>(
        title: Text(
          'Stream Page',
          style: TextStyle(fontSize: 18),
        ),
        stream: streamListPerson,

        ///--------------------------------------------
        /// ✅ 1) Add the reactive parameters to a list.
        ///---------------------------------------------
        listRx: [
          RxItem.input(Get.find<Test2Controller>().rxAuth, 'auth'),
          RxItem.input(Get.find<Test2Controller>().rxList, 'list_user'),
          RxItem.input(Get.find<Test3Controller>().rx_2, 'inter')
        ],
        obxWidgetBuilder: (context, objesctStream, rxSet) {
          ///-----------------------------------------------
          /// ✅ 1.2) Collect the reactive variable with .value
          /// => (Rx or RxList)
          ///-----------------------------------------------
          ///  If they are within the function [obxWidgetBuilder],
          /// when they change, a rebuild of the body will occur.

          print(
              // ignore: lines_longer_than_80_chars
              ' TEST -- ${rxSet.getRx('list_user').value.length.toString()} ');

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
                                  // ignore: lines_longer_than_80_chars
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
      ),
    );
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
}

class TestGetStreamPageStateful extends StatefulWidget {
  @override
  _TestGetStreamPageStatefulState createState() =>
      _TestGetStreamPageStatefulState();
}

class _TestGetStreamPageStatefulState extends State<TestGetStreamPageStateful> {
  Test2Controller controll_1;

  @override
  void initState() {
    ///-------------------------------------------------------------------
    /// ✅ 2) Boot your controller into a StatefulWidget.
    ///-------------------------------------------------------------------
    controll_1 = Get.find<Test2Controller>();
    super.initState();

    Future.delayed(const Duration(seconds: 8), () {
      ///------------------------------------------
      /// Test to check the reactivity of the screen.
      ///------------------------------------------
      /// 2) 👇🏼
      controll_1.changeAuth = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetStreamPage<List<Person>>(
      title: Text(
        'Stream Page',
        style: TextStyle(fontSize: 18),
      ),
      stream: streamListPerson,
      obxWidgetBuilder: (context, objesctStream, _) {
        // ☑️ This function is inside an Obx. Place reactive verables into it.

        ///-------------------------------------------------------------
        /// 2.2) Or pass the reactive variable get inside this function.
        ///-------------------------------------------------------------
        ///

        if (!controll_1.isAuth) {
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

  @override
  void dispose() {
    Get.find<Test2Controller>().changeAuth = false;
    super.dispose();
  }
}

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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                focusColor: Colors.grey,
                splashColor: Colors.blue,
                onTap: () {
                  Get.toNamed(Routes.PAGE_1);
                },
                child: Text(
                  'Go to the GetStreamPage with reactive variables in a list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                focusColor: Colors.grey,
                splashColor: Colors.blue,
                onTap: () {
                  Get.toNamed(Routes.PAGE_2);
                },
                child: Text(
                  'Go to the GetStreamPage with '
                  'reactive variables by controllers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                focusColor: Colors.grey,
                splashColor: Colors.blue,
                onTap: () {
                  Get.toNamed(Routes.PAGE_3);
                },
                child: Text(
                  'Go to the GetStreamWidget',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TestGetStreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetStreamWidget'),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () {
          Get.find<Test2Controller>().changeAuth = false;
          Get.find<Test2Controller>().rxList.clear();
          return Future.value(true);
        },
        child: GetStreamWidget<List<Person>>(
          stream: streamListPerson,
          listRx: [
            RxItem.input(Get.find<Test2Controller>().rxAuth, 'auth'),
            RxItem.input(Get.find<Test2Controller>().rxList, 'list_user'),
            RxItem.input(Get.find<Test3Controller>().rx_2, 'inter')
          ],
          obxWidgetBuilder: (context, objesctStream, rxSet) {
            print(
                // ignore: lines_longer_than_80_chars
                ' TEST -- ${rxSet.getRx('list_user').value.length.toString()} ');

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
                                    // ignore: lines_longer_than_80_chars
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
        ),
      ),
    );
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
}

final dataListPerson = <Person>[
  Person(name: 'Rafaela Pinho', age: 30),
  Person(name: 'Paulo Emilio Silva', age: 45),
  Person(name: 'Pedro Gomes', age: 18),
  Person(name: 'Orlando Guerra', age: 23),
  Person(name: 'Zacarias Triste', age: 15),
];

final dataListPerson2 = <Person>[
  Person(name: 'Rafaela Pinho', age: 30),
  Person(name: 'Paulo Emilio Silva', age: 45),
  Person(name: 'Pedro Gomes', age: 18),
  Person(name: 'Orlando Guerra', age: 23),
  Person(name: 'Zacarias Triste', age: 15),
  Person(name: 'Antonio Rabelo', age: 33),
  Person(name: 'Leticia Maciel', age: 47),
  Person(name: 'Patricia Oliveira', age: 19),
  Person(name: 'Pedro Lima', age: 15),
  Person(name: 'Junior Rabelo', age: 33),
  Person(name: 'Lucia Maciel', age: 47),
  Person(name: 'Ana Oliveira', age: 19),
  Person(name: 'Thiago Silva', age: 33),
  Person(name: 'Charles Ristow', age: 47),
  Person(name: 'Raquel Montenegro', age: 19),
  Person(name: 'Rafael Peireira', age: 15),
  Person(name: 'Nome Comum', age: 33),
];

final dataListPerson3 = <Person>[
  Person(name: 'Rafaela Pinho', age: 30),
  Person(name: 'Paulo Emilio Silva', age: 45),
  Person(name: 'Pedro Gomes', age: 18),
  Person(name: 'Orlando Guerra', age: 23),
  Person(name: 'Ana Pereira', age: 23),
  Person(name: 'Zacarias Triste', age: 15),
  Person(name: 'Antonio Rabelo', age: 33),
  Person(name: 'Leticia Maciel', age: 47),
  Person(name: 'Patricia Oliveira', age: 19),
  Person(name: 'Pedro Lima', age: 15),
  Person(name: 'Fabio Melo', age: 51),
  Person(name: 'Junior Rabelo', age: 33),
  Person(name: 'Lucia Maciel', age: 47),
  Person(name: 'Ana Oliveira', age: 19),
  Person(name: 'Thiago Silva', age: 33),
  Person(name: 'Charles Ristow', age: 47),
  Person(name: 'Raquel Montenegro', age: 19),
  Person(name: 'Rafael Peireira', age: 15),
  Person(name: 'Thiago Ferreira', age: 33),
  Person(name: 'Joaquim Gomes', age: 18),
  Person(name: 'Esther Guerra', age: 23),
  Person(name: 'Pedro Braga', age: 19),
  Person(name: 'Milu Silva', age: 17),
  Person(name: 'William Ristow', age: 47),
  Person(name: 'Elias Tato', age: 22),
  Person(name: 'Dada Istomesmo', age: 44),
  Person(name: 'Nome Incomum', age: 52),
  Person(name: 'Qualquer Nome', age: 9),
  Person(name: 'First Last', age: 11),
  Person(name: 'Bom Dia', age: 23),
  Person(name: 'Bem Mequiz', age: 13),
  Person(name: 'Mal Mequer', age: 71),
  Person(name: 'Quem Sabe', age: 35),
  Person(name: 'Miriam Leitao', age: 33),
  Person(name: 'Gabriel Mentiroso', age: 19),
  Person(name: 'Caio Petro', age: 27),
  Person(name: 'Tanto Nome', age: 66),
  Person(name: 'Nao Diga', age: 33),
  Person(name: 'Fique Queto', age: 11),
  Person(name: 'Cicero Gome', age: 37),
  Person(name: 'Carlos Gome', age: 48),
  Person(name: 'Mae Querida', age: 45),
  Person(name: 'Exausto Nome', age: 81),
];

class Person {
  final String name;

  final int age;

  Person({this.name, this.age});

  @override
  String toString() {
    return 'Person{name: $name, age: $age}';
  }
}
