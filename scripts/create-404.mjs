import { promises as fs } from "node:fs";
import { resolve } from "node:path";

const distDir = resolve("dist");
const indexPath = resolve(distDir, "index.html");
const fallbackPath = resolve(distDir, "404.html");

async function createFallback() {
  try {
    const html = await fs.readFile(indexPath, "utf8");
    await fs.writeFile(fallbackPath, html);
    console.log("Created dist/404.html for GitHub Pages fallback.");
  } catch (error) {
    console.error("Unable to create 404.html fallback:", error);
    process.exitCode = 1;
  }
}

createFallback();
