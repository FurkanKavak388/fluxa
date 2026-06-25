import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/invoice.dart';

class AnotherInvoicePage extends StatefulWidget {
  const AnotherInvoicePage({Key? key}) : super(key: key);

  @override
  State<AnotherInvoicePage> createState() => _AnotherInvoicePageState();
}

class _AnotherInvoicePageState extends State<AnotherInvoicePage> {
  final TextEditingController _phoneController = TextEditingController(text: '90');
  String? searchedPhone;
  List<Invoice> searchedInvoices = [];
  bool isSearching = false;
  String? searchError;

  final Color primaryColor = const Color(0xFFE53935);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchByPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 12 || !RegExp(r'^90\d{10}$').hasMatch(phone)) {
      setState(() {
        searchError = 'Lütfen geçerli bir telefon numarası girin (90 ile başlayan, 12 hane).';
        searchedInvoices = [];
        searchedPhone = null;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchError = null;
      searchedInvoices = [];
      searchedPhone = null;
    });

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() {
          searchError = 'Telefon numarasına ait kullanıcı bulunamadı.';
          searchedInvoices = [];
          searchedPhone = null;
        });
        return;
      }

      final userId = userQuery.docs.first.id;

      final invoicesQuery = await FirebaseFirestore.instance
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .where('isPaid', isEqualTo: false)
          .get();

      final invoices = invoicesQuery.docs.map((doc) => Invoice.fromDocument(doc)).toList();

      setState(() {
        searchedInvoices = invoices;
        searchedPhone = phone;
      });
    } catch (e) {
      setState(() {
        searchError = 'Arama sırasında hata oluştu: $e';
        searchedInvoices = [];
        searchedPhone = null;
      });
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> _payInvoice(Invoice invoice) async {
    try {
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoice.id)
          .update({'isPaid': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fatura ödendi.')),
      );
      setState(() {
        searchedInvoices.removeWhere((inv) => inv.id == invoice.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          invoice.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tutar: ₺${invoice.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text('Kesim Tarihi: ${invoice.cutOffDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text('Son Ödeme Tarihi: ${invoice.dueDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _payInvoice(invoice),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text(
            'Öde',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final errorTextColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Başkasının Faturasını Öde',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: InputDecoration(
                      hintText: '90 ile başlayan telefon',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    style: TextStyle(color: textColor),
                    cursorColor: primaryColor,
                    onChanged: (value) {
                      if (!value.startsWith('90')) {
                        _phoneController.text = '90';
                        _phoneController.selection = const TextSelection.collapsed(offset: 2);
                      }
                    },
                    onSubmitted: (_) => _searchByPhone(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white, size: 22),
                    onPressed: isSearching ? null : _searchByPhone,
                    tooltip: 'Ara',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  searchError!,
                  style: TextStyle(color: errorTextColor, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: searchedPhone == null
                  ? Center(
                      child: Text(
                        'Bir telefon numarası girin ve arama yapın.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : searchedInvoices.isEmpty
                      ? Center(
                          child: Text(
                            'Ödenmemiş fatura bulunamadı.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchedInvoices.length,
                          itemBuilder: (context, index) =>
                              _buildInvoiceCard(searchedInvoices[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
