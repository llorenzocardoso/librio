import React, { useEffect, useRef, useState } from 'react';
import { useColorMode } from '@docusaurus/theme-common';
import './styles.css';

interface MermaidFullscreenProps {
  children: React.ReactNode;
}

const MermaidFullscreen: React.FC<MermaidFullscreenProps> = ({ children }) => {
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [scale, setScale] = useState(1);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);
  const { colorMode } = useColorMode();

  const toggleFullscreen = () => {
    setIsFullscreen(!isFullscreen);
    if (!isFullscreen) {
      setScale(1);
      setPosition({ x: 0, y: 0 });
    }
  };

  const handleZoomIn = () => {
    setScale(prev => Math.min(prev + 0.3, 5));
  };

  const handleZoomOut = () => {
    setScale(prev => Math.max(prev - 0.3, 0.3));
  };

  const handleReset = () => {
    setScale(1);
    setPosition({ x: 0, y: 0 });
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    if (scale > 1) {
      setIsDragging(true);
      setDragStart({
        x: e.clientX - position.x,
        y: e.clientY - position.y
      });
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isDragging && scale > 1) {
      setPosition({
        x: e.clientX - dragStart.x,
        y: e.clientY - dragStart.y
      });
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleWheel = (e: React.WheelEvent) => {
    if (isFullscreen) {
      e.preventDefault();
      const delta = e.deltaY * -0.002;
      setScale(prev => Math.max(0.3, Math.min(5, prev + delta)));
    }
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isFullscreen) {
        switch (e.key) {
          case 'Escape':
            setIsFullscreen(false);
            break;
          case '+':
          case '=':
            handleZoomIn();
            break;
          case '-':
          case '_':
            handleZoomOut();
            break;
          case '0':
            handleReset();
            break;
        }
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isFullscreen]);

  return (
    <div className="mermaid-container">
      <div
        className="mermaid-wrapper"
        ref={containerRef}
        onClick={toggleFullscreen}
        style={{ cursor: 'pointer' }}
        title="Clique para visualizar em tela cheia"
      >
        <button
          className="fullscreen-button"
          onClick={(e) => {
            e.stopPropagation();
            toggleFullscreen();
          }}
          title="Visualizar em tela cheia"
          aria-label="Visualizar diagrama em tela cheia"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/>
          </svg>
        </button>
        {children}
      </div>

      {isFullscreen && (
        <div
          className={`fullscreen-overlay ${colorMode}`}
          onMouseDown={handleMouseDown}
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseUp}
          onWheel={handleWheel}
        >
          <div className="fullscreen-controls">
            <button
              onClick={handleZoomIn}
              title="Zoom In (+)"
              aria-label="Aumentar zoom"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
              </svg>
            </button>
            <button
              onClick={handleZoomOut}
              title="Zoom Out (-)"
              aria-label="Diminuir zoom"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 13H5v-2h14v2z"/>
              </svg>
            </button>
            <button
              onClick={handleReset}
              title="Reset (0)"
              aria-label="Resetar zoom"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
              </svg>
            </button>
            <span className="zoom-level">{Math.round(scale * 100)}%</span>
            <button
              onClick={toggleFullscreen}
              title="Sair da tela cheia (ESC)"
              aria-label="Sair da tela cheia"
              className="close-button"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <div
            className="fullscreen-content"
            style={{
              transform: `translate(${position.x}px, ${position.y}px) scale(${scale})`,
              cursor: scale > 1 ? (isDragging ? 'grabbing' : 'grab') : 'default'
            }}
          >
            {children}
          </div>
        </div>
      )}
    </div>
  );
};

export default MermaidFullscreen;
