import 'package:firebase_auth/firebase_auth.dart'; // To get the User ID/Email
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/track_model.dart';

class PdfService {
  static Future<void> generateTrackPdf(Track track) async {
    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final boldFont = await PdfGoogleFonts.robotoBold();
      
      // 1. Get current User info
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? "Unknown User";

      DateTime start = track.startDate ?? DateTime.now();
      DateTime end = track.endDate ?? DateTime.now();

      // Start at the 1st of the starting month
      DateTime currentMonth = DateTime(start.year, start.month, 1);

      // 2. Loop until we pass the end date's month
      while (currentMonth.isBefore(end) || 
            (currentMonth.year == end.year && currentMonth.month == end.month)) {
        
        // Month-specific math for the grid
        final int daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
        final int firstDayOffset = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;

        List<int?> days = [];
        for (int i = 0; i < firstDayOffset; i++) {
          days.add(null);
        }
        for (int i = 1; i <= daysInMonth; i++) {
          days.add(i);
        }
        while (days.length % 7 != 0) {
          days.add(null);
        }

        // Capture currentMonth for this specific page build to prevent naming inconsistency
        final pageDate = currentMonth;

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION (Includes User Info) ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("TRACK PROGRESS REPORT", style: pw.TextStyle(font: boldFont, fontSize: 18)),
                      pw.Text("User: $userEmail", style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text("Goal: ${track.name}", style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.Text("Daily Question: ${track.checkText}", style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 20),

                  // --- DYNAMIC MONTH HEADER (Fixed inconsistency) ---
                  pw.Center(
                    child: pw.Text(
                      DateFormat('MMMM yyyy').format(pageDate).toUpperCase(), 
                      style: pw.TextStyle(font: boldFont, fontSize: 22, color: PdfColors.blueGrey800)
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // --- THE CALENDAR TABLE ---
                  pw.Table(
                    children: [
                      // Weekday Headers
                      pw.TableRow(
                        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => 
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 8),
                            child: pw.Center(child: pw.Text(d, style: pw.TextStyle(font: boldFont, fontSize: 11))),
                          )
                        ).toList(),
                      ),
                      // Grid Rows
                      for (int i = 0; i < days.length; i += 7)
                        pw.TableRow(
                          children: days.sublist(i, i + 7).map((day) {
                            if (day == null) return pw.SizedBox(height: 55);

                            DateTime dayDate = DateTime(pageDate.year, pageDate.month, day);
                            String key = DateFormat('yyyy-MM-dd').format(dayDate);
                            
                            // Check if within actual range
                            bool inRange = !dayDate.isBefore(DateTime(start.year, start.month, start.day)) && 
                                           !dayDate.isAfter(DateTime(end.year, end.month, end.day));
                            
                            DayStatus status = track.dailyProgress[key] ?? DayStatus.notSet;

                            return pw.Container(
                              height: 55,
                              child: pw.Center(
                                child: pw.Container(
                                  width: 35,
                                  height: 35,
                                  decoration: pw.BoxDecoration(
                                    shape: pw.BoxShape.circle,
                                    color: !inRange ? PdfColors.white : 
                                           (status == DayStatus.yes ? PdfColors.green200 : 
                                            status == DayStatus.no ? PdfColors.red200 : PdfColors.grey200),
                                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text("$day", 
                                      style: pw.TextStyle(
                                        font: font, 
                                        fontSize: 10,
                                        color: inRange ? PdfColors.black : PdfColors.grey400
                                      )
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),

                  pw.Spacer(),
                  // Footer
                  pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Total Range: ${DateFormat('y/M/d').format(start)} - ${DateFormat('y/M/d').format(end)}", 
                          style: pw.TextStyle(font: font, fontSize: 8)),
                      pw.Text("Generated on: ${DateFormat('y/M/d').format(DateTime.now())}", 
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    ]
                  )
                ],
              );
            },
          ),
        );

        // Move to the next month
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      }

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${track.name}_Progress_Report.pdf',
      );

    } catch (e) {
      print("PDF Error: $e");
    }
  }
}