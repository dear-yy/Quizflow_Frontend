import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String url;

  const ArticleCard({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("❌ URL을 열 수 없습니다: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📌 추천 아티클",
              style: GoogleFonts.bebasNeue(
                fontSize: 16,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                text: title,
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe5bdb5),
                ),
                recognizer: TapGestureRecognizer()..onTap = _launchURL,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                text: url.length > 30 ? "${url.substring(0, 30)}..." : url,
                style: GoogleFonts.bebasNeue(
                  fontSize: 14,
                  color: Color(0xFFe5bdb5),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()..onTap = _launchURL,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
