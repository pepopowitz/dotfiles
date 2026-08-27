#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const LAYOUT_FILE =
  process.env.AEROSPACE_LAYOUT_FILE ||
  path.join(os.homedir(), '.aerospace/.aerospace.windows.json');
const AEROSPACE = execSync('brew --prefix', { encoding: 'utf8' }).trim() + '/bin/aerospace';
const WINDOW_FORMAT = '%{window-id}%{workspace}%{app-bundle-id}%{window-title}';

const VSCODE = 'com.microsoft.VSCode';
const EDGE = 'com.microsoft.edgemac';

// VS Code and Edge both join title segments with a spaced dash of some flavor.
const TITLE_SEPARATOR = /\s+[-–—]\s+/;

const dryRun = process.argv.includes('--dry-run');

function normalizeWindows(rawWindows) {
  return rawWindows.map((window) => ({
    windowId: window['window-id'],
    appBundleId: window['app-bundle-id'],
    windowTitle: window['window-title'],
    workspace: window['workspace'],
  }));
}

function readSavedLayout() {
  if (!fs.existsSync(LAYOUT_FILE)) return [];

  const contents = fs.readFileSync(LAYOUT_FILE, 'utf8').trim();
  if (contents.length === 0) return [];

  return normalizeWindows(JSON.parse(contents));
}

function readCurrentLayout() {
  const raw = execSync(
    `${AEROSPACE} list-windows --all --format "${WINDOW_FORMAT}" --json`,
    { encoding: 'utf8' }
  );

  return normalizeWindows(JSON.parse(raw));
}

// "steves-games — Untitled-1" -> "steves-games"
function repositoryName(title) {
  return title.split(TITLE_SEPARATOR)[0].trim();
}

// "Gmail - Microsoft Edge - Personal" -> "Personal"
function browserProfileName(title) {
  const segments = title.split(TITLE_SEPARATOR);
  return segments[segments.length - 1].trim();
}

function matchOnWindowId(window, savedLayout) {
  return savedLayout.find((saved) => saved.windowId === window.windowId);
}

function matchOnAppAndTitle(window, savedLayout) {
  return savedLayout.find(
    (saved) =>
      saved.appBundleId === window.appBundleId &&
      saved.windowTitle === window.windowTitle
  );
}

function matchOnRepositoryName(window, savedLayout) {
  if (window.appBundleId !== VSCODE) return undefined;

  const repository = repositoryName(window.windowTitle);
  return savedLayout.find(
    (saved) =>
      saved.appBundleId === VSCODE && repositoryName(saved.windowTitle) === repository
  );
}

// Several open windows can share a profile; they all land on the first saved
// window for that profile, which beats leaving them where they are.
function matchOnBrowserProfile(window, savedLayout) {
  if (window.appBundleId !== EDGE) return undefined;

  const profile = browserProfileName(window.windowTitle);
  return savedLayout.find(
    (saved) =>
      saved.appBundleId === EDGE && browserProfileName(saved.windowTitle) === profile
  );
}

function matchOnApp(window, savedLayout) {
  return savedLayout.find((saved) => saved.appBundleId === window.appBundleId);
}

// Order matters: most specific match wins.
const MATCH_STRATEGIES = [
  { name: 'window id', match: matchOnWindowId },
  { name: 'app + title', match: matchOnAppAndTitle },
  { name: 'repository name', match: matchOnRepositoryName },
  { name: 'browser profile', match: matchOnBrowserProfile },
  { name: 'app', match: matchOnApp },
];

function findBestMatch(window, savedLayout) {
  for (const strategy of MATCH_STRATEGIES) {
    const saved = strategy.match(window, savedLayout);
    if (saved) return { strategy: strategy.name, saved };
  }

  return undefined;
}

function moveWindowToWorkspace(windowId, workspace) {
  execSync(
    `${AEROSPACE} move-node-to-workspace --window-id ${windowId} ${JSON.stringify(workspace)} --fail-if-noop`,
    { stdio: 'ignore' }
  );
}

function describe(window) {
  return `${window.windowId} (${window.appBundleId} "${window.windowTitle}")`;
}

function restoreWindow(window, savedLayout) {
  const match = findBestMatch(window, savedLayout);

  if (!match) {
    console.log(`${'no match'.padEnd(16)} ${describe(window)}`);
    return;
  }

  const { workspace } = match.saved;
  const alreadyThere = workspace === window.workspace;

  console.log(
    `${match.strategy.padEnd(16)} ${describe(window)} -> ${workspace}${alreadyThere ? ' (no move needed)' : ''}`
  );

  if (!alreadyThere && !dryRun) moveWindowToWorkspace(window.windowId, workspace);
}

function restoreLayout() {
  const savedLayout = readSavedLayout();

  if (savedLayout.length === 0) {
    console.error('No saved layout found.');
    process.exit(1);
  }

  for (const window of readCurrentLayout()) {
    restoreWindow(window, savedLayout);
  }
}

restoreLayout();
