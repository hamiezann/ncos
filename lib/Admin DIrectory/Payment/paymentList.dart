import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ncos/Admin%20DIrectory/Payment/paymentModel.dart';
import '../../Network Configuration/networkConfig.dart';


class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class PaymentFilter {
  String? status;
  PaymentFilter({this.status});
}

enum PaymentSortCriteria {
  dateAscending,
  dateDescending,
  amountAscending,
  amountDescending,
}

List<Payment> sortPayments(List<Payment> payments, PaymentSortCriteria criteria) {
  switch (criteria) {
    case PaymentSortCriteria.dateAscending:
      payments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case PaymentSortCriteria.dateDescending:
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case PaymentSortCriteria.amountAscending:
      payments.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
      break;
    case PaymentSortCriteria.amountDescending:
      payments.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
      break;
  }
  return payments;
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<List<Payment>> futurePayments;
  PaymentFilter _filter = PaymentFilter();
  PaymentSortCriteria _sortCriteria = PaymentSortCriteria.dateDescending;

  @override
  void initState() {
    super.initState();
    futurePayments = fetchPayments();
  }

  Future<List<Payment>> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}/payments'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<Payment> payments = jsonResponse.map((payment) => Payment.fromJson(payment)).toList();
        // return jsonResponse.map((payment) => Payment.fromJson(payment)).toList();

        if(_filter.status != null && _filter.status!.isNotEmpty){
          payments = payments.where((payment) => payment.orders.any((order) =>order.orderStatus == _filter.status)).toList();
        }
        return sortPayments(payments, _sortCriteria);
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (error) {
      throw Exception('Failed to load payments: $error');
    }
  }

  Future<void> _refreshPayments() async {
    setState(() {
      futurePayments = fetchPayments();
    });
  }

  void _openFilterDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return FilterDialog(
              currentFilter: _filter,
              onFilterChanged: (filter) {
                setState(() {
                  _filter = filter;
                  futurePayments = fetchPayments();
                });
              }
          );
        }
    );
  }

  void _openSortDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SortDialog(
              currentSortCriteria: _sortCriteria,
              onSortChanged: (criteria) {
                setState(() {
                  _sortCriteria = criteria;
                  futurePayments = fetchPayments();
                });
              }
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip:'Filter By',
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _openSortDialog,
            tooltip: 'Sort By',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPayments,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.red.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FutureBuilder<List<Payment>>(
            future: futurePayments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No payments found'));
              } else {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Payment payment = snapshot.data![index];
                    return PaymentCard(payment: payment);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;

  PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text('${payment.paymentMethod} - RM${payment.totalPrice.toStringAsFixed(2)}'),
        subtitle: Text(payment.createdAt.toLocal().toString()),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: payment.orders.map((order) {
            return Column(
              children: [
                Text('Order ID: ''#${order.id}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text('Order Status:'),
                Text(
                  '${order.orderStatus}',
                  style: TextStyle(
                    color: order.orderStatus == 'Completed'
                        ? Colors.green
                        : order.orderStatus == 'Pending'
                        ? Colors.blueAccent
                        : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.white60,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final PaymentFilter currentFilter;
  final Function(PaymentFilter) onFilterChanged;

  FilterDialog({required this.currentFilter, required this.onFilterChanged});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late PaymentFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = PaymentFilter(
      status: widget.currentFilter.status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Payments'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _filter.status,
            decoration: InputDecoration(labelText: 'Order Status'),
            items: [
              DropdownMenuItem(value: '', child: Text('All')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              setState(() {
                _filter.status = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Apply'),
          onPressed: () {
            widget.onFilterChanged(_filter);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SortDialog extends StatefulWidget {
  final PaymentSortCriteria currentSortCriteria;
  final Function(PaymentSortCriteria) onSortChanged;

  SortDialog({required this.currentSortCriteria, required this.onSortChanged});

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {

  late PaymentSortCriteria _sortCriteria;
  @override
  void initState() {
    super.initState();
    _sortCriteria = widget.currentSortCriteria;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sort Payments'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile<PaymentSortCriteria>(
              title: const Text('Date Ascending'),
              value: PaymentSortCriteria.dateAscending,
              groupValue: _sortCriteria,
              onChanged: (value) {
                setState(() {
                  _sortCriteria = value!;
                });
              }),
          RadioListTile<PaymentSortCriteria>(
              title: const Text('Date Descending'),
              value: PaymentSortCriteria.dateDescending,
              groupValue: _sortCriteria,
              onChanged: (value) {
                setState(() {
                  _sortCriteria = value!;
                });
              }),
          RadioListTile<PaymentSortCriteria>(
              title: const Text('Amount Ascending'),
              value: PaymentSortCriteria.amountAscending,
              groupValue: _sortCriteria,
              onChanged: (value) {
                setState(() {
                  _sortCriteria = value!;
                });
              }),
          RadioListTile<PaymentSortCriteria>(
              title: const Text('Amount Descending'),
              value: PaymentSortCriteria.amountDescending,
              groupValue: _sortCriteria,
              onChanged: (value) {
                setState(() {
                  _sortCriteria = value!;
                });
              }),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSortChanged(_sortCriteria);
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
