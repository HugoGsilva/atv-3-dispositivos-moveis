import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Após 3 segundos, navega para a tela principal.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B130F),
                    Color(0xFF0F3A28),
                    Color(0xFF177A4F),
                  ]
                : const [
                    Color(0xFF0F7A4D),
                    Color(0xFF1B8A5A),
                    Color(0xFF34D399),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Conteúdo central
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LogoEmblem(),
                        const SizedBox(height: 28),
                        const Text(
                          'Pódio da Turma',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ranking de Popularidade dos Alunos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Pill IFPR
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Text(
                            'IFPR – Campus Paranaguá',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Indicador de progresso fino na base
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Emblema da marca: "squircle" translúcido com uma pirâmide de degraus
/// (3 barras crescentes) coroada por uma estrela — alusão ao ranking.
class _LogoEmblem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.starColor, size: 26),
          const SizedBox(height: 6),
          // Pirâmide de 3 degraus
          ..._steps(),
        ],
      ),
    );
  }

  List<Widget> _steps() {
    const widths = [22.0, 38.0, 54.0];
    return [
      for (final w in widths)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: w,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
    ];
  }
}
