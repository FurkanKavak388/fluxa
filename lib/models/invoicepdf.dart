import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/invoice.dart';

Future<void> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();

 
  final user = FirebaseAuth.instance.currentUser;
  String userName = "";
  String userSurname = "";

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      userName = doc['name'] ?? '';
      userSurname = doc['surname'] ?? '';
    }
  }

  
  final fontRegular = await PdfGoogleFonts.openSansRegular();
  final fontBold = await PdfGoogleFonts.openSansBold();

  final dateFormatter = DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR');
  final monthYearFormatter = DateFormat('MMMM yyyy', 'tr_TR');

  final cutOffDateFormatted = dateFormatter.format(invoice.cutOffDate.toLocal());
  final dueDateFormatted = dateFormatter.format(invoice.dueDate.toLocal());
  final generatedDateFormatted = dateFormatter.format(DateTime.now().toLocal());
  final invoiceMonthYear = monthYearFormatter.format(invoice.cutOffDate.toLocal());

 
  final qr = Barcode.qrCode();
  final qrSvg = qr.toSvg(invoice.id ?? '', width: 100, height: 100);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Stack(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "$userName $userSurname",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 22,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Fatura Dönemi: $invoiceMonthYear",
                    style: pw.TextStyle(font: fontRegular, fontSize: 16),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    "Fatura #${invoice.id}",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 28,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text("Başlık: ${invoice.title}",
                      style: pw.TextStyle(font: fontRegular, fontSize: 16)),
                  pw.Text(
                      "Tutar: ${invoice.amount.toStringAsFixed(2)} TL",
                      style: pw.TextStyle(font: fontRegular, fontSize: 16)),
                  pw.Text("Kesim Tarihi: $cutOffDateFormatted",
                      style: pw.TextStyle(font: fontRegular, fontSize: 16)),
                  pw.Text("Son Ödeme Tarihi: $dueDateFormatted",
                      style: pw.TextStyle(font: fontRegular, fontSize: 16)),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: invoice.isPaid
                          ? PdfColors.green
                          : PdfColors.red,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      invoice.isPaid ? "ÖDENMİŞ" : "ÖDENMEMİŞ",
                      style: pw.TextStyle(
                        font: fontBold,
                        color: PdfColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  pw.Spacer(),
                  pw.Divider(),
                  pw.Text(
                    "Bu fatura $generatedDateFormatted tarihinde oluşturulmuştur.",
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            
            pw.Positioned(
              right: 24,
              bottom: 64,
              child: pw.Container(
                width: 100,
                height: 100,
                child: pw.SvgImage(svg: qrSvg),
              ),
            ),
          ],
        );
      },
    ),
  );

  final output = await getApplicationDocumentsDirectory();
  final filePath = "${output.path}/fatura_${invoice.id}.pdf";
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: "fatura_${invoice.id}.pdf",
  );
}
