#!/usr/bin/env node

const { execSync } = require('child_process');

function findFirstEmptyWorkspace() {
  try {
    // Get all workspaces
    const workspaces = execSync('aerospace list-workspaces --all')
      .toString()
      .trim()
      .split('\n');

    // Check each workspace for window count
    for (const workspace of workspaces) {
      const windows = execSync(
        `aerospace list-windows --workspace "${workspace}"`
      )
        .toString()
        .trim();
      if (!windows) {
        // Return the first workspace with no windows
        return workspace;
      }
    }

    // If no empty workspace is found
    return null;
  } catch (error) {
    console.error('Error:', error.message);
    return null;
  }
}

// Run the function and print the result
const emptyWorkspace = findFirstEmptyWorkspace();
if (emptyWorkspace) {
  console.log(emptyWorkspace);
}
