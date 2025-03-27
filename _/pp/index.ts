// index.ts
import puppeteer from 'puppeteer';

// Configuration
const GITHUB_REPO_URL = 'https://github.com/microsoft/TypeScript-Handbook'; // Replace with your desired repo URL
const OUTPUT_ZIP_FILE = 'typescript-handbook.zip'; // Replace with your desired filename

async function downloadRepoAsZip(repoUrl: string, outputZipFile: string): Promise<void> {
    console.info ('Downloading repo as zip file...');
  try {
    const browser = await puppeteer.launch({
        executablePath: '/usr/bin/google-chrome-stable',
    }); // Corrected: removed 'browser' option

    const page = await browser.newPage();

    // Navigate to the GitHub repo URL
    await page.goto(repoUrl);
    await browser.close();

  } catch (error) {
    console.error('An error occurred:', error);
  }
}

// Run the function
downloadRepoAsZip(GITHUB_REPO_URL, OUTPUT_ZIP_FILE);