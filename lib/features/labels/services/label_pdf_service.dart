import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/label_model.dart';

class LabelPdfService {

  static Future<void> generatePdf({
    required List<LabelModel> labels,
    required String clinicName,
  }) async {

    final pdf = pw.Document();

    // 🔥 Carrega logo real
    final ByteData imageData =
        await rootBundle.load("assets/images/logo_woson.png");

    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final logo = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {

          return [pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: labels.map((label) {

              return pw.Container(
                width: 95 * PdfPageFormat.mm,
                height: 60 * PdfPageFormat.mm,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(
                    color: PdfColor.fromHex("#5E2B97"),
                    width: 2,
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // HEADER ROXO
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex("#5E2B97"),
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(10),
                          topRight: pw.Radius.circular(10),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                        children: [

                          pw.Image(
                            logo,
                            height: 28, // 🔥 logo maior
                          ),

                          pw.Text(
                            clinicName.toUpperCase(),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 6),

                    pw.Row(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [

                              _line("Esterilização",
                                  _formatDate(label.sterilizationDate)),

                              _line("Validade",
                                  _formatDate(label.validityDate)),

                              _line("Responsável",
                                  label.responsible),

                              _line("Lote",
                                  label.lotNumber),

                              _line("Autoclave",
                                  label.model),

                              _line("Nº Série",
                                  label.serialNumber),
                            ],
                          ),
                        ),

                        pw.SizedBox(width: 6),

                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: label.publicUrl,
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),

                    pw.Spacer(),

                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        "ID: ${label.globalNumber}",
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex("#5E2B97"),
                        ),
                      ),
                    ),
                  ],
                ),
              );

            }).toList(),
          )
          ];
      
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: "$label: ",
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}