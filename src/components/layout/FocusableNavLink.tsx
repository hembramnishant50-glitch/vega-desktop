import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useFocusable } from '@noriginmedia/norigin-spatial-navigation-react';
import { settingsStorage } from '../../lib/storage';

export interface FocusableNavLinkProps extends Omit<React.HTMLAttributes<HTMLDivElement>, 'className'> {
  to: string;
  title?: string;
  focusKey?: string;
  className?: string | ((props: { isActive: boolean }) => string);
}

export const FocusableNavLink: React.FC<FocusableNavLinkProps> = ({ to, title, focusKey: propFocusKey, children, className, ...rest }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const tvMode = settingsStorage.isTvModeEnabled();
  
  // Calculate active state exactly like NavLink does
  const isActive = location.pathname === to || (to !== '/' && location.pathname.startsWith(to));

  const { ref, focused } = useFocusable({
    focusable: tvMode,
    focusKey: propFocusKey,
    onArrowPress: (direction) => {
      // Prevent focus from disappearing off-screen to the left
      if (direction === 'left') {
        return false;
      }
      return true;
    },
    onEnterPress: () => {
      if (typeof to === 'string') {
        navigate(to);
      }
    },
    onFocus: (layout) => {
      layout.node.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  });

  const baseClass = typeof className === 'function' ? className({ isActive }) : className;
  const finalClass = `${baseClass} ${focused ? 'tv-focus' : ''}`.trim();

  return (
    <div 
      {...rest}
      // @ts-ignore
      ref={ref} 
      title={title}
      className={finalClass}
      onClick={() => {
        if (typeof to === 'string') {
          navigate(to);
        }
      }}
      role="link"
    >
      {children}
    </div>
  );
};
