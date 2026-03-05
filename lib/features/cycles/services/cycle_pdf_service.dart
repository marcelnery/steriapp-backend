import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/cycle_model.dart';

class CyclePdfService {
  static Future<File> generateCyclePdf(CycleModel cycle) async {
    final pdf = pw.Document();

    // =========================
    // ASSETS
    // =========================
    final logoData =
        await rootBundle.load('assets/images/logo_woson.png');
    final watermarkData =
        await rootBundle.load('assets/images/autoclave_woson.png');

    final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    final watermark =
        pw.MemoryImage(watermarkData.buffer.asUint8List());

    // =========================
    // PAGE THEME (TUDO AQUI)
    // =========================
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 90, 32, 48),
      buildBackground: (context) => pw.Opacity(
        opacity: 0.06,
        child: pw.Image(
          watermark,
          fit: pw.BoxFit.cover,
        ),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,

        // =========================
        // CABEÇALHO
        // =========================
        header: (context) => _header(logo),

        // =========================
        // RODAPÉ
        // =========================
        footer: (context) => _footer(context),

        build: (context) => [
          _section(
            'Identificação do Equipamento',
            [
              _row('Modelo', _safe(cycle.model)),
              _row('Número de Série', _safe(cycle.serialNumber)),
              _row('Programa', _safe(cycle.program)),
              _row('Ciclo Nº', cycle.cycleNumber.toString()),
              _row('Data', _formatDate(cycle.startTime)),
            ],
          ),

          pw.SizedBox(height: 16),

          _section(
            'Parâmetros do Ciclo',
            [
              _row('Temperatura de Esterilização',
                  '${cycle.sterilizationTemperature} °C'),
              _row('Tempo de Esterilização',
                  '${cycle.sterilizationTime} min'),
              _row('Tempo de Vácuo', '${cycle.vacuumTime} min'),
              _row('Tempo de Secagem', '${cycle.dryTime} min'),
            ],
          ),

          pw.SizedBox(height: 16),

          _section(
            'Valores Medidos',
            [
              _row('Temperatura Máx. Sensor 1',
                  '${cycle.maxTemperature} °C'),
              _row('Temperatura Máx. Sensor 2',
                  '${cycle.maxTemperature2} °C'),
              _row('Pressão Máxima',
                  '${cycle.maxPressure} bar'),
            ],
          ),

          pw.SizedBox(height: 16),

          pw.Text(
            'Etapas do Ciclo',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),

          if (!cycle.isCompleteCycle)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: PdfColors.red100,
              child: pw.Text(
                'Atenção: ciclo incompleto ou sem dados detalhados.',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.red800,
                ),
              ),
            ),

          if (cycle.stages.isNotEmpty)
            pw.Table.fromTextArray(
              headers: const [
                'Etapa',
                'Tempo',
                'Temp. 1 (°C)',
                'Temp. 2 (°C)',
                'Pressão',
              ],
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1.5),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
                4: pw.FlexColumnWidth(1.5),
              },
              data: cycle.stages.map((s) {
                return [
                  _safe(s.stage),
                  _safe(s.time),
                  s.temperature1.toStringAsFixed(1),
                  s.temperature2.toStringAsFixed(1),
                  s.pressure.toStringAsFixed(2),
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 16),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: cycle.result == 'SUCESSO'
                  ? PdfColors.green100
                  : PdfColors.red100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Resultado do Ciclo: ${cycle.result}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: cycle.result == 'SUCESSO'
                    ? PdfColors.green800
                    : PdfColors.red800,
              ),
            ),
          ),

          pw.SizedBox(height: 24),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                cycle.publicUrl,
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.BarcodeWidget(
                barcode: Barcode.qrCode(),
                width: 90,
                height: 90,
                data: cycle.publicUrl,
              ),
            ],
          ),
        ],
      ),
    );

    // =========================
    // SALVAR E ABRIR
    // =========================
    final dir = await getApplicationDocumentsDirectory();
    final laudosDir = Directory('${dir.path}/Laudos');

    if (!await laudosDir.exists()) {
      await laudosDir.create(recursive: true);
    }

    final file =
        File('${laudosDir.path}/laudo_ciclo_${cycle.cycleNumber}.pdf');

    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);

    return file;
  }

  // =========================
  // CABEÇALHO
  // =========================
  static pw.Widget _header(pw.ImageProvider logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        children: [
          pw.Image(logo, width: 60),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAUDO DE CICLO DE ESTERILIZAÇÃO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Woson · Sistema SteriApp',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // RODAPÉ
  // =========================
  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================
  static String _safe(String value) =>
      value.replaceAll(RegExp(r'[^\x20-\x7EÀ-ÿ]'), '');

  static pw.Widget _section(
      String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.grey400,
            ),
          ),
          child: pw.Column(children: rows),
        ),
      ],
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
