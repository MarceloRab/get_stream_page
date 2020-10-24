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
}

class AppPages {
  static const INITIAL = Routes.HOME;
  static final routes = [
    GetPage(name: Routes.HOME, page: () => TestGetStreamPage()),
  ];
}

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
