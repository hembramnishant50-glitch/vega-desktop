import { useEffect } from 'react';
import { getVersion } from '@tauri-apps/api/app';
import { ask, message } from '@tauri-apps/plugin-dialog';
import { openUrl, openPath } from '@tauri-apps/plugin-opener';
import { download } from '@tauri-apps/plugin-upload';
import { downloadDir, join } from '@tauri-apps/api/path';
import { settingsStorage } from '../storage';
import axios from 'axios';

// Helper to compare semver versions simply
const isNewer = (latest: string, current: string) => {
  if (!latest || !current) return false;
  const l = latest.replace(/[^0-9.]/g, '').split('.').map(Number);
  const c = current.replace(/[^0-9.]/g, '').split('.').map(Number);
  for (let i = 0; i < 3; i++) {
    const lPart = l[i] || 0;
    const cPart = c[i] || 0;
    if (lPart > cPart) return true;
    if (lPart < cPart) return false;
  }
  return false;
};

export const checkAppUpdates = async (manual = false) => {
  try {
    // 1. Fetch latest release from GitHub
    const { data: release } = await axios.get(
      'https://api.github.com/repos/vega-org/vega-desktop/releases/latest'
    );

    const latestVersion = release?.tag_name;
    const currentVersion = await getVersion();

    if (!latestVersion) {
      console.log('No public releases found or GitHub API returned an error.');
      if (manual) {
        message('No public releases found yet. Check back later!', { title: 'Up to Date', kind: 'info' });
      }
      return;
    }

    if (!isNewer(latestVersion, currentVersion)) {
      console.log('Vega Desktop is up to date.');
      if (manual) {
        message('You are already on the latest version of Vega Desktop.', { title: 'Up to Date', kind: 'info' });
      }
      return;
    }

    const autoInstall = settingsStorage.isAutoDownloadEnabled();
    const userAgent = navigator.userAgent.toLowerCase();

    let platformExt = '';
    if (userAgent.includes('windows') || userAgent.includes('win32')) {
      platformExt = '.exe';
    } else if (userAgent.includes('macintosh') || userAgent.includes('mac os')) {
      platformExt = '.dmg';
    } else if (userAgent.includes('linux')) {
      platformExt = '.appimage';
    }

    // Find the appropriate asset
    const asset = release.assets?.find((a: any) =>
      a.name.toLowerCase().endsWith(platformExt) ||
      (platformExt === '.exe' && a.name.toLowerCase().endsWith('.msi'))
    );

    if (!autoInstall || !asset) {
      // Just show a dialog
      const wantToUpdate = await ask(
        `Version ${latestVersion} is available! Would you like to go to the download page?`,
        { title: 'Vega Desktop Update', kind: 'info' }
      );
      if (wantToUpdate) {
        openUrl(release.html_url);
      }
      return;
    }

    // Auto-download the installer
    const dlDir = await downloadDir();
    const filePath = await join(dlDir, asset.name);

    console.log('Downloading update to:', filePath);

    // We don't await the message so it doesn't block the download
    message(`Downloading new version (${latestVersion}). You will be prompted when it finishes.`, { title: 'Updating Vega Desktop' });

    await download(
      asset.browser_download_url,
      filePath,
      (progressInfo) => {
        // You could optionally send progress updates to a UI toast here
        if (progressInfo.progress % 1024 === 0) {
          // Keep the variable used
          console.log('Downloading...', progressInfo.progress);
        }
      }
    );

    const wantToInstall = await ask(
      `Update downloaded successfully! Do you want to install it now?`,
      { title: 'Update Ready', kind: 'info' }
    );

    if (wantToInstall) {
      // Launch installer and let the OS take over
      await openPath(filePath);
    }

  } catch (err: any) {
    console.error('Failed to check for app updates:', err);
    if (manual) {
      if (err.response?.status === 404) {
        message('No public releases found yet. Check back later!', { title: 'Up to Date', kind: 'info' });
      } else {
        message('Failed to check for updates. Please check your internet connection.', { title: 'Error', kind: 'error' });
      }
    }
  }
};

export const useAppUpdater = () => {
  useEffect(() => {
    // @ts-ignore - Tauri injects this globally
    if (!window.__TAURI_INTERNALS__) return;

    // Run after a short delay so we don't slow down initial render
    const timer = setTimeout(() => {
      checkAppUpdates(false);
    }, 5000);

    return () => clearTimeout(timer);
  }, []);
};
