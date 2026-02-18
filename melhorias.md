🟢 1 Clean Architecture (separar camadas)
🟢 2 Senha forte + indicador visual
🟢 3 MFA (email verify + TOTP)
🟢 4 Navegação global (drawer) UX/Modularidade
🟢 5 Flutter pub outdated
🟢 6 Cache local
🟡 7 Bundle size (antes/depois)
🟢 8 dart analyze (antes/depois)
🟢 9 Firebase Crashlytics + Performance Observabilidade

1 - Clean arch implementada
2 - Senha forte (8 digitos, numero, maiusuculo e simbolo) implementada
3 - obrigatório verificação de email para entrar e possíver ter TOTP
4 - nova nevagação em todas as abas, não é mais necessário voltar no dash para mudar de tela.
5 - Comando "flutter pub upgrade" e atualizou 17 dependências. A única restante (fl_chart) é uma major version que optei por não atualizar para evitar breaking changes nos gráficos.
6 - O Firestore já implementa cache local nativo via snapshots. Complementamos com cache de imagens via CachedNetworkImage para comprovantes, 1ª vez que o comprovante é aberto baixa da rede e salva no cache local do dispositivo, 2ª vez em diante carrega instantaneamente do disco.
7 -
8 - dart analyze - 0 issues found
9 - Painel de Crashlytics e performance no Firebase ativos - botão apra simualr crash adicionado.
