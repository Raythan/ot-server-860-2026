# Manual – Loja in-game (Shop no cliente)

Este manual explica como a loja in-game funciona e como configurar itens e preços para validação e testes.

---

## 1. Visão geral

- **Cliente (OtClient v8):** O módulo `game_shop` envia e recebe dados pelo **Extended Opcode 201** em JSON.
- **Servidor:** O creature event `ExtendedOpcode` (script `extendedopcode_shop.lua`) trata o opcode 201, lê as tabelas `z_shop_category` e `z_shop_offer`, usa **premium points** da conta (`accounts.premium_points`) como moeda e registra compras em `z_shop_history_item`.

Fluxo resumido:

1. Jogador abre a Shop no cliente (botão Shop).
2. Cliente envia `action: "init"` → servidor devolve categorias, ofertas e saldo de pontos.
3. Jogador escolhe oferta e confirma compra → cliente envia `action: "buy"` com `data.id` = id da oferta.
4. Servidor desconta os pontos, entrega o item (ou serviço) e envia mensagem de sucesso ou erro.
5. Histórico: cliente envia `action: "history"` → servidor devolve últimas compras da conta.

---

## 2. Requisitos

- **Cliente:** Extended Opcode habilitado (em `modules/game_features/features.lua` já está `GameExtendedOpcode` ativo).
- **Servidor:** Conexão com OtClient (o servidor só registra o evento ExtendedOpcode para clientes OtClient).
- **Banco de dados:**
  - Tabela `accounts` com coluna `premium_points` (INT, padrão 0).
  - Tabelas `z_shop_category`, `z_shop_offer` e `z_shop_history_item` (estrutura já usada pelo projeto; se faltar algo, use a migration em `data/migrations/001_ingame_shop.sql`).

---

## 3. Configurar categorias e ofertas no banco

### 3.1 Categorias (`z_shop_category`)

| Coluna    | Tipo         | Uso |
|-----------|--------------|-----|
| `id`      | int, PK      | Id da categoria (auto). |
| `name`    | varchar(50)  | Nome exibido na aba da loja (ex: "Items", "Premium"). |
| `desc`    | varchar(255)| Descrição (opcional no cliente atual). |
| `button`  | varchar(50) | Nome do botão/imagem (ex: `_sbutton_getextraservice.gif`). Pode ser vazio. |
| `hide`    | int, default 0 | 0 = visível, 1 = oculta (não aparece na loja). |

Exemplo:

```sql
INSERT INTO `z_shop_category` (`name`, `desc`, `button`, `hide`) VALUES
('Items', 'Compre itens com pontos premium.', '_sbutton_getextraservice.gif', 0),
('Premium', 'Dias de VIP.', '_sbutton_get_vip_days.gif', 0);
```

### 3.2 Ofertas (`z_shop_offer`)

| Coluna             | Tipo          | Uso |
|--------------------|---------------|-----|
| `id`               | int, PK       | Id da oferta (auto). O cliente envia este `id` ao comprar. |
| `category`         | int           | Id da categoria (`z_shop_category.id`). |
| `coins`            | int           | Preço em **premium points**. |
| `price`            | varchar(50)   | Preço em texto (ex: para site); pode ser vazio. |
| `itemid`           | int           | Item ID (ex: 2160 = gold). 0 se for serviço (outfit, premium, etc.). |
| `count`            | int           | Quantidade do item (padrão 1). |
| `offer_name`       | varchar(255)  | Nome da oferta na loja. |
| `offer_description` | text        | Descrição exibida no cliente. |
| `offer_type`       | varchar(255)  | Ex: `'items'`, `'outfits'`, `'premium'`. Hoje a entrega automática no servidor está feita para `itemid` > 0. |
| `offer_date`       | int           | Data (timestamp Unix); pode usar `UNIX_TIMESTAMP()`. |
| `default_image`    | varchar(50)   | Nome da imagem (opcional). |
| `hide`             | int, default 0| 0 = visível, 1 = oculta. |

Exemplos de ofertas para **testar**:

```sql
-- Categoria "Items" com id = 5 (ajuste o category se o seu id for outro)
INSERT INTO `z_shop_offer` (`category`, `coins`, `price`, `itemid`, `count`, `offer_type`, `offer_description`, `offer_name`, `offer_date`, `default_image`, `hide`) VALUES
(5, 3, '', 2160, 100, 'items', '100 gold coins.', '100 Gold Coins', UNIX_TIMESTAMP(), '', 0),
(5, 10, '', 2148, 50, 'items', '50 small health potions.', '50 Small Health Potions', UNIX_TIMESTAMP(), '', 0),
(5, 5, '', 2472, 1, 'items', '1 pair of soft boots.', 'Soft Boots', UNIX_TIMESTAMP(), '', 0);
```

---

## 4. Premium points (moeda da loja)

- Saldo da loja = **`accounts.premium_points`** (conta do personagem logado).
- Para **dar pontos** a uma conta (teste ou recompensa):

```sql
UPDATE `accounts` SET `premium_points` = `premium_points` + 100 WHERE `id` = <account_id>;
```

- Para saber o `account_id`: use o id da conta no login (ou consulte pela tabela `players`: `SELECT account_id FROM players WHERE name = 'NomeDoPersonagem';`).

---

## 5. Como validar e testar

1. **Migration (se precisar)**  
   - Execute uma vez o conteúdo de `data/migrations/001_ingame_shop.sql` (ignorar erros de coluna/tabela já existente).

2. **Categorias e ofertas**  
   - Garanta que existem linhas em `z_shop_category` com `hide = 0`.  
   - Garanta ofertas em `z_shop_offer` com `hide = 0`, `category` igual a um `id` de categoria válida e, para itens, `itemid` > 0 e `count` >= 1.

3. **Pontos na conta**  
   - Atualize `accounts.premium_points` para a conta que vai testar (ex.: +100).

4. **Cliente**  
   - Use o executável que carrega o módulo `game_shop` e com **GameExtendedOpcode** habilitado (já configurado em `game_features`).

5. **No jogo**  
   - Abra a janela da Shop (botão Shop).  
   - Deve carregar categorias e ofertas e exibir “Points: N”.  
   - Compre uma oferta de item (ex.: 100 gold por 3 pontos): deve descontar pontos, enviar mensagem de sucesso e o item ir para o inventário.  
   - Abra “Transaction history”: deve listar a compra.

6. **Erros comuns**  
   - “You do not have enough premium points”: aumentar `premium_points` na conta.  
   - “Please make sure you have free capacity…”: inventário/capacidade cheios.  
   - Loja não abre ou não carrega: conferir se o cliente é OtClient e se Extended Opcode está habilitado; no servidor, conferir se o creature event `ExtendedOpcode` está registrado em `creaturescripts.xml` e se o script `extendedopcode_shop.lua` e a lib `shop_client.lua` estão carregados.

---

## 6. Arquivos envolvidos

| Onde        | Arquivo | Função |
|------------|---------|--------|
| Cliente    | `modules/game_shop/shop.lua` | Envia init/history/buy e exibe categorias, ofertas e pontos. |
| Cliente    | `modules/game_features/features.lua` | Habilita `GameExtendedOpcode`. |
| Servidor   | `data/lib/core/shop_client.lua` | Lê DB (categorias, ofertas, pontos), compra e histórico. |
| Servidor   | `data/creaturescripts/scripts/others/extendedopcode_shop.lua` | Trata opcode 201 e chama a lógica da loja. |
| Servidor   | `data/creaturescripts/creaturescripts.xml` | Registra o event `ExtendedOpcode` (type extendedopcode). |
| Servidor   | `data/lib/core/core.lua` | Carrega `shop_client.lua`. |
| Banco      | `accounts.premium_points`, `z_shop_category`, `z_shop_offer`, `z_shop_history_item` | Dados da loja. |

---

## 7. Resumo rápido para configurar itens e preços

1. Inserir/ajustar categorias em `z_shop_category` (`hide = 0` para aparecer).  
2. Inserir ofertas em `z_shop_offer`: `category` = id da categoria, `coins` = preço em pontos, `itemid` = id do item, `count` = quantidade, `offer_name` e `offer_description` para o texto na loja, `hide = 0`.  
3. Dar pontos à conta: `UPDATE accounts SET premium_points = premium_points + N WHERE id = ?`.  
4. Testar no cliente: abrir Shop, comprar e ver histórico.

Com isso a estrutura esperada pelo cliente é atendida e você pode validar e testar a loja in-game.
