const fs = require('fs').promises;
const path = require('path');
const https = require('https');
const unzipper = require('unzipper'); // Make sure to install this: npm install unzipper
const { pipeline } = require('stream');
const { promisify } = require('util');

const pipe = promisify(pipeline);

// Configuration - Customize these!
const plugins = [
    { name: 'tokyonight.nvim', repo: 'folke/tokyonight.nvim' },
    { name: 'nvim-treesitter', repo: 'nvim-treesitter/nvim-treesitter' },
    // Add more plugins here
];
const lazyDir = path.join(process.env.HOME || process.env.USERPROFILE, '.local', 'share', 'nvim', 'lazy');
const initLuaPath = path.join(process.env.HOME || process.env.USERPROFILE, '.config', 'nvim', 'init.lua'); // Adjust if your init.lua is elsewhere

async function downloadAndExtract(plugin) {
    const zipUrl = `https://github.com/${plugin.repo}/archive/refs/heads/master.zip`; // Or use "main" instead of "master" if that's the default branch
    const pluginDir = path.join(lazyDir, plugin.name);

    console.log(`Downloading ${plugin.name} from ${zipUrl}`);

    try {
        await fs.mkdir(lazyDir, { recursive: true }); // Ensure lazyDir exists
        await fs.rm(pluginDir, { recursive: true, force: true }); // Remove existing plugin
        await fs.mkdir(pluginDir, { recursive: true }); // Recreate plugin dir

        const response = await new Promise((resolve, reject) => {
            https.get(zipUrl, (res) => {
                if (res.statusCode >= 400) {
                    reject(new Error(`Failed to download ${plugin.name}. Status code: ${res.statusCode}`));
                } else {
                    resolve(res);
                }
            }).on('error', (err) => {
                reject(err);
            });
        });

        console.log(`Extracting ${plugin.name} to ${pluginDir}`);

        // Use unzipper directly with streams
        await pipe(
            response,
            unzipper.Extract({ path: pluginDir })
        );

        // Rename the extracted directory (e.g., folke-tokyonight.nvim-master -> .)
        const extractedDirName = (await fs.readdir(pluginDir))[0]; // Assumes only one directory inside the zip
        const extractedDirPath = path.join(pluginDir, extractedDirName);

        if (extractedDirName) {
            const files = await fs.readdir(extractedDirPath)
            for (const file of files) {
                await fs.rename(path.join(extractedDirPath, file), path.join(pluginDir, file))
            }
            await fs.rmdir(extractedDirPath, { recursive: true })

            console.log(`Extracted and moved files to ${pluginDir}`);
        } else {
            console.warn(`No directory found inside the zip for ${plugin.name}.  Check the zip file contents.`);
        }


    } catch (error) {
        console.error(`Error processing ${plugin.name}:`, error);
    }
}

async function updateInitLua(plugins) {
    try {
        let initLuaContent = await fs.readFile(initLuaPath, 'utf8');
        let lazyRequireBlock = "";

        for (const plugin of plugins) {
            lazyRequireBlock += `\n  require('${plugin.name}')`;
        }

        // Find or create the lazy.setup block
        const lazySetupPattern = /lazy\.setup\(\{(.|\n)*?\}\)/g;
        const lazySetupMatch = initLuaContent.match(lazySetupPattern);

        if (lazySetupMatch) {
            // Append new plugins to the existing block.
            initLuaContent = initLuaContent.replace(lazySetupPattern, (match) => {
                // Find the closing bracket for the require block and add the new plugins there.
                const closingCurlyIndex = match.lastIndexOf("}");
                if (closingCurlyIndex !== -1) {
                    const insertionPoint = closingCurlyIndex;
                    const newMatch = match.slice(0, insertionPoint) + lazyRequireBlock + match.slice(insertionPoint);
                    return newMatch;
                }
                return match; // If somehow the closing bracket isn't found, leave the original match unchanged.
            });
        } else {
            // Create a new lazy.setup block if it doesn't exist.
            lazyRequireBlock = `\n  { ${lazyRequireBlock} \n  }`
            const newLazySetupBlock = `\nlazy.setup({${lazyRequireBlock}\n})\n`
            initLuaContent += newLazySetupBlock
        }

        await fs.writeFile(initLuaPath, initLuaContent, 'utf8');
        console.log(`Updated ${initLuaPath} with plugin references.`);
    } catch (error) {
        console.error(`Error updating ${initLuaPath}:`, error);
    }
}

async function main() {
    for (const plugin of plugins) {
        await downloadAndExtract(plugin);
    }
    await updateInitLua(plugins);
}

main().catch((err) => {
    console.error('An error occurred:', err);
});