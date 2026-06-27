import React from 'react';
import { LuPlay as Play, LuX as X } from 'react-icons/lu';
import { useFocusable } from '@noriginmedia/norigin-spatial-navigation-react';
import { settingsStorage } from '../../lib/storage';

export interface Post {
  title: string;
  image: string;
  link: string;
  progress?: number;
  providerValue?: string;
  type?: string;
  episodeTitle?: string;
}

interface PostCardItemProps {
  post: Post;
  onClick: (post: Post) => void;
  onRemove?: (post: Post, e: React.MouseEvent) => void;
}

export const PostCardItem: React.FC<PostCardItemProps> = ({ post, onClick, onRemove }) => {
  const tvMode = settingsStorage.isTvModeEnabled();

  const { ref, focused } = useFocusable({
    focusable: tvMode,
    onEnterPress: () => onClick(post),
    onFocus: (layout) => {
      layout.node.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }
  });

  return (
    <div 
      // @ts-ignore
      ref={ref}
      className={`post-card ${focused ? 'tv-focus' : ''}`}
      onClick={() => onClick(post)}
    >
      <div className="post-image-container">
        <img 
          src={post.image} 
          alt={post.title} 
          className="post-image"
          loading="lazy"
        />
        <div className="post-hover-overlay">
          <Play size={48} fill="currentColor" />
        </div>
        {onRemove && (
          <button 
            className="post-remove-btn" 
            onClick={(e) => {
              e.stopPropagation();
              onRemove(post, e);
            }}
            title="Remove from history"
          >
            <X size={20} />
          </button>
        )}
        {post.progress !== undefined && (
          <div className="post-progress-bar-container">
            <div 
              className="post-progress-bar-fill"
              style={{ width: `${post.progress * 100}%` }}
            />
          </div>
        )}
      </div>
      <h3 className="post-title label-md">{post.title}</h3>
    </div>
  );
};
