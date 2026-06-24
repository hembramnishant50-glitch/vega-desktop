import React, { useState, useEffect } from 'react';
import { settingsStorage } from '../../lib/storage';
import { open } from '@tauri-apps/plugin-dialog';
import { FolderOpen } from 'lucide-react';
import { FocusableButton } from '../layout/FocusableButton';

const QUALITIES = ['360p', '480p', '720p', '1080p', '4k'];

export const PreferencesSettings: React.FC = () => {
  const [downloadLocation, setDownloadLocation] = useState<string>('vega');
  const [excludedQualities, setExcludedQualities] = useState<string[]>([]);
  const [autoInstallUpdates, setAutoInstallUpdates] = useState<boolean>(true);
  const [tvModeEnabled, setTvModeEnabled] = useState<boolean>(false);

  useEffect(() => {
    setDownloadLocation(settingsStorage.getDownloadLocation());
    setExcludedQualities(settingsStorage.getExcludedQualities());
    setAutoInstallUpdates(settingsStorage.isAutoDownloadEnabled());
    setTvModeEnabled(settingsStorage.isTvModeEnabled());
  }, []);

  const handleChangeDir = async () => {
    try {
      const selected = await open({
        directory: true,
        multiple: false,
      });
      if (selected && typeof selected === 'string') {
        setDownloadLocation(selected);
        settingsStorage.setDownloadLocation(selected);
      }
    } catch (err) {
      console.error('Failed to open dialog:', err);
    }
  };

  const handleResetDir = () => {
    setDownloadLocation('vega');
    settingsStorage.resetDownloadLocation();
  };

  const handleToggleQuality = (quality: string) => {
    const updated = excludedQualities.includes(quality)
      ? excludedQualities.filter(q => q !== quality)
      : [...excludedQualities, quality];
    
    setExcludedQualities(updated);
    settingsStorage.setExcludedQualities(updated);
  };

  const handleToggleAutoInstall = () => {
    const nextState = !autoInstallUpdates;
    setAutoInstallUpdates(nextState);
    settingsStorage.setAutoDownloadEnabled(nextState);
  };

  const handleToggleTvMode = () => {
    const nextState = !tvModeEnabled;
    setTvModeEnabled(nextState);
    settingsStorage.setTvModeEnabled(nextState);
  };

  const isAndroid = navigator.userAgent.toLowerCase().includes('android');

  return (
    <div className="preferences-settings">
      {/* Download Directory */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg">Download Directory</h3>
          <p className="body-md text-muted" style={{ wordBreak: 'break-all' }}>
            {isAndroid 
              ? 'Internal App Storage (Recommended for Android)' 
              : (downloadLocation === 'vega' ? 'Default (Documents/VegaDownloads)' : downloadLocation)}
          </p>
        </div>
        {!isAndroid && (
          <div style={{ display: 'flex', gap: '8px' }}>
            <FocusableButton 
              className="theme-toggle-btn active"
              style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
              onClick={handleChangeDir}
            >
              <FolderOpen size={16} /> Change
            </FocusableButton>
            {downloadLocation !== 'vega' && (
              <FocusableButton 
                className="theme-toggle-btn"
                onClick={handleResetDir}
              >
                Reset
              </FocusableButton>
            )}
          </div>
        )}
      </div>

      <div className="settings-divider" />

      {/* Auto Install Updates */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg">Auto Install App Updates</h3>
          <p className="body-md text-muted">Automatically download and install new versions of Vega</p>
        </div>
        <FocusableButton 
          className={`theme-toggle-btn ${autoInstallUpdates ? 'active' : ''}`}
          onClick={handleToggleAutoInstall}
        >
          {autoInstallUpdates ? 'ON' : 'OFF'}
        </FocusableButton>
      </div>

      <div className="settings-divider" />
      
      {/* TV Mode */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg">TV / Controller Mode</h3>
          <p className="body-md text-muted">Enable arrow-key spatial navigation for remotes and gamepads (Requires app restart)</p>
        </div>
        <FocusableButton 
          className={`theme-toggle-btn ${tvModeEnabled ? 'active' : ''}`}
          onClick={handleToggleTvMode}
        >
          {tvModeEnabled ? 'ON' : 'OFF'}
        </FocusableButton>
      </div>

      <div className="settings-divider" />
      
      {/* Excluded Qualities */}
      <div className="settings-row">
        <div className="settings-info" style={{ width: '100%' }}>
          <h3 className="label-lg">Excluded Qualities</h3>
          <p className="body-md text-muted" style={{ marginBottom: '8px' }}>Select qualities you want to hide from playback and downloads.</p>
          
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '8px' }}>
            {QUALITIES.map(q => {
              const isExcluded = excludedQualities.includes(q);
              return (
                <FocusableButton
                  key={q}
                  className={`quality-toggle-btn ${isExcluded ? 'excluded' : ''}`}
                  onClick={() => handleToggleQuality(q)}
                  title={isExcluded ? 'Click to Include' : 'Click to Exclude'}
                >
                  {q}
                </FocusableButton>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};
