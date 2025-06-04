import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';

class EchoGenBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showBadge;

  const EchoGenBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  State<EchoGenBottomNavBar> createState() => _EchoGenBottomNavBarState();
}

class _EchoGenBottomNavBarState extends State<EchoGenBottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }
  
  @override
  void didUpdateWidget(EchoGenBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _previousIndex) {
      _animationController.forward(from: 0.0);
      _previousIndex = widget.currentIndex;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: (index) {
                if (index != widget.currentIndex) {
                  _animationController.forward(from: 0.0);
                  widget.onTap(index);
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: isDarkMode ? AppTheme.primaryLight : AppTheme.primaryBlue,
              unselectedItemColor: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              selectedLabelStyle: AppTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTheme.labelMedium,
              type: BottomNavigationBarType.fixed,
              items: [
                _buildNavItem(
                  icon: Icons.add_circle_outline_rounded,
                  activeIcon: Icons.add_circle_rounded,
                  label: 'Create',
                  tooltip: 'Create new podcast',
                  isSelected: widget.currentIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.headphones_outlined,
                  activeIcon: Icons.headphones,
                  label: 'Library',
                  tooltip: 'Your podcast library',
                  isSelected: widget.currentIndex == 1,
                  showBadge: widget.showBadge,
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  tooltip: 'App settings',
                  isSelected: widget.currentIndex == 2,
                ),
              ],
            );
          }
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String tooltip,
    required bool isSelected,
    bool showBadge = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    Widget iconWidget = Icon(isSelected ? activeIcon : icon);
    
    // Apply scale animation to the selected item
    if (isSelected) {
      iconWidget = ScaleTransition(
        scale: _scaleAnimation,
        child: iconWidget,
      );
    }
    
    // Add badge if needed
    if (showBadge) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.secondaryRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return BottomNavigationBarItem(
      icon: iconWidget,
      label: label,
      tooltip: tooltip,
    );
  }
} 