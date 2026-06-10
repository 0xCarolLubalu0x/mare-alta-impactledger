
# Maré Alta · ImpactLedger
 
> Protocolo de registro auditável de impacto ambiental em blockchain.  
> HackWeb · Residência TIC19 · Desafio 3 — ImpactLedger
 
---
 
## 🔗 Links rápidos
 
| | |
|---|---|
| 🎥 **Pitch no YouTube** | _https://youtu.be/l3czDoEI6ag_ |
| 📄 **Slides (PDF)** | [slides_marealta.pdf](./slides_marealta.pdf) |
| ⛓️ **Contrato no Etherscan (Sepolia)** | _[0x9a3E76Fbd5B4a14DffC5E32c76a8B19B6407b99A](https://sepolia.etherscan.io/address/0x9a3E76Fbd5B4a14DffC5E32c76a8B19B6407b99A)_ |
 
---
 
## 🌊 O que é
 
**Maré Alta** é um app mobile construído sobre o protocolo **ImpactLedger** — um smart contract em Solidity que grava permanentemente ações de impacto ambiental na blockchain Ethereum.
 
O caso de uso inicial é a **ONG Missão Ambiental**, mas a arquitetura permite que qualquer coletivo use com sua própria identidade.
 
> "Uma caderneta digital impossível de falsificar."
 
---
 
## 🚨 O problema
 
Milhares de horas de voluntariado ambiental acontecem todos os dias no Brasil — mas esse trabalho não existe oficialmente. Registros em papel somem. Planilhas são alteradas. Não há prova verificável para editais, certificações ESG ou histórico profissional.
 
---
 
## ✅ A solução
 
| Componente | Função |
|---|---|
| 📸 Foto da ação | Prova de presença — técnica, sem validador humano |
| 📍 GPS + timestamp | Capturados automaticamente em background |
| ⛓️ Smart contract | Grava cada ação permanentemente na Ethereum |
| 🏅 Badges on-chain | 1 badge a cada 3h acumuladas — não transferíveis, não apagáveis |
 
**Qualquer tempo conta:** mesmo 1h entra no contador. Ao acumular 3h totais, o badge é emitido automaticamente pelo contrato.
 
---
 
## 📱 Telas do app
 
### Tela 1 — Perfil do voluntário
- Hero card com métricas lidas diretamente do contrato (ações, horas, badges)
- Barra de progresso animada para o próximo badge
- Badges conquistados + badges bloqueados visíveis
- Histórico de ações com status "acumulando" para registros abaixo de 3h
### Tela 2 — Registrar impacto
- Campo de foto, GPS e hora automáticos
- Descrição da ação e horas dedicadas
- Preview de badges calculados em tempo real
- Confirmação on-chain com hash da transação
### Tela 3 — Painel do coletivo (3 abas)
- **Impacto:** métricas globais + ranking anônimo por carteira
- **Iniciativas:** rede pública de coletivos com tags temáticas
- **Recompensas:** parceiros oferecem produtos/serviços em troca de badges
---
 
## ⛓️ Smart Contract
 
**Arquivo:** [`/contracts/MareAltaImpactLedger.sol`](./contracts/MareAltaImpactLedger.sol)  
**Rede:** Ethereum Sepolia Testnet  
**Compilador:** Solidity ^0.8.20
 
### Funções principais
 
```solidity
// Registra um novo voluntário (somente admin)
function registrarMembro(address carteira, string calldata nome) external
 
// Grava uma ação de impacto + recalcula badges acumulados (somente admin)
function registrarImpacto(address carteira, string calldata descricao, uint256 horas) external
 
// Consulta dados on-chain de um membro (gratuito, qualquer pessoa)
function consultarMembro(address carteira) external view returns (...)
```
 
### Regra de badges
 
```
badges = totalHoras / 3   // divisão inteira
 
Exemplos:
1h + 1h + 1h = totalHoras=3 → badges=1
6h em uma ação             → badges=2
7h acumuladas              → badges=2, 1h no contador aguardando
```
 
### Eventos on-chain
 
```solidity
event MembroRegistrado(address indexed carteira, string nome)
event ImpactoRegistrado(address indexed carteira, string descricao, uint256 horas, uint256 totalHorasAcumuladas, uint256 badgesTotal)
```
 
---
 
## 🏛️ Arquitetura
 
```
┌─────────────────────┐     ┌──────────────────────────────┐     ┌─────────────────┐
│   App Mobile         │────▶│  MareAltaImpactLedger.sol    │────▶│  Ethereum        │
│   (Frontend)         │     │  (Smart Contract Solidity)   │     │  Sepolia Testnet │
│                      │     │                              │     │                  │
│  • Foto + GPS + hora │     │  • registrarMembro()         │     │  • Imutável      │
│  • Perfil on-chain   │     │  • registrarImpacto()        │     │  • Auditável     │
│  • Painel coletivo   │     │  • consultarMembro()         │     │  • Público       │
│  • Recompensas       │     │  • badges = totalHoras / 3   │     │  • Permanente    │
└─────────────────────┘     └──────────────────────────────┘     └─────────────────┘
```
 
---
 
## 🎖️ Badges — reputação Soulbound
 
| Badge | Conquista quando... |
|---|---|
| 🌳 Guardião da Terra | Mutirão, plantio ou limpeza de vegetação |
| ♻️ Agente Verde | Reciclagem, compostagem ou educação ambiental |
| 💧 Protetor das Águas | Limpeza de rios, praias ou corpos d'água |
| 🌱 Semeador | Reflorestamento e produção de mudas |
| ⭐ Liderança | Após 15 ações registradas |
 
Badges são **Soulbound** (inspirados em ERC-5114): vinculados à carteira que os gerou, não transferíveis, não apagáveis. Representam a história real de quem agiu.
 
---
 
## 🎯 Diferenciais de design
 
- **Sem validador central** — prova é foto + GPS + timestamp, não aprovação humana
- **Privacidade por padrão** — nomes nunca aparecem publicamente, apenas carteiras encurtadas
- **Colaborativo, não competitivo** — ranking existe mas só você sabe sua posição
- **Qualquer tempo conta** — horas se acumulam; nenhuma ação é pequena demais
- **Multi-coletivo** — qualquer ONG pode usar o protocolo com sua própria identidade
---
 
## 📁 Estrutura do repositório
 
```
mare-alta-impactledger/
├── contracts/
│   └── MareAltaImpactLedger.sol   # Smart contract principal
├── frontend/
│   └── index.html                 # Interface do app
├── slides_marealta.pdf            # Apresentação do projeto
└── README.md
```
 
---
 
## 🚀 Como testar o contrato
 
1. Abrir [remix.ethereum.org](https://remix.ethereum.org)
2. Criar arquivo `MareAltaImpactLedger.sol` e colar o código
3. Compilar com Solidity ^0.8.20
4. Em "Deploy & Run" → selecionar **Injected Provider (MetaMask)** → rede **Sepolia**
5. Clicar em **Deploy**
6. Testar:
   - `registrarMembro("0xSeuEndereço", "Carol Lubalu")`
   - `registrarImpacto("0xSeuEndereço", "Reflorestamento", 3)`
   - `consultarMembro("0xSeuEndereço")` — retorna dados on-chain
---
 
## 👩‍💻 Autora
 
**Caroline Rodrigues da Silva e Lopes**  
Residência TIC19 — Trilha 2 - Desafio 3 Blockchain + Smart Contracts  
HackWeb · São Paulo · 2026
 
---
 
*Maré Alta — porque cada ação conta. Para sempre.*