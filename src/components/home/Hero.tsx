import React from 'react';
import { LuPlay as Play } from 'react-icons/lu';
import { useHeroMetadata } from '../../lib/hooks/useHomePageData';
import { useNavigate } from 'react-router-dom';
import useContentStore from '../../lib/zustand/contentStore';
import { useFocusable } from '@noriginmedia/norigin-spatial-navigation-react';
import { settingsStorage } from '../../lib/storage';
import './Hero.css';

interface HeroProps {
  post: {
    title: string;
    image: string;
    link: string;
  } | null;
}

export const Hero: React.FC<HeroProps> = ({ post }) => {
  const navigate = useNavigate();
  const { provider } = useContentStore();
  const tvMode = settingsStorage.isTvModeEnabled();

  const { data: meta, isLoading: metaLoading } = useHeroMetadata(
    post?.link || '',
    provider?.value || ''
  );

  const handlePlayClick = () => {
    if (post) {
      navigate(`/content/${encodeURIComponent(post.link)}`);
    }
  };

  const { ref: playRef, focused: playFocused } = useFocusable({
    focusable: tvMode && !!post,
    onEnterPress: handlePlayClick,
    onFocus: (layout) => {
      layout.node.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  });

  if (!post || metaLoading) {
    return (
      <div className="hero-container skeleton">
        {post ? (
          <div
            className="hero-background"
            style={{ backgroundImage: `url(${post.image})` }}
          />
        ) : (
          <div className="hero-skeleton-bg" />
        )}
        <div className="hero-vignette" />
        <div className="hero-content">
          <div className="skeleton-title" style={{ width: '60%', height: '48px', marginBottom: '16px' }} />
          <div className="skeleton-text" style={{ width: '80%', height: '24px', marginBottom: '8px' }} />
          <div className="skeleton-text" style={{ width: '70%', height: '24px', marginBottom: '24px' }} />
          <div className="skeleton-button" style={{ width: '120px', height: '48px', borderRadius: '12px' }} />
        </div>
      </div>
    );
  }

  // Use high-res background from meta if available, otherwise use post.image
  const bgImage = meta?.background || post.image;
  // Use logo if available, otherwise just text
  const logoUrl = meta?.logo;
  const description = meta?.description || meta?.plot || '';

  return (
    <div className="hero-container">
      <div
        className="hero-background"
        style={{ backgroundImage: `url(${bgImage})` }}
      />
      <div className="hero-vignette" />

      <div className="hero-content">
        {logoUrl ? (
          <img src={logoUrl} alt={post.title} className="hero-logo" />
        ) : (
          <h1 className="hero-title display-lg">{post.title}</h1>
        )}

        {description && (
          <p className="hero-description body-lg">
            {description}
          </p>
        )}

        <div className="hero-actions">
          <button 
            // @ts-ignore
            ref={playRef}
            className={`btn-play ${playFocused ? 'tv-focus' : ''}`} 
            onClick={handlePlayClick}
          >
            <Play size={24} fill="currentColor" />
            <span className="label-lg">Play</span>
          </button>
        </div>
      </div>
    </div>
  );
};

