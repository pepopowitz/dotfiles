module.exports = {
  onRendererWindow(win) {
    console.log('[hyper-shift-enter] onRendererWindow called');

    try {
      win.document.addEventListener('DOMContentLoaded', () => {
        console.log('[hyper-shift-enter] DOM ready');
        attachListener(win);
      });

      if (win.document.readyState !== 'loading') {
        console.log('[hyper-shift-enter] DOM already ready, attaching directly');
        attachListener(win);
      }
    } catch (err) {
      console.error('[hyper-shift-enter] Error attaching listener:', err);
    }
  }
};

function attachListener(win) {
  win.document.addEventListener('keydown', (e) => {
    console.log('[hyper-shift-enter] keydown:', e.key, 'shift:', e.shiftKey, 'code:', e.code);

    if (e.key === 'Enter' && e.shiftKey) {
      console.log('[hyper-shift-enter] Shift+Enter intercepted!');

      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      try {
        const state = win.store.getState();
        const uid = state.sessions.activeUid;
        console.log('[hyper-shift-enter] uid:', uid, 'sessions:', Object.keys(state.sessions.sessions || {}));

        if (uid) {
          win.rpc.emit('data', { uid, data: '\x0a' });
          console.log('[hyper-shift-enter] sent \\x0a to uid:', uid);
        } else {
          console.warn('[hyper-shift-enter] no active uid found');
        }
      } catch (err) {
        console.error('[hyper-shift-enter] Error in handler:', err);
      }
    }
  }, true);
}
