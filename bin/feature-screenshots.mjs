import fs from "fs/promises";
import path from "path";
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";
import sharp from "sharp";

async function getScreenshotDirectory() {
  const { stdout } = await $`defaults read com.apple.screencapture location`;
  return stdout.trim() || `${process.env.HOME}/Desktop`; // Fallback to Desktop if not set
}

async function getLatestScreenshots(directory, count = 2) {
  const files = await fs.readdir(directory);
  const screenshots = files
    .filter((file) => file.endsWith(".png"))
    .map((file) => ({
      file,
      time: fs.statSync(path.join(directory, file)).mtime.getTime(),
    }))
    .sort((a, b) => b.time - a.time)
    .slice(0, count)
    .map((fileInfo) => path.join(directory, fileInfo.file));

  if (screenshots.length < count) {
    throw new Error(`Not enough screenshots found in ${directory}`);
  }

  return screenshots;
}

async function compareScreenshots(beforePath, afterPath, outputPath) {
  const beforeImage = PNG.sync.read(await fs.readFile(beforePath));
  const afterImage = PNG.sync.read(await fs.readFile(afterPath));

  const { width, height } = beforeImage;
  const diffImage = new PNG({ width, height });

  pixelmatch(beforeImage.data, afterImage.data, diffImage.data, width, height, {
    threshold: 0.1,
  });

  const diffPath = "diff.png";
  await fs.writeFile(diffPath, PNG.sync.write(diffImage));

  await sharp({
    create: {
      width: width * 3,
      height: height,
      channels: 4,
      background: { r: 255, g: 255, b: 255, alpha: 0 },
    },
  })
    .composite([
      { input: beforePath, left: 0, top: 0 },
      { input: afterPath, left: width, top: 0 },
      { input: diffPath, left: width * 2, top: 0 },
    ])
    .toFile(outputPath);
}

(async () => {
  try {
    const screenshotDir = await getScreenshotDirectory();
    console.log({
      screenshotDir,
    });
    const [beforePath, afterPath] = await getLatestScreenshots(screenshotDir);

    console.log(`Comparing screenshots: ${beforePath} and ${afterPath}`);

    await compareScreenshots(beforePath, afterPath, "output.png");
    console.log("Comparison image created successfully!");
  } catch (err) {
    console.error("Error creating comparison image:", err);
  }
})();
