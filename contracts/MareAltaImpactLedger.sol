// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title  MareAltaImpactLedger
 * @author Caroline Rodrigues da Silva e Lopes — HackWeb · Residência TIC19 · Desafio 3
 * @notice Protocolo de registro auditável de impacto ambiental em blockchain.
 *
 * Conceitos-chave para avaliadores:
 * ─────────────────────────────────
 * • Imutabilidade   → após gravado, nenhum dado pode ser alterado ou apagado
 * • Gas             → toda escrita na EVM custa Ether; leituras (view) são gratuitas
 * • Eventos         → logs permanentes indexáveis fora da chain (The Graph, Etherscan)
 * • Soulbound       → badge vinculado ao address; não é token transferível,
 *                     é um uint que representa reputação não-alienável
 *
 * Regra de badges:
 * ─────────────────
 * 1 badge a cada 3 horas ACUMULADAS.
 * Qualquer quantidade de horas pode ser registrada — mesmo 1h entra no contador.
 * Ex: 1h + 1h + 1h = totalHoras=3 → badges=1
 *     3h em uma ação   = totalHoras=3 → badges=1
 *     6h em uma ação   = totalHoras=6 → badges=2
 */
contract MareAltaImpactLedger {

    // ─────────────────────────────────────────────
    // ESTADO
    // ─────────────────────────────────────────────

    address public admin;
    // admin é quem fez o deploy — representa a organização validadora (ONG Missão Ambiental)

    struct Membro {
        string  nome;
        uint256 totalAcoes;   // quantas vezes registrarImpacto foi chamado para este endereço
        uint256 totalHoras;   // soma acumulada de todas as horas registradas
        uint256 badges;       // calculado como totalHoras / 3 — atualizado a cada registro
        bool    existe;       // guarda para evitar re-registro acidental
    }

    mapping(address => Membro) private membros;
    // mapping = "dicionário" da EVM: endereço → dados do membro

    // ─────────────────────────────────────────────
    // EVENTOS
    // ─────────────────────────────────────────────

    event MembroRegistrado(address indexed carteira, string nome);
    event ImpactoRegistrado(
        address indexed carteira,
        string  descricao,
        uint256 horas,
        uint256 totalHorasAcumuladas,
        uint256 badgesTotal
    );

    // ─────────────────────────────────────────────
    // MODIFICADORES
    // ─────────────────────────────────────────────

    modifier somenteAdmin() {
        require(msg.sender == admin, "Somente o admin pode executar esta acao");
        _;
    }

    modifier membroExiste(address carteira) {
        require(membros[carteira].existe, "Membro nao registrado");
        _;
    }

    // ─────────────────────────────────────────────
    // CONSTRUTOR
    // ─────────────────────────────────────────────

    constructor() {
        admin = msg.sender;
    }

    // ─────────────────────────────────────────────
    // FUNÇÕES DE ESCRITA (custam Gas)
    // ─────────────────────────────────────────────

    /**
     * @notice Registra um novo membro na plataforma.
     * @param  carteira Endereço Ethereum do voluntário
     * @param  nome     Nome ou apelido do voluntário (gravado on-chain)
     */
    function registrarMembro(address carteira, string calldata nome) external somenteAdmin {
        require(!membros[carteira].existe, "Membro ja registrado");
        require(bytes(nome).length > 0, "Nome nao pode ser vazio");

        membros[carteira] = Membro({
            nome:       nome,
            totalAcoes: 0,
            totalHoras: 0,
            badges:     0,
            existe:     true
        });

        emit MembroRegistrado(carteira, nome);
    }

    /**
     * @notice Registra uma ação de impacto ambiental para um membro.
     * @dev    badges = totalHoras / 3  (divisão inteira acumulada)
     * @param  carteira  Endereço do voluntário
     * @param  descricao Descrição da ação (ex: "Reflorestamento")
     * @param  horas     Horas dedicadas nesta ação (>= 1)
     */
    function registrarImpacto(
        address carteira,
        string calldata descricao,
        uint256 horas
    ) external somenteAdmin membroExiste(carteira) {
        require(horas >= 1, "Minimo de 1 hora por registro");
        require(bytes(descricao).length > 0, "Descricao nao pode ser vazia");

        Membro storage m = membros[carteira];

        m.totalAcoes  += 1;
        m.totalHoras  += horas;
        m.badges       = m.totalHoras / 3;
        // Divisão inteira: 7h → 2 badges (resto 1h fica acumulado para o próximo)

        emit ImpactoRegistrado(
            carteira,
            descricao,
            horas,
            m.totalHoras,
            m.badges
        );
    }

    // ─────────────────────────────────────────────
    // FUNÇÕES DE LEITURA (gratuitas — não custam Gas)
    // ─────────────────────────────────────────────

    /**
     * @notice Consulta os dados on-chain de um membro.
     * @param  carteira Endereço do voluntário
     */
    function consultarMembro(address carteira)
        external
        view
        membroExiste(carteira)
        returns (
            string  memory nome,
            uint256 totalAcoes,
            uint256 totalHoras,
            uint256 badges
        )
    {
        Membro storage m = membros[carteira];
        return (m.nome, m.totalAcoes, m.totalHoras, m.badges);
    }

    /**
     * @notice Verifica se um endereço é membro registrado.
     */
    function ehMembro(address carteira) external view returns (bool) {
        return membros[carteira].existe;
    }
}