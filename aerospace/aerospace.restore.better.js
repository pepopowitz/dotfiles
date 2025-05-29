#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const { execSync } = require('child_process');

function makeJSFriendly(layoutArray) {
  return layoutArray.map((window) => {
    return {
      windowId: window['window-id'],
      appBundleId: window['app-bundle-id'],
      windowTitle: window['window-title'],
      workspace: window['workspace'],
    };
  });
}

function getSavedLayout() {
  const layoutPath = '~/.aerospace/.aerospace.windows.json';
  const actualPath = layoutPath.replace(/^~/, os.homedir());

  const layoutContents = fs.readFileSync(actualPath, 'utf8');
  if (layoutContents.length === 0) {
    console.log('No saved layout found.');
    return [];
  }

  return makeJSFriendly(JSON.parse(layoutContents));
}

function getCurrentLayout() {
  const raw = execSync(
    'aerospace list-windows --all --format "%{window-id}%{app-bundle-id}%{window-title}" --json'
  ).toString();

  return makeJSFriendly(JSON.parse(raw));
}

function matchOnWindowId(window) {
  const currentWindowId = window.windowId;

  const matchOnWindowId = savedLayout.find((savedWindow) => {
    return savedWindow.windowId === currentWindowId;
  });
  return matchOnWindowId;
}

function matchOnFullWindowTitle(window) {
  const { appBundleId, windowTitle } = window;

  const matchOnFullWindowTitle = savedLayout.find((savedWindow) => {
    return (
      savedWindow.appBundleId === appBundleId &&
      savedWindow.windowTitle === windowTitle
    );
  });

  return matchOnFullWindowTitle;
}

function matchOnAppBundleId(window) {
  const currentAppBundleId = window.appBundleId;
  const matchOnAppBundleId = savedLayout.find((savedWindow) => {
    return savedWindow.appBundleId === currentAppBundleId;
  });
  return matchOnAppBundleId;
}

function findBestMatch(window) {
  // Order matters!!!!!!
  strategies = [matchOnWindowId, matchOnFullWindowTitle, matchOnAppBundleId];

  // issues remaining:
  //   - edge will mismatch if the title is different (on appbundleid only).
  //   - vs code should match on partial title

  let bestMatch;
  strategies.find((strategy) => {
    bestMatch = strategy(window);
    return bestMatch;
  });

  return bestMatch;
}

function restoreWindowToWorkspaceMaybe(window) {
  const { windowId } = window;
  const bestMatch = findBestMatch(window);

  if (bestMatch) {
    console.log(
      `Restoring window ${windowId} to workspace ${bestMatch.workspace}`
    );
    // execSync(`aerospace move-window --window "${windowId}" --workspace "${workspace}"`);
  } else {
    console.log(`No saved layout for window ${windowId}`);
  }
}

const savedLayout = getSavedLayout();
const currentLayout = getCurrentLayout();

currentLayout.forEach(restoreWindowToWorkspaceMaybe);

// current_windows=$($(brew --prefix)/bin/aerospace list-windows --all --format "%{window-id}%{app-bundle-id}%{window-title}" --json)

// const currentWindows = execSync('brew --prefix', { encoding: 'utf8' }).trim();
// console.log(layout);
