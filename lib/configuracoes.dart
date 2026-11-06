import 'package:flutter/material.dart';

import 'api_service.dart';
import 'tema.dart';
import 'perfil.dart';
import 'ajuda_suporte.dart';
import 'sobre.dart';
import 'login_page.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  AppCores cOf(BuildContext context) => context.cores;

  @override
  Widget build(BuildContext context) {
    final c = cOf(context);
    final user = ApiService.usuario;
    final nome = (user?['name'] ?? user?['nome'] ?? 'Usuário').toString();
    final email = (user?['email'] ?? '').toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'Configurações',
          style: TextStyle(
            color: c.texto,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Conta, aparência e suporte',
          style: TextStyle(color: c.textoSuave, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: c.gradCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.bordaSutil),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: c.roxo.withValues(alpha: 0.15),
                child: Text(
                  nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: c.roxo,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(color: c.textoSuave, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _tile(
          context,
          icon: Icons.person_outline,
          title: 'Perfil',
          subtitle: 'Nome, e-mail e dados pessoais',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Perfil(aoVoltar: () => Navigator.pop(context)),
              ),
            );
          },
        ),
        _tile(
          context,
          icon: Icons.dark_mode_outlined,
          title: 'Tema',
          subtitle: AppTema.escuro ? 'Modo escuro ativo' : 'Modo claro ativo',
          trailing: Switch(
            value: AppTema.escuro,
            onChanged: (v) => AppTema.definirEscuro(v),
          ),
          onTap: () => AppTema.definirEscuro(!AppTema.escuro),
        ),
        _tile(
          context,
          icon: Icons.help_outline,
          title: 'Ajuda e suporte',
          subtitle: 'Dúvidas e contato',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AjudaSuporte()),
            );
          },
        ),
        _tile(
          context,
          icon: Icons.info_outline,
          title: 'Sobre',
          subtitle: 'EasySell e versão do app',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Sobre(aoVoltar: () => Navigator.pop(context)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ApiService.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sair da conta'),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.vermelho,
            side: BorderSide(color: c.bordaMedia),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final c = cOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: c.gradCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.bordaSutil),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.roxo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: c.roxo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: c.texto,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: c.textoSuave, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.chevron_right_rounded, color: c.textoFraco),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
