import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_dialog.dart';
import '../animation/lotus_painter.dart';
import 'origin_toast.dart';

class OriginHeader extends ConsumerWidget implements PreferredSizeWidget {
  const OriginHeader({
    super.key,
    this.onSearchTap,
    this.isScrolled = false,
  });

  final VoidCallback? onSearchTap;
  final bool isScrolled;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final currency = ref.watch(currencyProvider);
    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: OriginColors.ivory.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: OriginColors.gold.withValues(alpha: isScrolled ? 0.45 : 0.25),
            width: 1,
          ),
        ),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: const Color(0x145A3C14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CustomPaint(
                        painter: LotusPainter(
                          progress: 1.0,
                          strokeWidth: 1.8,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ORIGIN',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        letterSpacing: 4.5,
                        color: OriginColors.royalBronze,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Navigation (Desktop)
              if (isDesktop)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NavLink(label: 'Home', path: '/', isSelected: GoRouterState.of(context).uri.toString() == '/'),
                          _NavLink(label: 'Collections', path: '/shop', isSelected: GoRouterState.of(context).uri.toString().startsWith('/shop')),
                          _NavLink(label: 'Heritage Journal', path: '/journal', isSelected: GoRouterState.of(context).uri.toString().startsWith('/journal')),
                          _NavLink(label: 'Authenticity', path: '/authenticity', isSelected: GoRouterState.of(context).uri.toString().startsWith('/authenticity')),
                          _NavLink(label: 'About', path: '/about', isSelected: GoRouterState.of(context).uri.toString().startsWith('/about')),
                          if (authState.isAdmin)
                            _NavLink(label: 'Admin', path: '/admin', isSelected: GoRouterState.of(context).uri.toString().startsWith('/admin'), isAccent: true),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              // Right Icons & Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Currency Toggle Button
                  InkWell(
                    onTap: () {
                      ref.read(currencyProvider.notifier).toggleCurrency();
                      showOriginToast(
                        context,
                        'Currency switched to ${currency == Currency.usd ? "INR (₹)" : "USD (\$)"}',
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: OriginColors.gold.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        currency == Currency.usd ? 'USD' : 'INR',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ),
                  ),

                  // Search icon
                  _HeaderIconButton(
                    icon: Icons.search,
                    tooltip: 'Search catalogue',
                    onTap: onSearchTap ??
                        () {
                          context.go('/shop');
                          showOriginToast(context, 'Explore products or filter by category');
                        },
                  ),

                  // Account / Profile icon
                  _HeaderIconButton(
                    icon: authState.isSignedIn ? Icons.person : Icons.person_outline,
                    tooltip: authState.isSignedIn
                        ? 'My Royal Account (${authState.user?.firstName})'
                        : 'Sign In / Register',
                    onTap: () {
                      if (authState.isSignedIn) {
                        context.go('/account');
                      } else {
                        showAuthDialog(
                          context,
                          reason: 'Please register or log in to manage your royal account.',
                        );
                      }
                    },
                  ),

                  // Wishlist icon
                  _HeaderIconButton(
                    icon: Icons.favorite_border,
                    tooltip: 'My Wishlist',
                    badgeCount: wishlist.length,
                    onTap: () async {
                      if (!await requireAuth(context, ref, 'view your wishlist')) return;
                      if (!context.mounted) return;
                      context.go('/wishlist');
                    },
                  ),

                  // Bag icon
                  _HeaderIconButton(
                    icon: Icons.shopping_bag_outlined,
                    tooltip: 'Shopping Bag',
                    badgeCount: cartState.totalItemCount,
                    onTap: () async {
                      if (!await requireAuth(context, ref, 'view your bag')) return;
                      if (!context.mounted) return;
                      context.go('/cart');
                    },
                  ),

                  // Mobile menu drawer toggle
                  if (!isDesktop)
                    IconButton(
                      icon: const Icon(Icons.menu, color: OriginColors.royalBronze),
                      onPressed: () {
                        _showMobileMenu(context, ref);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OriginColors.ivoryLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final auth = ref.watch(authControllerProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OriginColors.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _MobileNavLink(label: 'Home', path: '/', icon: Icons.home_outlined),
                _MobileNavLink(label: 'Shop & Collections', path: '/shop', icon: Icons.grid_view),
                _MobileNavLink(label: 'Heritage Journal', path: '/journal', icon: Icons.auto_stories_outlined),
                _MobileNavLink(label: 'Authenticity & Provenance', path: '/authenticity', icon: Icons.verified_outlined),
                _MobileNavLink(label: 'About ORIGIN', path: '/about', icon: Icons.info_outline),
                if (auth.isAdmin)
                  _MobileNavLink(label: 'Admin Panel', path: '/admin', icon: Icons.admin_panel_settings_outlined),
                const Divider(height: 24),
                if (auth.isSignedIn) ...[
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined, color: OriginColors.goldDark),
                    title: Text('My Account (${auth.user?.name})'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/account');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: OriginColors.inkMuted),
                    title: const Text('Sign Out'),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                      Navigator.pop(ctx);
                      showOriginToast(context, 'Signed out');
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.login, color: OriginColors.goldDark),
                    title: const Text('Register / Sign In'),
                    onTap: () {
                      Navigator.pop(ctx);
                      showAuthDialog(context, reason: 'Welcome to ORIGIN.');
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.path,
    required this.isSelected,
    this.isAccent = false,
  });

  final String label;
  final String path;
  final bool isSelected;
  final bool isAccent;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isAccent
        ? OriginColors.royalBronze
        : (widget.isSelected || _hovered ? OriginColors.goldDark : OriginColors.ink);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: widget.isSelected || widget.isAccent ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.isSelected || _hovered ? 20 : 0,
                color: OriginColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavLink extends StatelessWidget {
  const _MobileNavLink({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: OriginColors.goldDark, size: 20),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: OriginColors.ink,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int badgeCount;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(widget.icon, size: 21),
          color: _hovered ? OriginColors.goldDark : OriginColors.royalBronze,
          tooltip: widget.tooltip,
          onPressed: widget.onTap,
        ),
        if (widget.badgeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              scale: 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: OriginColors.goldDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  widget.badgeCount > 9 ? '9+' : widget.badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: button,
    );
  }
}
