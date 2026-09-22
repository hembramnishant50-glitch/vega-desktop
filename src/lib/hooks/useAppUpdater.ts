import { useEffect } from 'react';
import { ask, message } from '@tauri-apps/plugin-dialog';
import { settingsStorage } from '../storage';
import { AxiosError } from 'axios';

export const checkAppUpdates = async (manual = false) => {
  try {
    // Omarchy Linux: Tauri auto-updater only
    const { check } = await import('@tauri-apps/plugin-updater');
    
    // Checks the endpoints defined in tauri.conf.json
    const update = await check();

    if (!update) {
      if (manual) {
        message('You are already on the latest version of Vega Desktop.', { title: 'Up to Date', kind: 'info' });
      }
      return;
    }

    const wantToUpdate = await ask(
      `Version ${update.version} is available!\n\nRelease notes:\n${update.body || 'New version available.'}\n\nWould you like to install it now?`,
      { title: 'Vega Desktop Update', kind: 'info' }
    );
    if (!wantToUpdate) return;

    message(
      `Downloading new version (${update.version}) in the background. The app will restart when ready.`,
      { title: 'Updating Vega Desktop', kind: 'info' }
    );

    console.log(`Downloading update ${update.version}...`);

    let downloaded = 0;
    let contentLength = 0;

    // This seamlessly downloads the patch and overwrites the files silently
    await update.downloadAndInstall((event) => {
      switch (event.event) {
        case 'Started':
          contentLength = event.data.contentLength || 0;
          break;
        case 'Progress':
          downloaded += event.data.chunkLength;
          if (downloaded % (1024 * 1024 * 5) === 0) {
            console.log(`Downloaded ${downloaded} of ${contentLength} bytes`);
          }
          break;
        case 'Finished':
          console.log('Download finished! Restarting...');
          break;
      }
    });


  } catch (err: any) {
    console.error('Failed to check for app updates:', err);
    if (manual) {
      const isRateLimit =
        err instanceof AxiosError &&
        err.response &&
        (err.response.status === 403 || err.response.status === 429);
      const errorMsg = isRateLimit
        ? 'GitHub API rate limit exceeded. Please wait a few minutes before trying again.'
        : 'Failed to check for updates. Please check your internet connection.';
      message(errorMsg, { title: isRateLimit ? 'Rate Limited' : 'Error', kind: 'error' });
    }
  }
};

export const useAppUpdater = () => {
  useEffect(() => {
    // @ts-ignore - Tauri injects this globally
    if (!window.__TAURI_INTERNALS__) return;

    if (!settingsStorage.isAutoCheckUpdateEnabled()) return;

    // Run after a short delay so we don't slow down initial render
    const timer = setTimeout(() => {
      checkAppUpdates(false);
    }, 5000);

    return () => clearTimeout(timer);
  }, []);
};
