import 'package:flutter/material.dart';
import 'package:maulika/repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.grey.shade800,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.black)),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  TextEditingController coinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CoinRich",
          style: style.headline4!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: coinController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  fillColor: Colors.black,
                  filled: true,
                  hintText: "Enter Coin Symbol",
                  hintStyle: TextStyle(
                    color: Colors.white,
                  )),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (coinController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please Enter coin symbol"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  var map = await Repository.getcoins(
                      coinController.text.toUpperCase());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SecondScreen(
                        map: map,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  print("getCoins: $e");
                }
              },
              child: Text(
                "Search",
                style: style.headline5!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final Map<String, dynamic> map;
  const SecondScreen({Key? key, required this.map}) : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  bool _showChart = false;

  bool get showChart => _showChart;

  set showChart(bool showChart) {
    _showChart = showChart;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CoinRich",
            style: style.headline4!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showChart = !showChart;
                    },
                    child: Chip(
                      avatar: Icon(
                        showChart ? Icons.menu : Icons.pie_chart,
                        color: Colors.yellow,
                      ),
                      backgroundColor: Colors.grey.shade800,
                      label: Text(
                        showChart ? "Show List" : "Show Chart",
                        style: const TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Count: ${widget.map.length}",
                    style: style.subtitle1!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              showChart
                  ? Expanded(
                      child: Center(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          // tooltipBehavior: _tooltip,
                          series: <
                              ChartSeries<MapEntry<String, dynamic>, String>>[
                            ColumnSeries<MapEntry<String, dynamic>, String>(
                              enableTooltip: true,
                              dataSource: widget.map.entries.toList(),
                              xValueMapper: (MapEntry data, _) => data.key,
                              yValueMapper: (MapEntry data, _) =>
                                  data.value['quote']['USD']['price'] as double,
                              name: 'Orders',
                              // dataLabelSettings: const DataLabelSettings(isVisible : true)
                            ),
                          ],
                        ),
                      ),
                    )
                  : widget.map.entries.isEmpty
                      ? Center(
                          child: Text(
                            "No coin available",
                            style: style.headlineMedium!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Column(
                          children: widget.map.entries
                              .map(
                                (e) => CustomCard(
                                  data: e,
                                ),
                              )
                              .toList(),
                        )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final MapEntry<String, dynamic> data;
  const CustomCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          builder: (_) => Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      data.value['name'],
                      style: style.headline4!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Tags",
                    style: style.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  List.from(data.value['tags']).isEmpty
                      ? const Center(
                          child: Text("No tags available"),
                        )
                      : Wrap(
                          children: List.from(data.value['tags'])
                              .map(
                                (e) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade200,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  margin: const EdgeInsets.all(4),
                                  child: Text(
                                    "$e",
                                    style: style.subtitle1,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Price Last Updated",
                    style: style.headline5!.copyWith(
                        color: Colors.black,
                        // fontSize: 25,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${data.value['last_updated']}",
                    style: style.titleLarge!.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      "CLOSE",
                      style: style.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: Text(
                    data.value['name'],
                    style: style.headlineMedium!.copyWith(
                      color: Colors.yellow,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                    ),
                    Text(
                      "3.95%",
                      style: style.subtitle1!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: Text(
                    data.value['symbol'],
                    style: style.subtitle1!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price: \$${double.parse(
                    (data.value['quote']['USD']['price'] as double)
                        .toStringAsFixed(2),
                  )}",
                  style: style.subtitle1!.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${data.value['cmc_rank']}",
                  style: style.subtitle1!.copyWith(
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  iconSize: 40,
                  color: Colors.yellow,
                  icon: const Icon(Icons.arrow_circle_right),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
