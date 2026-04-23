import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:h2s/models/match_result_model.dart';

class PdfExportService {
  PdfExportService._();

  static Future<void> exportMatchReport(MatchResultModel result) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('MMM dd, yyyy – HH:mm').format(result.createdAt);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.interRegular(),
          bold: await PdfGoogleFonts.interBold(),
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '⚡ SPORTSHIELD AI',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.Text(
                'Digital Asset Protection Report',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey400, width: 1),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: $dateStr',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 16),
          pw.Text(
            'Match Analysis Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 24),

          // Summary card
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DETECTION SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _labelValue('Query Video', result.queryVideoTitle),
                    ),
                    pw.Expanded(
                      child: _labelValue('Matched Video', result.matchedVideoTitle),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _labelValue(
                        'Similarity Score',
                        '${result.similarityPercent}%',
                        isBold: true,
                      ),
                    ),
                    pw.Expanded(
                      child: _labelValue(
                        'Risk Level',
                        result.riskLevel,
                        isBold: true,
                        color: _riskColor(result.riskLevel),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                _labelValue('Analysis Date', dateStr),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          if (result.riskLevel == 'High')
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColors.red400),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    '⚠  WARNING: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red600,
                    ),
                  ),
                  pw.Text(
                    'Possible unauthorized sports media detected.',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                ],
              ),
            ),

          pw.SizedBox(height: 24),

          // Matched scenes table
          if (result.matchedScenes.isNotEmpty) ...[
            pw.Text(
              'MATCHED SCENES',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    _tableHeader('At (Query)'),
                    _tableHeader('Query Caption'),
                    _tableHeader('At (Match)'),
                    _tableHeader('Matched Caption'),
                    _tableHeader('Score'),
                  ],
                ),
                ...result.matchedScenes.map(
                  (scene) => pw.TableRow(
                    children: [
                      _tableCell(scene.queryTimeLabel),
                      _tableCell(scene.queryCaption),
                      _tableCell(scene.targetTimeLabel),
                      _tableCell(scene.targetCaption),
                      _tableCell('${(scene.similarity * 100).round()}%'),
                    ],
                  ),
                ),
              ],
            ),
          ],

          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report was automatically generated by SportShield AI. '
            'Results are based on AI-powered caption similarity analysis. '
            'Manual review is recommended for high-risk cases.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SportShield_Report_${result.id}.pdf',
    );
  }

  static pw.Widget _labelValue(String label, String value,
      {bool isBold = false, PdfColor? color}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? PdfColors.blueGrey900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      );

  static pw.Widget _tableCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey800),
        ),
      );

  static PdfColor _riskColor(String risk) {
    switch (risk) {
      case 'High':
        return PdfColors.red700;
      case 'Medium':
        return PdfColors.orange700;
      default:
        return PdfColors.green700;
    }
  }
}
