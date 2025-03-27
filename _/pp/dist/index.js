"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// index.ts
const puppeteer_1 = __importDefault(require("puppeteer"));
// Configuration
const GITHUB_REPO_URL = 'https://github.com/microsoft/TypeScript-Handbook'; // Replace with your desired repo URL
const OUTPUT_ZIP_FILE = 'typescript-handbook.zip'; // Replace with your desired filename
async function downloadRepoAsZip(repoUrl, outputZipFile) {
    console.info('Downloading repo as zip file...');
    try {
        const browser = await puppeteer_1.default.launch({
            executablePath: '/usr/bin/google-chrome-stable',
        }); // Corrected: removed 'browser' option
        const page = await browser.newPage();
        // Navigate to the GitHub repo URL
        await page.goto(repoUrl);
        await browser.close();
    }
    catch (error) {
        console.error('An error occurred:', error);
    }
}
// Run the function
downloadRepoAsZip(GITHUB_REPO_URL, OUTPUT_ZIP_FILE);
//# sourceMappingURL=index.js.map