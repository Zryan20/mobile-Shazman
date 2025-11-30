import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.elevation = 2.0,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.padding,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = isDisabled || onPressed == null || isLoading;
    
    final Color effectiveBackgroundColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? AppColors.primary600);
    
    final Color effectiveTextColor = isOutlined
        ? (textColor ?? AppColors.primary600)
        : (textColor ?? Colors.white);
    
    final Color effectiveIconColor = iconColor ?? effectiveTextColor;
    
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: Material(
        color: effectivelyDisabled
            ? (isOutlined ? Colors.transparent : AppColors.neutral300)
            : effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: isOutlined ? 0 : (effectivelyDisabled ? 0 : elevation),
        child: InkWell(
          onTap: effectivelyDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: isOutlined
                ? BoxDecoration(
                    border: Border.all(
                      color: effectivelyDisabled
                          ? AppColors.neutral300
                          : (backgroundColor ?? AppColors.primary600),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  )
                : null,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTextColor,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: 8),
                      ],
                      if (icon != null && prefixIcon == null) ...[
                        Icon(
                          icon,
                          color: effectivelyDisabled
                              ? AppColors.neutral500
                              : effectiveIconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: effectivelyDisabled
                                ? AppColors.neutral500
                                : effectiveTextColor,
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        const SizedBox(width: 8),
                        suffixIcon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Primary button variant
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      backgroundColor: AppColors.primary600,
      textColor: Colors.white,
    );
  }
}

// Secondary button variant
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  
  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      backgroundColor: AppColors.primary700,
      textColor: Colors.white,
    );
  }
}

// Outlined button variant
class OutlinedCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? borderColor;
  
  const OutlinedCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      isOutlined: true,
      backgroundColor: borderColor ?? AppColors.primary600,
      textColor: borderColor ?? AppColors.primary600,
    );
  }
}

// Text button variant (minimal styling)
class TextCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final double fontSize;
  
  const TextCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? AppColors.primary600,
                size: 18,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? AppColors.primary600,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Success button variant
class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  
  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }
}

// Warning/Danger button variant
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  
  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}

// Small button variant
class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  
  const SmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      height: 36,
      fontSize: 14,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

// Icon button variant
class IconCustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  
  const IconCustomButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? AppColors.primary600,
      borderRadius: BorderRadius.circular(size / 4),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 4),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}