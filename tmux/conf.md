## Resumo do Arquivo de Configuração do Tmux

Este arquivo de configuração do tmux personaliza o comportamento do tmux com várias opções e atalhos de teclado. Aqui estão os principais destaques:

**Comandos Básicos**

* **Prefixo:** `C-Space` (Control + Barra de Espaço). O prefixo padrão `C-b` foi substituído por `C-Space`. Este prefixo é usado antes de todos os outros comandos do tmux.
* **Recarregar Configuração:** `C-Space r`. Recarrega o arquivo `~/.tmux.conf` e exibe uma mensagem de confirmação.

**Navegação de Sessão/Janela**

* **Alternar Sessão:** `C-Space Space`. Alterna para a última sessão usada.
* **Selecionar Sessão:** `C-Space s`. Abre o seletor de sessão, ordenado por tempo de atividade, permitindo escolher rapidamente entre as sessões. As sessões são exibidas de forma compacta (sem mostrar as janelas).
* **Selecionar Janela:**
    * `C-Space u`: Janela 1
    * `C-Space i`: Janela 2
    * `C-Space o`: Janela 3
    * `C-Space p`: Janela 4
* **Janela Anterior:** `C-Space m`

**Divisão e Navegação de Painel**

* **Split Vertical:** `C-Space |`
* **Split Horizontal:** `C-Space -`
* **Mover/Redimensionar Painel:** `C-Space` + `Seta` (Esquerda, Baixo, Cima, Direita). Redimensiona o painel ativo em 1 célula.
* **Maximizar Painel:** `C-Space M`. Alterna o painel ativo para ocupar a tela inteira.

**Modo de Cópia**

* **Entrar no Modo de Cópia:** `C-Space v`. Entra no modo de cópia para selecionar e copiar texto.
* **Sair do Modo de Cópia:** `Esc`
* **Selecionar Texto:** `v` (no modo de cópia)
* **Copiar Texto:** `y` (no modo de cópia)
* **Início da linha:** `g` (seguido de `h`)
* **Fim da linha:** `g` (seguido de `l`)
* **Não sair do modo de cópia ao arrastar com o mouse:** Comportamento padrão alterado.

**Comportamento do Painel e da Janela**

* **Sincronizar Painéis:** `C-Space Q`. Sincroniza a entrada em todos os painéis na janela atual.
* **Renumerar Janelas:** `set -g renumber-windows on`. Renumera as janelas automaticamente quando uma é fechada.
* **Índice Base da Janela:** `set -g base-index 1`. As janelas são numeradas a partir de 1 em vez de 0.
* **Desativar detach on destroy:** `set -g detach-on-destroy off`

**Aparência**

* **Tema:** Catppuccin (Mocha). Personaliza a barra de status e as cores do painel.
* **Borda do Painel:** Linhas simples.
* **Indicadores de Borda do Painel:** Cor.
* **Barra de Status:** Posicionada na parte superior da tela.

**Outras Configurações**

* **Histórico de Scrollback:** Aumentado para 10000 linhas.
* **Suporte ao Mouse:** Ativado para redimensionamento de painel, rolagem, etc.
* **Clipboard:** Sincronização com a área de transferência do sistema (`set -s set-clipboard on`).
* **Tempo de Escape:** Definido para 10ms para resposta mais rápida do Vim.
* **Eventos de Foco:** Ativados (`set-option -g focus-events on`).
* **Enviar comando para todos os painéis:**
    * `M-e`: Envia comando para todos os painéis da sessão atual.
    * `M-E`: Envia comando para todos os painéis de todas as sessões.

**Plugins**

* **tmux Plugin Manager (TPM):** Usado para instalar e gerenciar plugins.
* **vim-tmux-navigator:** Permite navegar perfeitamente entre os painéis do tmux e as janelas do Vim.
* **tmux-resurrect:** Persiste sessões do tmux após reiniciar o computador.
* **tmux-continuum:** Salva automaticamente as sessões do tmux a cada 5 minutos e as restaura na reinicialização.
