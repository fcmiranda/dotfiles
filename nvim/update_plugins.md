```typescript
import * as fs from 'node:fs';
import * as path from 'node:path';
import * as https from 'node:https';
import * as unzipper from 'unzipper';
import { promisify } from 'node:util';
import { pipeline } from 'node:stream';
const streamPipeline = promisify(pipeline);

// Configurações
const LAZYVIM_CONFIG_DIR: string = path.join(process.env.HOME || '', '.config', 'nvim');
const LOCAL_PLUGINS_DIR: string = path.join(LAZYVIM_CONFIG_DIR, 'local_plugins');
const LAZY_LUA_PATH: string = path.join(LAZYVIM_CONFIG_DIR, 'lua', 'config', 'lazy.lua');
const GITHUB_API_URL: string = 'https://api.github.com/repos/{owner}/{repo}/releases/latest';

interface PluginConfig {
    [key: string]: any;  // Permite propriedades arbitrárias
    dir?: string;      // 'dir' é opcional
    name?: string;    // 'name' também é opcional
}

async function getPluginConfig(): Promise<{ [ownerRepo: string]: PluginConfig }> {
    try {
        const content: string = fs.readFileSync(LAZY_LUA_PATH, 'utf-8');

        const startIndex: number = content.indexOf("return {") + "return {".length;
        const endIndex: number = content.lastIndexOf("}");
        const pluginListStr: string = content.substring(startIndex, endIndex).trim();

        // Avalia a string como JavaScript (cuidado com a segurança)
        //console.log(pluginListStr);
        const pluginList: any[] = eval(`[${pluginListStr}]`); // CUIDADO: eval()

        const pluginConfigs: { [ownerRepo: string]: PluginConfig } = {};

        for (const plugin of pluginList) {
            if (typeof plugin === 'string') {
                const ownerRepo: string = plugin;
                pluginConfigs[ownerRepo] = {};
            } else if (typeof plugin === 'object') {
                if (plugin.dir) {
                    const ownerRepo: string = plugin.name || Object.keys(plugin)[0];
                    pluginConfigs[ownerRepo] = plugin;
                } else {
                    const ownerRepo: string = Object.keys(plugin)[0];
                    pluginConfigs[ownerRepo] = plugin;
                }
            }
        }

        return pluginConfigs;
    } catch (error) {
        console.error(`Erro ao ler/parsear lazy.lua: ${error}`);
        return {};
    }
}

async function getLatestRelease(owner: string, repo: string): Promise<string | null> {
    const url: string = GITHUB_API_URL.replace('{owner}', owner).replace('{repo}', repo);

    return new Promise((resolve, reject) => {
        https.get(url, { headers: { 'User-Agent': 'Node.js' } }, (res) => {
            let data: string = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                try {
                    const jsonData: any = JSON.parse(data);
                    resolve(jsonData.tag_name);
                } catch (error) {
                    reject(`Erro ao parsear JSON: ${error}`);
                }
            });
        }).on('error', (error) => {
            reject(`Erro ao obter a última release: ${error}`);
        });
    });
}

async function getLocalVersion(pluginDir: string): Promise<string | null> {
    const gitDir: string = path.join(pluginDir, '.git');
    if (!fs.existsSync(gitDir) || !fs.statSync(gitDir).isDirectory()) {
        return null;
    }

    const tagsDir: string = path.join(gitDir, 'refs', 'tags');
    if (!fs.existsSync(tagsDir) || !fs.statSync(tagsDir).isDirectory()) {
        return null;
    }

    const tags: string[] = fs.readdirSync(tagsDir).sort();
    if (tags.length > 0) {
        return tags[tags.length - 1];
    } else {
        return null;
    }
}

async function downloadAndExtract(owner: string, repo: string, tag: string, pluginDir: string): Promise<void> {
    const zipUrl: string = `https://github.com/${owner}/${repo}/archive/refs/tags/${tag}.zip`;
    const tempDir: string = path.join(LOCAL_PLUGINS_DIR, `${repo}_temp`);

    try {
        // Cria o diretório temporário
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }

        const zipFilePath: string = path.join(tempDir, `${repo}-${tag}.zip`);

        // Download do zip
        const fileStream: fs.WriteStream = fs.createWriteStream(zipFilePath);

        await new Promise<void>((resolve, reject) => {
            https.get(zipUrl, (res) => {
                res.pipe(fileStream);
                res.on('end', resolve);
                res.on('error', reject);
            }).on('error', reject);
        });

        // Extração do zip
        const extractDir: string = path.join(tempDir, `${repo}-${tag}`); // Diretório onde o zip será extraído
        await fs.promises.mkdir(extractDir, { recursive: true }); // Cria o diretório de extração

        const zip = fs.createReadStream(zipFilePath).pipe(unzipper.Extract({ path: extractDir }));

        await new Promise<void>((resolve, reject) => {
            zip.on('close', resolve);
            zip.on('error', reject);
        });


        const sourceDir: string = path.join(tempDir, `${repo}-${tag}`);
        const items: string[] = fs.readdirSync(sourceDir);

        for (const item of items) {
            const s: string = path.join(sourceDir, item);
            const d: string = path.join(pluginDir, item);

            if (fs.existsSync(d)) {
                if (fs.statSync(d).isFile()) {
                    fs.unlinkSync(d);
                } else {
                    fs.rmdirSync(d, { recursive: true });
                }
            }
            fs.renameSync(s, d);
        }

        // Remove o diretório temporário
        fs.rmdirSync(tempDir, { recursive: true });
        console.log(`Plugin ${owner}/${repo} atualizado para a versão ${tag}`);
    } catch (error) {
        console.error(`Erro ao baixar/extrair ${owner}/${repo}: ${error}`);
    }
}

async function updatePlugin(ownerRepo: string, pluginConfig: PluginConfig): Promise<void> {
    const [owner, repo] = ownerRepo.split('/');
    const pluginName: string = repo;
    let pluginDir: string;

    if (pluginConfig.dir) {
        pluginDir = pluginConfig.dir;
    } else {
        pluginDir = path.join(LOCAL_PLUGINS_DIR, owner, pluginName);
    }

    if (!fs.existsSync(pluginDir)) {
        fs.mkdirSync(pluginDir, { recursive: true });
    }

    const localVersion: string | null = await getLocalVersion(pluginDir);
    const latestVersion: string | null = await getLatestRelease(owner, repo);

    if (latestVersion && (localVersion !== latestVersion)) {
        console.log(`Atualizando ${owner}/${repo} de ${localVersion} para ${latestVersion}`);
        await downloadAndExtract(owner, repo, latestVersion, pluginDir);
    } else {
        console.log(`Plugin ${owner}/${repo} já está na versão mais recente.`);
    }
}

async function main(): Promise<void> {
    const pluginConfigs: { [ownerRepo: string]: PluginConfig } = await getPluginConfig();

    for (const ownerRepo in pluginConfigs) {
        await updatePlugin(ownerRepo, pluginConfigs[ownerRepo]);
    }
}

main();
```

**Como usar:**

1.  **Instale o Node.js e o TypeScript:** Certifique-se de que o Node.js e o TypeScript estejam instalados no seu sistema.
2.  **Crie um arquivo `tsconfig.json`:** Crie um arquivo `tsconfig.json` na raiz do seu projeto com as seguintes configurações básicas:

    ```json
    {
      "compilerOptions": {
        "target": "es2020",
        "module": "commonjs",
        "moduleResolution": "node",
        "esModuleInterop": true,
        "forceConsistentCasingInFileNames": true,
        "strict": true,
        "outDir": "dist"
      },
      "include": ["src/**/*"],
      "exclude": ["node_modules"]
    }
    ```

3.  **Crie um diretório `src`:** Coloque o código TypeScript dentro de um diretório `src`.
4.  **Salve o script:** Salve o script como `src/update_plugins.ts` (ou outro nome que preferir dentro do diretório `src`).
5.  **Instale as dependências:**
    ```bash
    npm install @types/node unzipper
    ```

6.  **Compile o código TypeScript:**
    ```bash
    tsc
    ```

    Isso criará um diretório `dist` com o código JavaScript compilado.

7.  **Ajuste as configurações:**
    *   `LAZYVIM_CONFIG_DIR`: Verifique se este caminho está correto para a sua configuração do LazyVim.
    *   `LOCAL_PLUGINS_DIR`: Verifique se este caminho está correto.
    *   `LAZY_LUA_PATH`: Ajuste para o caminho correto do seu arquivo `lazy.lua`.

8.  **Execute o script:**
    ```bash
    node dist/update_plugins.js
    ```

9.  **Integre com o LazyVim:**
    *   Você pode adicionar um comando no Neovim para executar este script. Por exemplo, adicione uma linha no seu `init.lua` ou `lazy.lua`:

        ```lua
        vim.api.nvim_create_user_command('UpdatePlugins', function()
          vim.fn.system('node ' .. os.path.expanduser("~/.config/nvim/dist/update_plugins.js"))
        end, {})
        ```

    *   Agora você pode executar `:UpdatePlugins` no Neovim para atualizar os plugins.

**Mudanças e Explicações:**

*   **Tipagem Forte:** O código agora usa tipagem forte com TypeScript, o que ajuda a prevenir erros e torna o código mais fácil de entender.
*   **Interfaces:** A interface `PluginConfig` define a estrutura esperada para as configurações dos plugins.
*   **`tsconfig.json`:** O arquivo `tsconfig.json` configura o compilador TypeScript.
*   **Compilação:** O código TypeScript precisa ser compilado para JavaScript antes de ser executado com Node.js.
*    **imports:**  mudei os imports para node 16+

**Considerações:**

*   **`eval()`: SEGURANÇA** A análise do arquivo `lazy.lua` ainda usa `eval()`, que é perigoso. Considere usar uma biblioteca de parsing Lua para Node.js se você estiver preocupado com a segurança.
*   **Gerenciamento de Erros:** O código inclui algum tratamento de erros, mas você pode querer adicionar mais para torná-lo mais robusto.
*   **Módulos:** O código usa módulos do Node.js para lidar com tarefas como sistema de arquivos, requisições HTTP e manipulação de arquivos .zip.
*   **Assincronismo:** O código é assíncrono e usa `async/await` para facilitar o gerenciamento de operações assíncronas.

Este script deve funcionar da mesma forma que as versões em Python e JavaScript, mas com os benefícios da tipagem forte do TypeScript. Lembre-se de testá-lo cuidadosamente e adaptá-lo à sua configuração específica.
