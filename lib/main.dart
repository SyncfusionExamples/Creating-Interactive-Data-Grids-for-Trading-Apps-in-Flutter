import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  runApp(MyApp());
}

/// The application that contains datagrid on it.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock DataGrid Demo',
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

/// The home page of the application which hosts the datagrid.
class MyHomePage extends StatefulWidget {
  /// Creates the home page.
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  late RealTimeUpdateDataGridSource _realTimeUpdateDataGridSource;
  late List<GridColumn> columns;

  @override
  void initState() {
    super.initState();
    columns = getColumns();
    _realTimeUpdateDataGridSource =
        RealTimeUpdateDataGridSource(columns: columns);
    _timer = Timer.periodic(const Duration(milliseconds: 800), (Timer args) {
      _realTimeUpdateDataGridSource.timerTick(args);
    });
  }

  Widget _buildDataGrid() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(child: Text("Trader Grid")),
      ),
      body: SfDataGrid(
        source: _realTimeUpdateDataGridSource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: columns,
      ),
    );
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridColumn(
        columnName: 'symbol',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Symbol'),
        ),
      ),
      GridColumn(
        columnName: 'companyName',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Company Name'),
        ),
      ),
      GridColumn(
        columnName: 'price',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Price'),
        ),
      ),
      GridColumn(
        columnName: 'change',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Change'),
        ),
      ),
      GridColumn(
        columnName: 'changePercentage',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Change %'),
        ),
      ),
      GridColumn(
        columnName: 'volume',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Volume'),
        ),
      ),
      GridColumn(
        columnName: 'marketCap',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Market Cap'),
        ),
      ),
      GridColumn(
        columnName: 'bid',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Bid'),
        ),
      ),
      GridColumn(
        columnName: 'ask',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Ask'),
        ),
      ),
      GridColumn(
        columnName: 'time',
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Time'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _buildDataGrid();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the real time stock which will be rendered in datagrid.
class Stock {
  Stock(
      this.symbol,
      this.companyName,
      this.price,
      this.change,
      this.changePercentage,
      this.volume,
      this.marketCap,
      this.bid,
      this.ask,
      this.time);

  String symbol;
  String companyName;
  double price;
  double change;
  double changePercentage;
  int volume;
  double marketCap;
  double bid;
  double ask;
  String time;
}

class RealTimeUpdateDataGridSource extends DataGridSource {
  RealTimeUpdateDataGridSource({required this.columns}) {
    _stocks = _fetchStocks();
    _buildDataGridRows();
  }

  List<GridColumn> columns;
  final Random _random = Random();
  List<Stock> _stocks = <Stock>[];
  List<DataGridRow> _dataGridRows = <DataGridRow>[];

  void timerTick(Timer args) {
    _updateStockData();
  }

  void _updateStockData() {
    // Update the DataGrid rows with formatted values.
    void updateDataRow(int recNo, int colIndex) {
      String columnName = columns[colIndex].columnName;
      final columnMap = {
        'symbol': _stocks[recNo].symbol,
        'companyName': _stocks[recNo].companyName,
        'price': _stocks[recNo].price,
        'change': _stocks[recNo].change,
        'changePercentage': _stocks[recNo].changePercentage,
        'volume': _stocks[recNo].volume,
        'marketCap': _stocks[recNo].marketCap,
        'bid': _stocks[recNo].bid,
        'ask': _stocks[recNo].ask,
        'time': _stocks[recNo].time,
      };
      _dataGridRows[recNo].getCells()[colIndex] = DataGridCell<dynamic>(
          columnName: columnName, value: columnMap[columnName]);
    }

    for (int recNo = 0; recNo < _stocks.length; recNo++) {
      double oldPrice = _stocks[recNo].price;
      // Update dynamic stock data.
      _stocks[recNo].price += (_random.nextDouble() * 4 - 2);
      _stocks[recNo].change = _stocks[recNo].price - oldPrice;
      _stocks[recNo].changePercentage =
          (_stocks[recNo].change / _stocks[recNo].price) * 100;
      _stocks[recNo].marketCap = _calculateMarketCap(_stocks[recNo].price);
      _stocks[recNo].bid = _stocks[recNo].price - _random.nextDouble();
      _stocks[recNo].ask = _stocks[recNo].price + _random.nextDouble();

      // Format dynamic numeric values to two decimal places.
      _stocks[recNo].price =
          double.parse(_stocks[recNo].price.toStringAsFixed(2));
      updateDataRow(recNo, 2);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 2));
      _stocks[recNo].change =
          double.parse(_stocks[recNo].change.toStringAsFixed(2));
      updateDataRow(recNo, 3);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 3));
      _stocks[recNo].changePercentage =
          double.parse(_stocks[recNo].changePercentage.toStringAsFixed(2));
      updateDataRow(recNo, 4);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 4));
      _stocks[recNo].volume += _random.nextInt(1000);
      updateDataRow(recNo, 5);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 5));
      _stocks[recNo].marketCap =
          double.parse(_stocks[recNo].marketCap.toStringAsFixed(2));
      updateDataRow(recNo, 6);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 6));
      _stocks[recNo].bid = double.parse(_stocks[recNo].bid.toStringAsFixed(2));
      updateDataRow(recNo, 7);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 7));
      _stocks[recNo].ask = double.parse(_stocks[recNo].ask.toStringAsFixed(2));
      updateDataRow(recNo, 8);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 8));
      _stocks[recNo].time = _generateCurrentTime();
      updateDataRow(recNo, 9);
      updateDataSource(rowColumnIndex: RowColumnIndex(recNo, 9));
    }
  }

  /// Update DataGrid source.
  void updateDataSource({required RowColumnIndex rowColumnIndex}) {
    notifyDataSourceListeners(rowColumnIndex: rowColumnIndex);
  }

  double _calculateMarketCap(double price) {
    final List<int> ranges = [1e6.toInt(), 1e9.toInt(), 1e12.toInt()];
    final int range = ranges[_random.nextInt(ranges.length)];
    final double outstandingShares = _random.nextDouble() * range;
    final marketCap = price * outstandingShares;

    return marketCap;
  }

  String _generateCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}';
  }

  void _buildDataGridRows() {
    _dataGridRows = _stocks.map<DataGridRow>((Stock stock) {
      return DataGridRow(cells: <DataGridCell>[
        DataGridCell<String>(columnName: 'symbol', value: stock.symbol),
        DataGridCell<String>(
            columnName: 'companyName', value: stock.companyName),
        DataGridCell<double>(columnName: 'price', value: stock.price),
        DataGridCell<double>(columnName: 'change', value: stock.change),
        DataGridCell<double>(
            columnName: 'changePercentage', value: stock.changePercentage),
        DataGridCell<int>(columnName: 'volume', value: stock.volume),
        DataGridCell<double>(columnName: 'marketCap', value: stock.marketCap),
        DataGridCell<double>(columnName: 'bid', value: stock.bid),
        DataGridCell<double>(columnName: 'ask', value: stock.ask),
        DataGridCell<String>(columnName: 'time', value: stock.time),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      _buildTextCell(row.getCells()[0].value),
      _buildTextCell(row.getCells()[1].value),
      _buildTextCell(row.getCells()[2].value),
      _buildChangeCell(row.getCells()[3].value),
      _buildChangePercentageCell(row.getCells()[4].value),
      _buildTextCell(row.getCells()[5].value),
      _buildMarketCapCell(row.getCells()[6].value),
      _buildTextCell(row.getCells()[7].value),
      _buildTextCell(row.getCells()[8].value),
      _buildTextCell(row.getCells()[9].value)
    ]);
  }

  /// Helper method to handle both String and double types.
  Widget _buildTextCell(dynamic value) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        value is double ? value.toStringAsFixed(2) : value.toString(),
      ),
    );
  }

  Widget _buildMarketCapCell(double marketCap) {
    String formattedMarketCap;

    // Format the market cap into appropriate units.
    if (marketCap >= 1e12) {
      formattedMarketCap =
          '\$${(marketCap / 1e12).toStringAsFixed(1)} Trillion';
    } else if (marketCap >= 1e9) {
      formattedMarketCap = '\$${(marketCap / 1e9).toStringAsFixed(1)} Billion';
    } else if (marketCap >= 1e6) {
      formattedMarketCap = '\$${(marketCap / 1e6).toStringAsFixed(1)} Million';
    } else {
      formattedMarketCap = '\$${marketCap.toStringAsFixed(1)}';
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(formattedMarketCap),
    );
  }

  Widget _buildChangeCell(double value) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: TextStyle(
          color: value < 0
              ? Colors.red
              : value >= 0 && value <= 1
                  ? null
                  : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChangePercentageCell(double value) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        '${value.toStringAsFixed(2)}%',
        style: TextStyle(
          color: value < 0
              ? Colors.red
              : value >= 0 && value <= 1
                  ? Colors.black
                  : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Stock> _fetchStocks() {
    return [
      Stock('AAPL', 'Apple', 157.25, -0.32, -0.20, 1200350, 2.5e12, 157.20,
          157.30, '12:35:45'),
      Stock('MSFT', 'Microsoft', 332.10, 1.50, 0.45, 890250, 2.7e11, 332.00,
          332.15, '12:35:45'),
      Stock('TSLA', 'Tesla', 212.75, -2.75, -1.28, 3500000, 672e9, 212.70,
          212.80, '12:35:45'),
      Stock('AMZN', 'Amazon', 129.85, 0.85, 0.66, 2150760, 1.3e11, 129.80,
          129.90, '12:35:45'),
      Stock('GOOGL', 'Alphabet', 141.50, 0.75, 0.53, 980500, 1.8e11, 141.45,
          141.55, '12:35:45'),
      Stock('NVDA', 'NVIDIA', 465.25, 3.50, 0.76, 1450300, 1.2e11, 465.20,
          465.30, '12:35:45'),
      Stock('META', 'Meta', 380.45, 5.00, 1.33, 2500000, 900e9, 380.30, 380.50,
          '12:35:45'),
      Stock('TSM', 'TSMC', 120.85, 1.10, 0.92, 4000000, 600e9, 120.80, 120.90,
          '12:35:45'),
      Stock('INTC', 'Intel', 50.15, -0.10, -0.20, 1000000, 200e9, 50.10, 50.20,
          '12:35:45'),
      Stock('IBM', 'IBM', 135.90, 0.50, 0.37, 500000, 150e9, 135.80, 135.95,
          '12:35:45'),
      Stock('DIS', 'Disney', 140.75, -1.00, -0.71, 750000, 250e9, 140.70,
          140.80, '12:35:45'),
    ];
  }
}
