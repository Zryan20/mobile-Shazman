import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/audio_service.dart';

/// Clickable word widget that shows Kurdish translation when tapped
class ClickableWord extends StatefulWidget {
  final String englishWord;
  final String kurdishTranslation;
  final String? pronunciation; // IPA or phonetic
  final String? audioPath; // Path to pronunciation audio
  final TextStyle? textStyle;
  final bool showUnderline;
  
  const ClickableWord({
    super.key,
    required this.englishWord,
    required this.kurdishTranslation,
    this.pronunciation,
    this.audioPath,
    this.textStyle,
    this.showUnderline = true,
  });

  @override
  State<ClickableWord> createState() => _ClickableWordState();
}

class _ClickableWordState extends State<ClickableWord> {
  bool _isPressed = false;

  void _showTranslation(BuildContext context) {
    // Play pronunciation audio if available
    if (widget.audioPath != null) {
      AudioService().playPronunciation(widget.audioPath!);
    }
    
    // Show translation popup
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => _TranslationDialog(
        englishWord: widget.englishWord,
        kurdishTranslation: widget.kurdishTranslation,
        pronunciation: widget.pronunciation,
        audioPath: widget.audioPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _showTranslation(context),
      child: Container(
        decoration: BoxDecoration(
          color: _isPressed 
              ? AppColors.primary600.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Text(
          widget.englishWord,
          style: (widget.textStyle ?? const TextStyle(fontSize: 16)).copyWith(
            decoration: widget.showUnderline 
                ? TextDecoration.underline 
                : null,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: AppColors.primary600,
            color: AppColors.primary600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Translation popup dialog
class _TranslationDialog extends StatelessWidget {
  final String englishWord;
  final String kurdishTranslation;
  final String? pronunciation;
  final String? audioPath;
  
  const _TranslationDialog({
    required this.englishWord,
    required this.kurdishTranslation,
    this.pronunciation,
    this.audioPath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English Word
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    englishWord,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                
                // Play audio button
                if (audioPath != null)
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary600,
                      size: 32,
                    ),
                    onPressed: () {
                      AudioService().playPronunciation(audioPath!);
                    },
                  ),
              ],
            ),
            
            // Pronunciation
            if (pronunciation != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '/$pronunciation/',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            
            const SizedBox(height: 20),
            
            // Kurdish Translation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary600.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'واتا بە کوردی:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kurdishTranslation,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'باشە',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rich text with clickable words
/// Usage: ClickableText('I love apples', translations: {'love': 'خۆشەویستن', 'apples': 'سێو'})
class ClickableText extends StatelessWidget {
  final String text;
  final Map<String, WordTranslation> translations;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  
  const ClickableText({
    super.key,
    required this.text,
    required this.translations,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final List<InlineSpan> spans = [];
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      
      if (translations.containsKey(cleanWord)) {
        // Clickable word
        final translation = translations[cleanWord]!;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ClickableWord(
              englishWord: word,
              kurdishTranslation: translation.kurdish,
              pronunciation: translation.pronunciation,
              audioPath: translation.audioPath,
              textStyle: textStyle,
            ),
          ),
        );
      } else {
        // Regular text
        spans.add(
          TextSpan(
            text: word,
            style: textStyle,
          ),
        );
      }
      
      // Add space between words (except last word)
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }
    
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: textStyle ?? const TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
    );
  }
}

/// Word translation data model
class WordTranslation {
  final String kurdish;
  final String? pronunciation;
  final String? audioPath;
  final String? example; // Example sentence
  
  const WordTranslation({
    required this.kurdish,
    this.pronunciation,
    this.audioPath,
    this.example,
  });
}