// ==UserScript==
// @name         GitHub - Warn if squashing or merging at the wrong time
// @namespace    http://stevenhicks.me/
// @version      0.1
// @description  Draw attention to merge/squash button
// @author       Steven Hicks
// @match        https://github.com/artsy/*/pull/*
// @grant        none
// ==/UserScript==

(function () {
  'use strict';

  document.addEventListener('pjax:end', () => {
    queueButtonCheck();
  });
  queueButtonCheck();

  function queueButtonCheck() {
    window.setTimeout(checkButton, 1000);
  }

  function checkButton() {
    const titleEl = document.querySelector('.gh-header-title .js-issue-title');
    if (!titleEl) {
      return;
    }

    const title = titleEl.innerText.trim();

    const activeButtonName = getActiveButtonName();
    if (!activeButtonName) {
      return;
    }

    if (
      (activeButtonName !== 'merge' && title === 'Deploy') ||
      (title !== 'Deploy' && activeButtonName !== 'squash')
    ) {
      showWarning();
    }
  }

  function getActiveButtonName() {
    const names = ['merge', 'squash', 'rebase'];
    return names.find((name) => {
      const element = document.querySelector('.btn-group-' + name);
      if (element) {
        return elementIsVisible(element);
      }
    });
  }

  function elementIsVisible(element) {
    return window.getComputedStyle(element).display !== 'none';
  }

  function showWarning() {
    const button = document.querySelector('.btn-group-merge');
    const ancestor = button.closest('.js-merge-box');
    ancestor.insertAdjacentHTML('beforebegin', makeWarningHTML());
    console.log('hey!');
  }

  function makeWarningHTML() {
    return `
<div style="${makeWarningCSS()}"><h2>👇 Hey Steve!!!! Are you sure this is right?</h2>
</div>
`;
  }

  function makeWarningCSS() {
    return `
background: linear-gradient(to left, #ff2420, #7e57c2, #2196f3, #26c6da, #43a047, #d4e244, #f9a825, #ff2420);
-webkit-background-clip: text;
-webkit-text-fill-color: transparent;
margin-bottom: 15px;
`;
  }
})();
