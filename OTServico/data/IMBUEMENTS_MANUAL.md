# Manual de Configuração – Sistema de Imbuements

Este documento descreve como configurar o sistema de imbuements (encantamentos) no servidor através dos arquivos Lua e XML. O sistema segue as regras do Tibia em relação a **slots por item** (até 3) e **tipos de encantamento permitidos por categoria de item**.

---

## 1. Visão geral

- **Onde usar:** A janela de imbuement só pode ser aberta em **Protection Zone (PZ)**. Aplicar ou limpar encantamento também exige PZ.
- **Como abrir a interface:**
  - **No cliente:** botão "Imbue" no menu superior ou digitar **!imbue** no chat. Para um item específico: **!imbue &lt;itemId&gt;**.
  - **No jogo:** usar um **Imbuing Shrine** (item no chão) em PZ.

---

## 2. Arquivos principais

| Arquivo | Função |
|--------|--------|
| `data/lib/core/imbuements.lua` | Tabelas de itens imbuáveis, encantamentos por tipo de item, constantes e funções (ex.: `sendImbuementPanel`, `getImbuingSlotsForItem`). |
| `data/XML/imbuements.xml` | Definição de cada encantamento: nome, base (Basic/Intricate/Powerful), categoria, custo, itens, duração, etc. |
| `data/events/scripts/player.lua` | Regras de aplicação/limpeza (PZ, premium, quests) e efeitos em combate. |
| `data/actions/scripts/imbuement.lua` | Ação de usar o Imbuing Shrine. |
| `data/talkactions/scripts/imbue.lua` | Talkaction **!imbue** para abrir a janela. |

---

## 3. Configuração em Lua – `data/lib/core/imbuements.lua`

### 3.1 Constantes

- **`IMBUEMENT_SLOT`**  
  Base dos atributos customizados dos slots no item (slot 0, 1, 2). Não altere a menos que mude o uso de atributos no engine.

- **Constantes de diálogo**  
  `MESSAGEDIALOG_IMBUEMENT_*` e `MESSAGEDIALOG_CLEARING_CHARM_*`: usadas nas mensagens de erro/sucesso enviadas ao cliente.

### 3.2 Tabela `Imbuements_Weapons`

Define **quais itens são imbuáveis** e em qual **categoria** (tipo de equipamento). Cada categoria tem uma lista de **item IDs**:

```lua
Imbuements_Weapons = {
    ["armor"] = { 21692, 2500, ... },
    ["shield"] = { 34068, 2537, ... },
    ["boots"] = { 34062, 24742, ... },
    ["helmet"] = { ... },
    ["bow"] = { ... },
    ["crossbow"] = { ... },
    ["backpack"] = { ... },
    ["wand"] = { ... },
    ["rod"] = { ... },
    ["axe"] = { ... },
    ["club"] = { ... },
    ["sword"] = { ... },
    ["spellbooks"] = { ... },
    -- ... outras categorias
}
```

- **Adicionar um item imbuável:** inclua o **id** do item na lista da categoria correta (ex.: nova espada em `["sword"]`).
- **Novo tipo de equipamento:** crie uma nova chave (ex. `["novoTipo"]`) e uma lista de IDs. Depois é preciso registrar esse tipo em **`equipitems`** (quais encantamentos ele aceita).

Cada item dessas listas é tratado como tendo **até 3 slots** de imbuement (conforme Tibia).

### 3.3 Tabela `equipitems`

Define **quais encantamentos** podem ser aplicados em **quais categorias** de item:

```lua
equipitems = {
    ["lich shroud"]   = { "armor", "shield", "spellbooks", ... },
    ["reap"]          = { "axe", "club", "sword" },
    ["vampirism"]     = { "axe", "club", "sword", "wand", "rod", ... },
    ["void"]          = { "axe", "club", "sword", "wand", "rod", "helmet", ... },
    ["strike"]        = { "axe", "club", "sword", "bow", "crossbow", ... },
    ["slash"]         = { "sword", "helmet", "elemental_swords" },
    ["chop"]          = { "axe", "helmet", "elemental_axes" },
    ["bash"]          = { "club", "helmet", "elemental_clubs" },
    ["precision"]     = { "bow", "crossbow", "helmet" },
    ["blockade"]      = { "shield", "helmet", "spellbooks" },
    ["epiphany"]      = { "wand", "rod", "helmetmage", ... },
    ["featherweight"] = { "backpack" },
    ["swiftness"]     = { "boots" },
    -- ... dano elemental, proteções, etc.
}
```

- **Permitir um encantamento em um tipo de item:** adicione o nome da categoria (ex. `"sword"`) na lista do encantamento.
- **Remover encantamento de um tipo:** tire a categoria da lista.

Os nomes das chaves devem bater com os nomes usados no XML (ex.: `"lich shroud"`, `"hide dragon"`).

### 3.4 Tabela `enablingStorages`

Associa cada encantamento a uma **storage de quest** (ex.: Forgotten Knowledge). Só jogadores que tiverem essa storage preenchida podem usar o encantamento (nível Powerful pode depender disso):

```lua
enablingStorages = {
    ["lich shroud"]   = Storage.ForgottenKnowledge.LadyTenebrisKilled,
    ["strike"]        = Storage.ForgottenKnowledge.LastLoreKilled,
    ["featherweight"] = -1,  -- sempre liberado
    -- ...
}
```

- **Liberar encantamento sem quest:** use `-1`.
- **Exigir quest:** use a constante de storage correspondente (definida em `data/lib/core/player.lua` ou em scripts de quest).

---

## 4. Configuração em XML – `data/XML/imbuements.xml`

### 4.1 Bases (níveis)

```xml
<base id="1" name="Basic"    protection="10000" price="5000"   percent="90" removecost="15000" duration="72000" />
<base id="2" name="Intricate" protection="30000" price="25000"  percent="70" removecost="15000" duration="72000" />
<base id="3" name="Powerful"  protection="50000" price="100000" percent="50" removecost="15000" duration="72000" />
```

- **price:** custo em gold para aplicar.
- **protection:** custo extra (gold) ao usar “protection charm” (sucesso 100%).
- **percent:** chance de sucesso sem protection (0–100). No Tibia atual (Summer 2025+) costuma ser 100% e preço fixo; você pode deixar `percent="100"` e ajustar só os preços.
- **removecost:** custo para **limpar** o encantamento.
- **duration:** duração em **segundos** (72000 = 20 horas).

Valores em Tibia real (referência): Basic 7.500 gp, Intricate 60.000 gp, Powerful 250.000 gp; duração 20 h; limpeza com custo fixo.

### 4.2 Categorias

As `<category id="..." name="..."/>` agrupam encantamentos na interface (Elemental Damage, Life Leech, Mana Leech, Critical Hit, proteções, skills, capacity, etc.). O **id** é usado em Lua para não permitir dois encantamentos da mesma categoria no mesmo item.

### 4.3 Definir um encantamento

Exemplo:

```xml
<imbuement name="Void" base="1" category="2" iconid="49">
    <attribute key="description" value="Converts 3% of damage to MP with a chance of 100%." />
    <attribute key="effect" type="skill" value="manaleech" bonus="3" chance="100" />
    <attribute key="item" value="12448" count="25" />
</imbuement>
```

- **name:** nome exibido (deve bater com as chaves em `equipitems` em Lua, quando houver subtipo pode ter `subgroup` no nome).
- **base:** 1 = Basic, 2 = Intricate, 3 = Powerful.
- **category:** id da categoria (evita duplicata no mesmo item).
- **attribute key="item" value="itemId" count="N":** ingrediente obrigatório (pode ter vários).

Para **novo encantamento**:

1. Adicione as 3 entradas (base 1, 2 e 3) em `imbuements.xml`.
2. Em `imbuements.lua`, adicione uma entrada em **`equipitems`** (nome em minúsculo, lista de categorias de item) e em **`enablingStorages`** (storage ou `-1`).

---

## 5. Limites por item (Tibia)

- Cada item imbuável tem **até 3 slots**.
- **Não** é possível colocar o **mesmo tipo de encantamento** em mais de um slot do mesmo item.
- **Não** é possível aplicar encantamento de um elemento em item que já tem proteção fixa para esse elemento (ex.: terra em item com proteção terra).
- Slots e tipos permitidos por item são controlados por **`Imbuements_Weapons`** + **`equipitems`** em `imbuements.lua`.

---

## 6. Proteção de zona (PZ)

- **Abrir janela:** só em PZ (talkaction **!imbue** e action do shrine checam PZ).
- **Aplicar encantamento:** `Player:onApplyImbuement` verifica PZ.
- **Limpar encantamento:** `Player:clearImbuement` verifica PZ.

As checagens estão em `data/events/scripts/player.lua` e em `data/talkactions/scripts/imbue.lua` e `data/actions/scripts/imbuement.lua`.

---

## 7. Cliente (OTCv8)

- O botão **“Imbue”** no menu envia **!imbue** ao servidor; o servidor só abre a janela se o jogador estiver em PZ.
- A janela de imbuement é preenchida pelos dados enviados pelo servidor (pacote 0xEB). Se o cliente esperar outro formato de pacote, pode ser necessário ajustar `Player.sendImbuementPanel` em `data/lib/core/imbuements.lua` (estrutura do `NetworkMessage`).

### Pacotes Apply/Clear

Quando o jogador clica em **Aplicar** ou **Limpar** encantamento, o cliente envia um pacote ao servidor. O servidor precisa tratar esse pacote e chamar `Player:onApplyImbuement` ou `Player:clearImbuement`. Se a sua compilação do TFS não tiver esse handler em C++ (em `protocolgame.cpp`), será preciso implementá-lo e invocar o Lua correspondente. As funções Lua já existem em `data/events/scripts/player.lua`.

---

## 8. Resumo rápido

| Objetivo | Onde |
|----------|------|
| Permitir novo item ser imbuado | `imbuements.lua` → `Imbuements_Weapons` (categoria + id) |
| Permitir encantamento X em tipo de item Y | `imbuements.lua` → `equipitems` |
| Exigir quest para encantamento | `imbuements.lua` → `enablingStorages` |
| Alterar custo, duração, chance | `data/XML/imbuements.xml` (bases e atributos do imbuement) |
| Novos encantamentos | `imbuements.xml` + `equipitems` + `enablingStorages` |

Referência do sistema no Tibia: [Imbuements - Tibia Wiki](https://www.tibiawiki.com.br/wiki/Imbuements).
