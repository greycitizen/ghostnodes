# ◈ Ghost Node Nation ◈

<div align="center">
  <img src="https://img.shields.io/badge/Status-Beta-blue.svg" alt="Status">
  <img src="https://img.shields.io/badge/Platform-OrangePi%20%7C%20RaspberryPi-ff69b4.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Script-Bash-4EAA25.svg?logo=gnu-bash" alt="Bash">
</div>

<br>

O **Ghost Node Nation** é um ecossistema completo e modular desenhado para facilitar a instalação, configuração e o monitoramento de infraestruturas locais de Bitcoin (Nodes) em hardwares limitados ou de placa única (SBCs), como Orange Pi e Raspberry Pi.

Nosso objetivo é proporcionar um painel de controle simples (via terminal), altamente resiliente a quedas de energia e corrupções de cartão de memória, levando um node focado em soberania e privacidade para as mãos de qualquer usuário (Pleb).

---

## 🚀 Como Funciona

Toda a arquitetura do projeto gira em torno da **`core_lib.sh`**, nossa biblioteca que fornece os padrões visuais, interativos e de sobrevivência ao projeto:
- Tratamento extremo de erros do gerenciador de pacotes (`apt/dpkg`).
- Persistência de estado de instalação (em caso de falhas, as instalações retornam de onde pararam).
- Painéis coloridos, com banners dinâmicos e leituras de temperatura / hardware integrados.

No coração da operação mora o **`ghostnode`**, um painel que permite checar o status de portas, configurações de Docker, conexões de Rede Wi-Fi (modo router/AP) e controlar todos os subprojetos (onde mora a inteligência central do Bitcoin).

---

## 📦 Projetos (SubNodes)

O Ghost Nodes é dividido em subprojetos modulares. Os atualmente em operação e em desenvolvimento são:

- [x] **Halfin Node:** A espinha dorsal. Focado no setup inicial, ferramentas de diagnóstico de hardware, Wi-Fi e instalação da stack via Docker e Portainer em placas como a Orange Pi Zero 3.
- [x] **Satoshi Node:** Dedicado puramente à camada base do Bitcoin. Baixa binários confiavelmente (Bitcoin Core ou Knots), suporta arquiteturas x86 e ARM, e inicia o painel de sincronização.
- [ ] **Nick Node:** *(Em desenvolvimento)*
- [ ] **Nash Node:** *(Em desenvolvimento)*
- [ ] **Adam Node:** *(Em desenvolvimento)*
- [ ] **Fiatjaf Node:** *(Em desenvolvimento)*
- [ ] **Craig Node:** *(Para se divertir e apagar em seguida)*

---

## 🛠 Como Instalar

A recomendação atual é iniciar a partir de um sistema limpo (como um Debian Bookworm no usuário padrão das placas SBC).

O instalador raiz foi construído à prova de falhas com proteção TTY, permitindo a instalação de um único comando (via cURL) ou local.

### Método 1: Comando Único (Online Bootstrap)

```bash
curl -fsSL https://raw.githubusercontent.com/greycitizen/ghostnodes/refs/heads/main/install.sh | sudo bash
```
> O script tentará automaticamente vincular o ambiente e escalar dependências, criando o usuário `pleb` ideal.

### Método 2: Instalação Manual via Git Clone

```bash
sudo apt update && sudo apt install git -y
sudo git clone https://github.com/greycitizen/ghostnodes.git /home/pleb/nodenation
cd /home/pleb/nodenation
sudo bash install.sh
```

---

## 🎮 Como Usar o Menu Principal

Após a instalação fundamental, todo o ecossistema é orquestrado através do script de menu. Basta acessar a pasta criada ou rodar os executáveis globais:

1. **Acessar o Painel de Redes e Subsistemas:**
   Se instalado globalmente, basta digitar em qualquer lugar:
   ```bash
   ghostnode
   ```
   *Este comando abre o dashboard universal contendo opções para checar Wi-Fi, Serviços e logs del Bitcoin (No menu `4 - Satoshi Node`).*

2. **Acessar o Gerenciador de Instalação (Projetos):**
   Caso deseje instalar novos projetos modulares na máquina:
   ```bash
   cd /home/pleb/nodenation
   sudo ./menu.sh
   ```
   *Um menu de projetos surgirá, permitindo empilhar o Halfin Node com Satoshi, etc.*

---

## 📁 Estrutura de Arquivos

```text
nodenation/
├── install.sh         # Instalador Base e Bootstrapper Seguro
├── ghostnode          # Painel de Controle Principal (Dash/Tracker)
├── menu.sh            # Seletor Principal de Instalação de Subprojetos
├── lib/
│   └── core_lib.sh    # Engine central de UI e tratamento de erro (Dpkg/Apt)
├── var/
│   └── globals.env    # Rotas globais, variáveis de ambiente e definições estritas
├── halfin/            # Projeto Base: Hardware e Docker Stack
└── satoshi/           # Projeto Bitcoin: Arquitetura, Core vs Knots, Status
```

---

<p align="center">
  <i>Construído sob máxima Soberania e Privacidade.</i><br>
  <b>Ghost Node Nation © 2026</b>
</p>
