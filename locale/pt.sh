#!/usr/bin/env bash
# locale/pt.sh — Brazilian Portuguese message catalog for bc250-beast.
# Machine-drafted, needs review by a native speaker. Sourced by lib/i18n.sh
# on top of locale/en.sh (any key missing here shows up in English).
#
# Rules (same as en.sh):
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical in every language (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / language selection
# ------------------------------------------------------------------
MSG[lang_name]="Português (Brasil)"
MSG[i18n_invalid]="Idioma desconhecido: %s (disponíveis: %s)"
MSG[i18n_switched]="Idioma: %s (%s)"
MSG[i18n_save_q]="Salvar esta escolha no arquivo de config (%s)?"
MSG[i18n_saved]="Idioma salvo na config: %s"
MSG[i18n_save_failed]="Não foi possível salvar o idioma (arquivo de config não encontrado: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Continuar?"
MSG[common_yn]="[s/N]"
MSG[common_yes_regex]="^[SsYy]$"
MSG[common_continue_anyway_q]="Continuar mesmo assim?"
MSG[common_empty]="<vazio>"
MSG[common_need_root]="Este módulo precisa ser executado como root (sudo)."
MSG[common_hw_check_skipped]="Detecção de hardware ignorada (--force)."
MSG[common_no_bc250]="Nenhuma AMD BC-250 detectada (PCI 1002:13fe não encontrado). Use --force para ignorar esta proteção."
MSG[common_bc250_found]="AMD BC-250 detectada (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live falhou, voltando para uma instalação normal (será preciso reiniciar depois)"
MSG[common_steamos_unsupported]="SteamOS imutável não é suportado — Bazzite é a distro recomendada pelo guia."
MSG[common_unknown_distro_pkg]="Distribuição não reconhecida, instale manualmente: %s"
MSG[common_reboot_needed]="É necessário reiniciar para aplicar as alterações acima."
MSG[common_reboot_now_q]="Reiniciar agora?"
MSG[common_reboot_reminder]="Não se esqueça de reiniciar antes de continuar com os próximos módulos."
MSG[common_config_created]="Nenhuma config encontrada, o exemplo foi copiado para %s (ajuste-o à sua placa)."
MSG[common_config_missing]="Arquivo de config não encontrado: %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine em todo o seu potencial"
MSG[common_m01_not_confirmed]="O módulo 01 (refrigeração/alimentação) não foi confirmado."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh — ponto de entrada único do bc250-beast.

Transforma uma AMD BC-250 em uma \"fera\" orquestrando, na ordem
recomendada pela comunidade (síntese do Old Lamer, docs/guide_old_lamer.md),
as ferramentas incorporadas (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI Forbidden-Darkness) e alguns
ajustes de sistema (zswap, mitigações, MangoHud).

Uso:
  sudo ./install.sh                 # menu interativo
  sudo ./install.sh --all           # executa todos os módulos em ordem
  sudo ./install.sh --module 05     # executa somente o módulo 05
  sudo ./install.sh --status        # diagnóstico rápido do estado atual
  sudo ./install.sh --lang pt       # idioma da interface, um código por
                                    # arquivo em locale/ (também BC250_LANG
                                    # ou UI_LANG na config)
  sudo ./install.sh --all --yes     # não interativo (usa os valores da
                                    # config sem confirmar cada etapa —
                                    # reserve isto para reimplantar uma
                                    # config já validada manualmente)
  sudo ./install.sh --force ...     # pula a detecção PCI da BC-250
                                    # (útil em dev / CI sem hardware real)"

MSG[mod_00_desc]="Verificações preliminares (hardware, distro, dependências)"
MSG[mod_01_desc]="Refrigeração e alimentação (checklist física)"
MSG[mod_02_desc]="BIOS/UEFI modificada (8 núcleos integrados + 512MB VRAM)"
MSG[mod_03_desc]="Desbloqueio 8 núcleos CPU (software, com persistência)"
MSG[mod_04_desc]="Desbloqueio de Compute Units da GPU (até 40 CU)"
MSG[mod_05_desc]="Overclock/undervolt da CPU (SMU)"
MSG[mod_06_desc]="Overclock da GPU (governor cyan-skillfish)"
MSG[mod_07_desc]="Ajustes do sistema (zswap, mitigações, MangoHud)"
MSG[mod_08_desc]="Extras opcionais (gabinetes, NullVRS, links da comunidade)"
MSG[mod_09_desc]="Validação e benchmark"

MSG[inst_module_not_found]="Módulo não encontrado: %s"
MSG[inst_module_failed]="O módulo %s falhou (código de saída %s). Interrompendo a sequência — corrija o problema e execute novamente com --module %s."
MSG[inst_status_title]="Status atual"
MSG[inst_status_bc250_yes]="AMD BC-250 detectada."
MSG[inst_status_bc250_no]="Nenhuma AMD BC-250 detectada neste sistema."
MSG[inst_status_distro]="Distribuição: %s"
MSG[inst_status_threads]="Threads CPU   : %s"
MSG[inst_status_mitig_off]="Mitigações    : desativadas"
MSG[inst_status_mitig_on]="Mitigações    : ativas (padrão)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Swap ativo    : sim"
MSG[inst_status_swap_no]="Swap ativo    : não"
MSG[inst_status_unlock_svc]="Unlock 8 núcleos (serviço): ativado"
MSG[inst_status_oc_svc]="OC da CPU (serviço)       : ativado"
MSG[inst_status_umr_yes]="umr           : instalado"
MSG[inst_status_umr_no]="umr           : ausente"
MSG[inst_status_gpu_hint]="Para detalhes da GPU (tabela WGP / CUs ativas):"
MSG[inst_menu_config]="Config ativa  : %s"
MSG[inst_menu_lang]="Idioma        : %s"
MSG[inst_menu_all]="a) Executar tudo na ordem recomendada"
MSG[inst_menu_status]="s) Status / diagnóstico"
MSG[inst_menu_edit]="e) Editar a config (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Idioma / Language"
MSG[inst_menu_quit]="q) Sair"
MSG[inst_prompt_choice]="Escolha: "
MSG[inst_press_enter]="Pressione Enter para continuar..."
MSG[inst_done_press_enter]="Concluído. Pressione Enter para continuar..."
MSG[inst_invalid_choice]="Escolha inválida."
MSG[inst_unknown_arg]="Argumento desconhecido: %s (veja --help)"
MSG[inst_module_needs_id]="--module requer um identificador (ex.: 05-cpu-overclock ou 05)"
MSG[inst_no_module_number]="Nenhum módulo corresponde ao número %s"
MSG[inst_lang_needs_arg]="--lang requer um código de idioma (disponíveis: %s)"
MSG[inst_final_validation_q]="Executar a validação final (módulo 09)?"
MSG[inst_yes_mode_validation]="Modo --yes: executando a validação final automaticamente."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh — remove as alterações PERSISTENTES feitas pelo bc250-beast.
Não mexe na BIOS gravada (módulo 02) nem na refrigeração/fiação (módulo 01).

Uso:
  sudo ./uninstall.sh [--lang <código>]"
MSG[uninst_title]="Desinstalando as alterações persistentes do bc250-beast"
MSG[uninst_rm_core_unlock]="Removendo o serviço bc250-core-unlock..."
MSG[uninst_disable_smu_oc]="Desativando o serviço bc250-smu-oc (ajuste de OC da CPU)..."
MSG[uninst_gpu_stock]="Restaurando a tabela WGP de fábrica (24 CU) e removendo o serviço de boot..."
MSG[uninst_rm_file]="Removendo %s"
MSG[uninst_kargs]="Removendo os kernel args adicionados (zswap, mitigations)..."
MSG[uninst_kargs_reboot]="É necessário reiniciar para aplicar a remoção dos kernel args."
MSG[uninst_swap_kept_1]="O swapfile Btrfs (/var/swap) e sua linha no fstab NÃO foram removidos"
MSG[uninst_swap_kept_2]="automaticamente (destrutivo). Remova-os manualmente se desejar:"
MSG[uninst_done_1]="Desinstalação concluída. A BIOS gravada (módulo 02) e a fiação"
MSG[uninst_done_2]="(módulo 01) permanecem no lugar — são alterações de hardware."

# ------------------------------------------------------------------
# Module 00 — preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Verificações preliminares"
MSG[m00_q_test_boot]="Você já fez um boot de teste (fonte + teclado + DisplayPort) e confirmou o acesso à BIOS antes de continuar?"
MSG[m00_dry_test_boot]="[DRY-RUN] Pergunta do boot de teste: %s"
MSG[m00_strongly_recommended]="Fortemente recomendado antes de qualquer alteração."
MSG[m00_abort_user]="Interrompido a pedido do usuário. Faça o boot de teste e execute novamente."
MSG[m00_distro_detected]="Distribuição detectada: %s"
MSG[m00_distro_unknown]="Distribuição não reconhecida automaticamente. Os módulos podem falhar nas etapas de instalação de pacotes."
MSG[m00_kernel]="Kernel: %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Ferramentas ausentes: %s"
MSG[m00_install_deps_q]="Instalar as dependências básicas agora?"
MSG[m00_deps_ok]="Todas as dependências básicas estão presentes."
MSG[m00_done]="Verificações preliminares concluídas."

# ------------------------------------------------------------------
# Module 01 — cooling & power
# ------------------------------------------------------------------
MSG[m01_title]="01 - Refrigeração e alimentação (etapas físicas)"
MSG[m01_checklist]="Este módulo não altera nada na máquina: refrigeração e alimentação
são etapas de hardware que devem ser feitas ANTES de aplicar o
overclock por software (módulos 05/06), sob risco de travamentos,
throttling ou até danos ao hardware.

Checklist (veja docs/guide_old_lamer.md seções 2 e 3 para os detalhes):

  [ ] Refrigeração escolhida e montada:
        - water cooler AIO de 240mm (melhor opção, <60°C sob carga)
        - ou 1x fan de 120mm (ex.: Arctic P12 Pro) em um dissipador
          parcialmente aberto (corte APENAS a área do fan)
  [ ] Pasta térmica trocada na APU: PTM 7950 (ganho de 5-8°C)
  [ ] Thermal putty aplicado nos VRMs + chips GDDR
  [ ] Dissipador passivo colado no backplate (área de RAM/VRAM)
  [ ] Arruelas plásticas adicionadas sob os parafusos com mola do
        dissipador central (pressão de contato do PTM 7950).
  [ ] Se usar um fan usado sem PWM: nunca abaixo de 1800 RPM.
  [ ] Fonte dimensionada corretamente: pelo menos 25A na linha de 12V
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / fonte de servidor
        Dell-HP reaproveitada com pinagem verificada)
  [ ] Se a placa estiver desbloqueada para 40 CU + overclock pesado (>300W):
        2x conectores Molex Microfit 3.0 (43025-0800) adicionados ao lado
        do conector PCIe original, fios AWG18 no mínimo

⚠️  O único conector PCIe original pode DERRETER sob carga pesada
    (40 CU desbloqueadas + overclock). Não avance com o overclock da GPU
    (módulo 06) sem esta etapa se a meta for acima de ~250-300W.
"
MSG[m01_confirm_q]="Você confirma que a refrigeração e a alimentação estão instaladas e validadas?"
MSG[m01_confirmed]="Etapa física validada pelo usuário. Você pode continuar."
MSG[m01_not_confirmed]="Etapa não confirmada. É fortemente recomendado resolvê-la antes de passar ao overclock (módulos 05/06)."

# ------------------------------------------------------------------
# Module 02 — BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - BIOS/UEFI modificada (8 núcleos integrados + 512MB VRAM)"
MSG[m02_intro]="Esta etapa grava (flash) uma BIOS modificada (Forbidden-Darkness UEFI Menu
Script) que:
  - integra o desbloqueio dos 8 núcleos da CPU diretamente em um menu da
    BIOS (persistente, sem precisar rodar um script a cada cold boot)
  - permite mudar a alocação de VRAM de 8 GB (padrão) para 512 MB,
    necessária para a alocação dinâmica de RAM/VRAM nos jogos

Procedimento (resumo — siga o vídeo oficial do projeto para os detalhes
visuais, link em docs/guide_old_lamer.md seção 4):

  1. É necessário um pendrive formatado.
  2. Este script copia reboot-uefi.sh + o Firmware.7z para o pendrive.
  3. Você vai executar reboot-uefi.sh com a opção 4 (extrair o .7z no
     pendrive) e depois a opção 2 (reinicialização única pelo pendrive
     via efibootmgr).
  4. Já no shell UEFI: fs1: -> execute a ferramenta de flash incluída no
     .7z -> faça backup da BIOS antiga (prefixo -O) -> grave a nova
     (-P -N).
  5. Limpe o CMOS (jumper ou remova a bateria por 20-30s).
  6. Na nova BIOS: ative \"Unlock CPU cores\" e volte a VRAM para
     512 MB (valor definido na config: BIOS_TARGET_VRAM_MB).

⚠️  Um flash de BIOS malfeito pode inutilizar a placa. Siga o procedimento
    à risca e guarde o backup da BIOS antiga."
MSG[m02_no_removable]="Nenhum dispositivo removível detectado."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: o flash da BIOS é uma etapa física (reinicialização no shell UEFI + manuseio"
MSG[m02_yes_mode_skip_2]="manual) que não pode ser tornada não interativa. Etapa de cópia para o pendrive ignorada."
MSG[m02_usb_prompt]="Ponto de montagem do pendrive de destino (ex.: /run/media/\$USER/USBSTICK), vazio para pular: "
MSG[m02_copying]="Copiando reboot-uefi.sh e Firmware.7z para %s ..."
MSG[m02_copied]="Arquivos copiados. Em seguida execute, A PARTIR DO PENDRIVE:"
MSG[m02_copy_skipped]="Cópia ignorada. Você pode executar manualmente:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh é uma ferramenta interativa (menu, prompts) — não iniciada automaticamente."
MSG[m02_yes_mode_tool_2]="Execute-a você mesmo: sudo bash '%s'"
MSG[m02_run_tool_q]="Iniciar agora a ferramenta interativa reboot-uefi.sh (opções 4 e depois 2 do menu)?"
MSG[m02_reminder_1]="Lembrete: após o flash + limpeza do CMOS, entre na BIOS para ativar"
MSG[m02_reminder_2]="\"Unlock CPU cores\" e ajustar a VRAM para %s MB antes de continuar."
MSG[m02_flashed_q]="O flash da BIOS foi concluído e a opção 'Unlock CPU cores' está ativada na BIOS?"
MSG[m02_flag_created]="Flag bios_flashed.flag criado — o módulo 03 detectará a BIOS modificada."
MSG[m02_flag_not_created]="Flag não criado. O módulo 03 tentará o desbloqueio por software (volátil)."

# ------------------------------------------------------------------
# Module 03 — CPU core unlock
# ------------------------------------------------------------------
MSG[m03_title]="03 - Desbloqueio de 8 núcleos da CPU"
MSG[m03_bios_detected_1]="BIOS modificada detectada. O desbloqueio de 8 núcleos é feito nativamente pela BIOS."
MSG[m03_bios_detected_2]="Lembre-se de verificar se a opção 'Unlock CPU cores' está ativada no menu da BIOS."
MSG[m03_stop_governor]="Parando temporariamente o cyan-skillfish-governor-smu (necessário para a escrita no SMU)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 na config, módulo ignorado."
MSG[m03_attempt]="Tentando desbloquear os núcleos da CPU..."
MSG[m03_mask_written]="Máscara de presença da CPU escrita com sucesso."
MSG[m03_unlock_failed_1]="Falha no desbloqueio. Veja a saída acima. Uma máscara fora do padrão (≠0x77)"
MSG[m03_unlock_failed_2]="sugere um defeito real no silício: releia modules/03-cpu-core-unlock antes de forçar."
MSG[m03_install_service_q]="Instalar o serviço systemd de persistência (reaplicado a cada boot)?"
MSG[m03_service_installed]="Serviço bc250-core-unlock.service instalado e ativado."
MSG[m03_takes_effect_after_reboot]="O desbloqueio entra em vigor APÓS reiniciar (a escrita no SMU só ativa os núcleos no próximo boot)."
MSG[m03_no_persistence]="Persistência não instalada: execute este módulo novamente após cada corte total de energia."
MSG[m03_reboot_q]="Reiniciar agora para ativar os 8 núcleos?"

# ------------------------------------------------------------------
# Module 04 — GPU CU unlock
# ------------------------------------------------------------------
MSG[m04_title]="04 - Desbloqueio de Compute Units (CU) da GPU"
MSG[m04_umr_missing]="umr não encontrado, instalando via ferramenta incluída..."
MSG[m04_immutable_reboot]="Sistema imutável (rpm-ostree): é necessário reiniciar antes de continuar."
MSG[m04_rerun_after_reboot]="Execute este módulo novamente após reiniciar."
MSG[m04_current_table]="Tabela WGP atual:"
MSG[m04_mode_full]="Modo da config: FULL -> desbloqueando todas as 40 CUs (20 WGPs)."
MSG[m04_mode_factory]="Modo da config: FACTORY -> restaurando a tabela de fábrica (24 CUs)."
MSG[m04_mode_custom]="Modo da config: CUSTOM -> desbloqueio total e depois mascaramento dos WGPs listados."
MSG[m04_disable_wgp]="Desativando WGP defeituoso: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom mas GPU_CU_DISABLE_LIST está vazia, nada a mascarar."
MSG[m04_unknown_mode]="GPU_CU_MODE desconhecido na config: %s (esperado: full|factory|custom)"
MSG[m04_new_table]="Nova tabela WGP:"
MSG[m04_test_stability]="Teste a estabilidade agora (FurMark Vulkan + um jogo) ANTES de tornar este ajuste permanente."
MSG[m04_make_permanent_q]="A configuração está estável, torná-la permanente no boot (write-service-table + install-service)?"
MSG[m04_permanent_done]="Tabela salva e serviço de restauração no boot instalado."
MSG[m04_live_only]="Ajuste aplicado somente AO VIVO: será perdido na próxima reinicialização."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Método alternativo \"kernel com patch\" (vendor/bc250-40cu-unlock):
  útil se o seu harvest map NÃO for simétrico (pares desativados
  espalhados em vez de todos do mesmo lado). Veja:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Este módulo (live manager) continua sendo o primeiro método recomendado.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 — CPU overclock
# ------------------------------------------------------------------
MSG[m05_title]="05 - Overclock / undervolt da CPU"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s excede o limite absoluto de segurança de 1300 mV. Corrija config/bc250-beast.conf."
MSG[m05_install_stress]="Instalando a ferramenta de teste de estresse 'stress-ng'..."
MSG[m05_install_smu_oc]="Instalando bc250-smu-oc a partir da cópia incorporada..."
MSG[m05_apply_q]="Aplicar %s MHz @ %s mV agora?"
MSG[m05_applying]="Aplicando o OC COM persistência (--keep): %s MHz @ %s mV (limite de temp. %s°C)"
MSG[m05_threads_warn_1]="%s threads visíveis (esperado 16 após o desbloqueio de 8 núcleos) — você"
MSG[m05_threads_warn_2]="reiniciou desde o módulo 03? O teste de estresse usará %s threads mesmo assim."
MSG[m05_stress_start]="Teste de estresse da CPU por %ss (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Teste de estresse falhou — revertendo para o stock."
MSG[m05_reverted]="Revertido para o stock."
MSG[m05_stable_q]="O sistema permaneceu estável, tornar este ajuste permanente no boot?"
MSG[m05_service_enabled]="Serviço bc250-smu-oc ativado no boot com %sMHz @ %smV."
MSG[m05_not_permanent]="Ajuste não tornado permanente — revertendo para o stock."
MSG[m05_monitoring_tip]="
Dicas de monitoramento:
  - amdgpu_top (métricas SMU ao vivo)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (detectar clock stretching)"

# ------------------------------------------------------------------
# Module 06 — GPU governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - Overclock da GPU (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Dependências de build ausentes:"
MSG[m06_install_with]="Instale com:"
MSG[m06_arch_libudev_note]="  # libudev é fornecida pelo systemd no Arch/CachyOS, sem pacote separado"
MSG[m06_ostree_build_env]="Ambiente de build disponível após reiniciar (sistema imutável rpm-ostree)"
MSG[m06_unknown_distro_deps]="Distribuição não reconhecida (%s). Instale manualmente: git, make, cargo, pkg-config, headers da libudev."
MSG[m06_deps_ok]="Todas as dependências de build estão presentes."
MSG[m06_cloning]="Clonando cyan-skillfish-governor (branch smu)..."
MSG[m06_repo_update]="Repositório já presente, atualizando..."
MSG[m06_pull_failed]="Pull falhou, continuando com a cópia local existente."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release em %s"
MSG[m06_building]="Compilando o governor (cargo build --release)..."
MSG[m06_build_failed]="cargo build falhou. Verifique os erros acima."
MSG[m06_build_ok]="Build concluído com sucesso. Binário: %s"
MSG[m06_follow_readme]="Instalação a partir de %s:
    binário, política D-Bus, wrapper performance-mode e
    o serviço systemd cyan-skillfish-governor-smu.
O serviço inicia imediatamente (sem necessidade de reiniciar)."
MSG[m06_installed_q]="Instalar o governor (binário + serviço systemd) e aplicar o ajuste abaixo?"
MSG[m06_config_postponed]="Instalação ignorada. Execute este módulo novamente para instalar e iniciar o governor."
MSG[m06_generating]="Gerando %s (curva idle -> alvo, temperatura alvo %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Escrevendo %s:"
MSG[m06_toml_header]="# Gerado por bc250-beast — módulo 06
# Os padrões do upstream podem ser instáveis: teste manualmente
# antes de ativar no boot."
MSG[m06_file_written]="Arquivo escrito: %s"
MSG[m06_progression]="Progressão recomendada por Old Lamer:
  1500 MHz (stock) -> 2000 MHz (passo fácil, ~10%%+ no FurMark)
  -> validar a CPU em 3,85 GHz (módulo 05) -> forçar mais a GPU
  SOMENTE se a refrigeração acompanhar (watercooling: até ~2,4 GHz
  relatado, ~360W / 30A, daí a importância dos conectores Molex
  extras do módulo 01).

  IMPORTANTE: após iniciar o serviço, rode uma carga real de GPU
  (FurMark Vulkan + um jogo) por alguns minutos e confira os logs
  (journalctl -u cyan-skillfish-governor-smu) antes de confiar."

# ------------------------------------------------------------------
# Module 07 — system tuning
# ------------------------------------------------------------------
MSG[m06_bin_installed]="Binário instalado: %s"
MSG[m06_perf_installed]="Wrapper performance-mode instalado: %s"
MSG[m06_dbus_installed]="Política D-Bus instalada: %s"
MSG[m06_service_installed]="Serviço systemd instalado: %s"
MSG[m06_started]="O serviço do governor está ativo."
MSG[m06_start_failed]="O serviço do governor não iniciou corretamente. Inspecione o serviço:"
MSG[m06_enable_boot_q]="Ativar o serviço do governor na inicialização (reaplica o OC a cada boot)?"
MSG[m06_enabled]="Serviço ativado na inicialização."
MSG[m07_title]="07 - Ajustes do sistema (zswap / mitigações / MangoHud)"
MSG[m07_zswap_ostree]="Ativando zswap + mitigations=off via kernel args (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Seria necessário reiniciar (sistema imutável rpm-ostree)."
MSG[m07_ostree_reboot]="É necessário reiniciar (sistema imutável rpm-ostree)."
MSG[m07_rerun_after_reboot]="Execute este módulo novamente após reiniciar: ele detectará que os kernel args já estão ativos."
MSG[m07_var_not_btrfs_1]="/var não está em Btrfs neste sistema — o procedimento oficial (swapfile Btrfs"
MSG[m07_var_not_btrfs_2]="dedicado) não se aplica como está. Crie um swapfile comum manualmente,"
MSG[m07_var_not_btrfs_3]="ou pule este submódulo se você não estiver no Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (se existir)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (reinicialização necessária)"
MSG[m07_dry_final_check]="[DRY-RUN] Verificação final: rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Desativando o swap existente..."
MSG[m07_rm_old_swap]="Removendo o antigo /var/swap..."
MSG[m07_create_subvol]="Criando o subvolume Btrfs /var/swap..."
MSG[m07_selinux_fix]="Corrigindo o contexto SELinux..."
MSG[m07_semanage_missing]="semanage ausente, é preciso instalar policycoreutils-python-utils (rpm-ostree, reinicialização)."
MSG[m07_rerun_selinux]="Execute este submódulo novamente após reiniciar para concluir a configuração do SELinux + criar o swapfile."
MSG[m07_create_swapfile]="Criando o swapfile de %sG..."
MSG[m07_fstab]="Adicionando ao /etc/fstab..."
MSG[m07_swapon]="Ativando o swap imediatamente..."
MSG[m07_swappiness]="Definindo vm.swappiness=%s (otimizado para jogos)..."
MSG[m07_final_check]="Verificação final:"
MSG[m07_zswap_not_active]="zswap ainda não está ativo (reinicialização pendente?)"
MSG[m07_mangohud_title]="Instalando o MangoHud (overlay de FPS/temperatura/uso de GPU-CPU)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] O MangoHud normalmente já vem instalado no Bazzite. Verificar: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud pré-instalado no SteamOS — pulando a instalação"
MSG[m07_mangohud_bazzite_check]="O MangoHud normalmente já vem instalado no Bazzite. Verificando..."
MSG[m07_mangohud_present]="MangoHud já presente."
MSG[m07_mangohud_steamos]="MangoHud pré-instalado no SteamOS — pulando a instalação"
MSG[m07_mangohud_steam_hint]="Para ativá-lo no Steam: adicione 'mangohud %%command%%' às opções de inicialização de um jogo."
MSG[m07_zswap_already]="zswap já ativado no nível do kernel, indo direto para a criação do swapfile."
MSG[m07_zswap_other_distro_1]="O procedimento oficial zswap+swapfile é documentado apenas para Bazzite/rpm-ostree+Btrfs."
MSG[m07_zswap_other_distro_2]="No %s: ative o zswap via GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="depois regenere a config do seu bootloader (grub-mkconfig / bootctl / etc., conforme o seu setup) e crie um swapfile comum."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 na config, etapa ignorada."
MSG[m07_mitig_title]="Desativando as mitigações da CPU (Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="Isso reduz a proteção contra alguns ataques locais (side-channel)."
MSG[m07_mitig_warn_2]="Recomendado apenas em uma máquina dedicada a jogos, não em uma estação de trabalho multiuso sensível."
MSG[m07_mitig_confirm_q]="Confirmar a desativação das mitigações da CPU?"
MSG[m07_mitig_ostree_done]="mitigations=off já aplicado via setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Adicione 'mitigations=off' ao GRUB_CMDLINE_LINUX (ou à sua config do systemd-boot),"
MSG[m07_mitig_grub_2_dry]="depois regenere a config do bootloader (grub-mkconfig / bootctl / etc.) e reinicie."
MSG[m07_mitig_grub_2]="depois regenere a config do bootloader e reinicie."
MSG[m07_mitig_done]="Mitigações desativadas (em vigor após reiniciar)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (ou não definido), etapa ignorada."
MSG[m07_done]="Módulo 07 concluído."

# ------------------------------------------------------------------
# Module 08 — extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Extras opcionais"
MSG[m08_intro]="Esta seção reúne extras opcionais mencionados nos vídeos do Old Lamer,
não essenciais para o funcionamento básico:

  1) Gabinetes impressos em 3D recomendados
       - NextGen3D (loja)      : https://nexgen3d.bigcartel.com/
       - NextGen3D (modelos)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro com water cooler de 240mm:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Alternativa com air cooler para CPU:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (camada Vulkan, útil em alguns títulos como Doom: The Dark
     Ages em uma GPU cortada): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling via Decky Loader (Frame Generation)
       - Requer o Decky Loader instalado previamente em sistemas tipo
         Bazzite/SteamOS (não incluído aqui, veja o Decky Loader oficial).

  4) Tela USB IPS de 3.5\" para monitoramento (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Comunidades:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="Não foi possível determinar o diretório home do usuário %s."
MSG[m08_dry_download]="[DRY-RUN] Baixar %s"
MSG[m08_dry_extract]="[DRY-RUN] Extrair em /tmp/nullvrs e copiar *.json + *.so para %s"
MSG[m08_downloading]="Baixando NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS instalado em %s (pertencente a %s):"
MSG[m08_files_not_found]="Arquivos não encontrados, verifique o arquivo baixado."
MSG[m08_repo_update]="Repositório já presente em %s, atualizando..."
MSG[m08_pull_failed]="Pull falhou."
MSG[m08_cloning_turing]="Clonando turing-smart-screen-python..."
MSG[m08_cloned_in]="Clonado em:"
MSG[m08_turing_steps]="Próximos passos (a fazer manualmente, conforme a sua distribuição):
  1) cd %s
  2) Crie um ambiente virtual Python: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Configure a tela (veja o README do repo: config.yaml, rotação, porta USB)
  5) Teste: python main.py
  6) Para o serviço systemd: copie turing-screen.service para /etc/systemd/system/ e ajuste os caminhos"
MSG[m08_see_readme]="Veja o README do repo para a configuração completa."
MSG[m08_community_title]="Links da comunidade BC-250"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="Loja NextGen3D"
MSG[m08_lbl_models]="Modelos no Printables"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Alternativa com air cooler para CPU"
MSG[m08_submenu_title]="Submenu de extras"
MSG[m08_opt_1]="1) Instalar Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Preparar Turing Smart Screen 3.5\" (clone + instruções)"
MSG[m08_opt_3]="3) Mostrar links da comunidade (formatados)"
MSG[m08_opt_q]="q) Voltar / Sair"
MSG[m08_prompt]="Escolha [1-3/q]: "
MSG[m08_done]="Módulo 08 concluído."

# ------------------------------------------------------------------
# Module 09 — validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Validação & Benchmark"
MSG[m09_invalid_status]="Status inválido para report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Comando: %s"
MSG[m09_instant_title]="Verificações instantâneas"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Verificando o número de núcleos da CPU (esperado: 16 threads / 8 núcleos físicos)"
MSG[m09_t_cpu_cores_16]="Núcleos CPU (16 threads / 8 núcleos)"
MSG[m09_threads_detected]="%s threads detectadas"
MSG[m09_t_cpu_cores_8]="Núcleos CPU (8 threads / 4 núcleos)"
MSG[m09_threads_not_unlocked]="%s threads — desbloqueio de 8 núcleos não aplicado (módulo 03)"
MSG[m09_t_cpu_cores]="Núcleos CPU"
MSG[m09_threads_unexpected]="%s threads — inesperado"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Verificando a frequência da CPU (config: %s MHz ±100 MHz)"
MSG[m09_t_cpu_freq_near]="Frequência CPU (perto de CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s MHz (alvo: %s MHz)"
MSG[m09_t_cpu_freq_diff200]="Frequência CPU (desvio ≤ 200 MHz)"
MSG[m09_t_cpu_freq_diff_gt200]="Frequência CPU (desvio > 200 MHz)"
MSG[m09_freq_target_diff]="%s MHz (alvo: %s MHz, desvio: %s MHz)"
MSG[m09_t_cpu_freq]="Frequência CPU"
MSG[m09_cpuinfo_unreadable]="Não foi possível ler /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Verificando as CUs ativas da GPU via bc250-cu-live-manager (config: %s)"
MSG[m09_t_gpu_cu_match]="CUs GPU ativas (conforme GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s CUs ativas (esperado: %s)"
MSG[m09_t_gpu_cu_mismatch]="CUs GPU ativas (difere de GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s CUs ativas (esperado: %s para o modo %s)"
MSG[m09_t_gpu_cu]="CUs GPU ativas"
MSG[m09_cu_detected_mode]="%s CUs ativas detectadas (modo da config: %s)"
MSG[m09_cu_parse_fail]="Não foi possível interpretar a saída do bc250-cu-live-manager"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager não instalado ou não executável"
MSG[m09_dry_services]="[DRY-RUN] Verificando os serviços systemd (bc250-core-unlock, bc250-smu-oc, cyan-skillfish-governor)"
MSG[m09_t_service]="Serviço %s"
MSG[m09_svc_active]="ativo"
MSG[m09_svc_enabled_inactive]="ativado mas não ativo (ainda iniciando?)"
MSG[m09_svc_inactive]="inativo / não ativado"
MSG[m09_dry_vram]="[DRY-RUN] Verificando a alocação de VRAM da BIOS (alvo: %s MB)"
MSG[m09_t_vram_target]="VRAM BIOS (%s MB)"
MSG[m09_vram_detected]="%s MB detectados"
MSG[m09_t_vram_default]="VRAM BIOS (8 GB = padrão de fábrica)"
MSG[m09_vram_default_msg]="VRAM em 8 GB (padrão), troca para 512 MB não aplicada (módulo 02)"
MSG[m09_t_vram]="VRAM BIOS"
MSG[m09_vram_detected_target]="%s MB detectados (alvo: %s MB)"
MSG[m09_vram_unknown]="Não foi possível determinar a alocação de VRAM"
MSG[m09_dry_temps]="[DRY-RUN] Verificando as temperaturas de CPU/GPU via sensors"
MSG[m09_t_cpu_temp_ok]="Temperatura CPU (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="Temperatura GPU (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="Temperatura CPU (> 85°C)"
MSG[m09_t_gpu_temp_high]="Temperatura GPU (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C — verifique a refrigeração (módulo 01)"
MSG[m09_t_cpu_temp]="Temperatura CPU"
MSG[m09_t_gpu_temp]="Temperatura GPU"
MSG[m09_temp_not_detected]="Não detectada via sensors"
MSG[m09_t_temps]="Temperatura CPU/GPU"
MSG[m09_sensors_missing]="Comando 'sensors' não disponível (lm-sensors não instalado)"
MSG[m09_dry_voltage]="[DRY-RUN] Verificando a tensão da CPU via bc250_smu_oc ou sensors (limite rígido: 1300 mV, tolerância ±50 mV vs CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="Tensão CPU (≤ 1300 mV, tol. ±50 mV)"
MSG[m09_t_voltage_danger]="Tensão CPU (> 1300 mV = PERIGO)"
MSG[m09_voltage_danger_msg]="%s mV (origem: %s) — EXCEDE O LIMITE ABSOLUTO DE SEGURANÇA"
MSG[m09_voltage_ok_msg]="%s mV (alvo: %s mV, origem: %s)"
MSG[m09_t_voltage_diff]="Tensão CPU (desvio > 50 mV vs config)"
MSG[m09_voltage_diff_msg]="%s mV (alvo: %s mV, desvio: %s mV, origem: %s)"
MSG[m09_t_voltage]="Tensão CPU"
MSG[m09_voltage_unreadable]="Tensão não legível (bc250_smu_oc, bc250_detect.py, sensors Vcore) — verifique manualmente"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Verificando a frequência da GPU via /sys/class/drm/card0/device/pp_dpm_sclk ou rocm-smi (alvo: %s MHz ±100 MHz)"
MSG[m09_t_gpu_freq_near]="Frequência GPU (GPU_FREQ_MHZ ±100 MHz)"
MSG[m09_gpu_freq_msg]="%s MHz (alvo: %s MHz, origem: %s)"
MSG[m09_t_gpu_freq_diff]="Frequência GPU (desvio > 100 MHz)"
MSG[m09_gpu_freq_diff_msg]="%s MHz (alvo: %s MHz, desvio: %s MHz, origem: %s)"
MSG[m09_t_gpu_freq]="Frequência GPU"
MSG[m09_gpu_freq_unreadable]="Não legível (pp_dpm_sclk ausente, rocm-smi ausente) — verifique manualmente"
MSG[m09_stability_title]="Testes de estabilidade (opcionais)"
MSG[m09_dry_stability]="[DRY-RUN] Testes de estabilidade: confirmação simulada = SIM, duração = %ss"
MSG[m09_yes_duration]="BC250_YES=1: duração padrão de 300 s (recomendado)."
MSG[m09_duration_prompt]="Duração do teste de estabilidade: 300 s (recomendado) ou 60 s (rápido)? [300/60]: "
MSG[m09_run_stability_prompt]="Executar os testes de estabilidade (%ss CPU + %ss GPU)? %s: "
MSG[m09_t_cpu_stability]="Estabilidade CPU (stress-ng %ss)"
MSG[m09_t_gpu_stability]="Estabilidade GPU (FurMark %ss)"
MSG[m09_stress_cpu_start]="Iniciando stress-ng CPU por %ss (usa todos os núcleos)..."
MSG[m09_finished_ok]="Concluído sem erros"
MSG[m09_failed_unstable]="Falha ou interrupção — instabilidade detectada"
MSG[m09_stress_ng_missing]="stress-ng não instalado (pkg_install stress-ng para adicioná-lo)"
MSG[m09_dry_furmark]="[DRY-RUN] Teste de GPU FurMark %ss"
MSG[m09_furmark_start]="Iniciando FurMark GPU por %ss..."
MSG[m09_furmark_missing]="FurMark não instalado, teste de GPU ignorado"
MSG[m09_stability_skipped]="Testes de estabilidade ignorados a pedido do usuário."
MSG[m09_skipped_user]="Ignorado (escolha do usuário)"
MSG[m09_score_excellent]="EXCELENTE"
MSG[m09_score_good]="BOM"
MSG[m09_score_check]="A REVISAR"
MSG[m09_report_title]="RELATÓRIO DE VALIDAÇÃO BC-250"
MSG[m09_report_passed]="Testes aprovados"
MSG[m09_report_warnings]="Avisos"
MSG[m09_report_failures]="Falhas"
MSG[m09_report_score]="Pontuação geral"
MSG[m09_reco_title]="Recomendações"
MSG[m09_reco_fail]="  • Alguns testes falharam. Verifique os módulos correspondentes:
    - Núcleos da CPU não desbloqueados → execute o módulo 03 novamente
    - Serviços systemd inativos        → journalctl -u <serviço> para diagnosticar
    - Frequência da CPU instável       → revise o módulo 05 (OC da CPU) + teste de estresse
    - VRAM não alterada para 512 MB    → refaça o módulo 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Alguns avisos foram emitidos:
    - Temperaturas altas               → verifique a refrigeração (módulo 01)
    - CUs / freq. GPU fora do esperado → revise os módulos 04, 05, 06
    - Ferramentas ausentes (sensors, FurMark, stress-ng)
      → instale-as com o seu gerenciador de pacotes"
MSG[m09_done]="Módulo 09 concluído (Pontuação: %s%% — %sP/%sW/%sF)."
