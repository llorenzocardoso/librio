import ExecutionEnvironment from '@docusaurus/ExecutionEnvironment';

if (ExecutionEnvironment.canUseDOM) {
  // Função para adicionar funcionalidade de fullscreen aos diagramas Mermaid
  function enhanceMermaidDiagrams() {
    const mermaidElements = document.querySelectorAll('.docusaurus-mermaid-container');

    mermaidElements.forEach((container) => {
      // Evita processar o mesmo elemento duas vezes
      if (container.classList.contains('enhanced')) return;

      container.classList.add('enhanced');

      // Adiciona estilos básicos
      container.style.position = 'relative';
      container.style.border = '1px solid var(--ifm-color-emphasis-300)';
      container.style.borderRadius = '8px';
      container.style.overflow = 'hidden';
      container.style.cursor = 'pointer';
      container.style.transition = 'all 0.3s ease';

      // Efeito hover
      container.addEventListener('mouseenter', () => {
        container.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.1)';
        container.style.borderColor = 'var(--ifm-color-primary)';
      });

      container.addEventListener('mouseleave', () => {
        container.style.boxShadow = 'none';
        container.style.borderColor = 'var(--ifm-color-emphasis-300)';
      });

      // Cria botão de fullscreen
      const fullscreenBtn = document.createElement('button');
      fullscreenBtn.className = 'mermaid-fullscreen-btn';
      fullscreenBtn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/>
        </svg>
      `;
      fullscreenBtn.title = 'Clique para visualizar em tela cheia';

      // Estilos do botão
      Object.assign(fullscreenBtn.style, {
        position: 'absolute',
        top: '8px',
        right: '8px',
        zIndex: '10',
        background: 'rgba(255, 255, 255, 0.9)',
        border: '1px solid var(--ifm-color-emphasis-300)',
        borderRadius: '6px',
        padding: '8px',
        cursor: 'pointer',
        transition: 'all 0.2s ease',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'var(--ifm-color-emphasis-700)',
        backdropFilter: 'blur(4px)'
      });

      // Hover do botão
      fullscreenBtn.addEventListener('mouseenter', () => {
        fullscreenBtn.style.background = 'rgba(255, 255, 255, 1)';
        fullscreenBtn.style.borderColor = 'var(--ifm-color-primary)';
        fullscreenBtn.style.color = 'var(--ifm-color-primary)';
        fullscreenBtn.style.transform = 'scale(1.05)';
      });

      fullscreenBtn.addEventListener('mouseleave', () => {
        fullscreenBtn.style.background = 'rgba(255, 255, 255, 0.9)';
        fullscreenBtn.style.borderColor = 'var(--ifm-color-emphasis-300)';
        fullscreenBtn.style.color = 'var(--ifm-color-emphasis-700)';
        fullscreenBtn.style.transform = 'scale(1)';
      });

      // Função para abrir em fullscreen
      const openFullscreen = (e) => {
        e.stopPropagation();

        const mermaidSvg = container.querySelector('svg');
        if (!mermaidSvg) return;

        // Cria overlay
        const overlay = document.createElement('div');
        overlay.className = 'mermaid-fullscreen-overlay';

        // Aplica tema
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        if (isDark) overlay.classList.add('dark');

        Object.assign(overlay.style, {
          position: 'fixed',
          top: '0',
          left: '0',
          right: '0',
          bottom: '0',
          zIndex: '9999',
          background: isDark ? 'rgba(24, 25, 26, 0.95)' : 'rgba(255, 255, 255, 0.95)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
          backdropFilter: 'blur(8px)'
        });

        // Clona o SVG
        const clonedSvg = mermaidSvg.cloneNode(true);
        clonedSvg.style.maxWidth = '90vw';
        clonedSvg.style.maxHeight = '90vh';
        clonedSvg.style.transition = 'transform 0.1s ease-out';

        // Cria controles
        const controls = document.createElement('div');
        controls.className = 'mermaid-fullscreen-controls';
        Object.assign(controls.style, {
          position: 'fixed',
          top: '20px',
          right: '20px',
          zIndex: '10000',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          background: isDark ? 'rgba(40, 44, 52, 0.95)' : 'rgba(255, 255, 255, 0.95)',
          border: '1px solid var(--ifm-color-emphasis-300)',
          borderRadius: '8px',
          padding: '8px 12px',
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.1)',
          backdropFilter: 'blur(8px)'
        });

        // Variáveis de zoom e posição
        let scale = 1;
        let position = { x: 0, y: 0 };
        let isDragging = false;
        let dragStart = { x: 0, y: 0 };

        // Funções de zoom
        const updateTransform = () => {
          clonedSvg.style.transform = `translate(${position.x}px, ${position.y}px) scale(${scale})`;
          zoomDisplay.textContent = `${Math.round(scale * 100)}%`;
        };

        const zoomIn = () => {
          scale = Math.min(scale + 0.3, 5);
          updateTransform();
        };

        const zoomOut = () => {
          scale = Math.max(scale - 0.3, 0.3);
          updateTransform();
        };

        const resetZoom = () => {
          scale = 1;
          position = { x: 0, y: 0 };
          updateTransform();
        };

        // Botões de controle
        const createControlBtn = (innerHTML, title, onClick) => {
          const btn = document.createElement('button');
          btn.innerHTML = innerHTML;
          btn.title = title;
          Object.assign(btn.style, {
            background: 'transparent',
            border: '1px solid var(--ifm-color-emphasis-300)',
            borderRadius: '6px',
            padding: '6px',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--ifm-color-emphasis-700)',
            minWidth: '32px',
            height: '32px'
          });
          btn.addEventListener('click', onClick);
          return btn;
        };

        const zoomInBtn = createControlBtn(
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>',
          'Zoom In (+)',
          zoomIn
        );

        const zoomOutBtn = createControlBtn(
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M19 13H5v-2h14v2z"/></svg>',
          'Zoom Out (-)',
          zoomOut
        );

        const resetBtn = createControlBtn(
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/></svg>',
          'Reset (0)',
          resetZoom
        );

        const zoomDisplay = document.createElement('span');
        zoomDisplay.textContent = '100%';
        Object.assign(zoomDisplay.style, {
          fontSize: '14px',
          fontWeight: '600',
          color: 'var(--ifm-color-emphasis-800)',
          minWidth: '50px',
          textAlign: 'center',
          padding: '0 8px'
        });

        const closeBtn = createControlBtn(
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>',
          'Sair da tela cheia (ESC)',
          () => document.body.removeChild(overlay)
        );

        closeBtn.style.background = 'var(--ifm-color-danger-lightest)';
        closeBtn.style.color = 'var(--ifm-color-danger)';
        closeBtn.style.borderColor = 'var(--ifm-color-danger-light)';

        // Adiciona controles
        controls.appendChild(zoomInBtn);
        controls.appendChild(zoomOutBtn);
        controls.appendChild(resetBtn);
        controls.appendChild(zoomDisplay);
        controls.appendChild(closeBtn);

        // Container do conteúdo
        const content = document.createElement('div');
        content.appendChild(clonedSvg);

        // Eventos de drag
        content.addEventListener('mousedown', (e) => {
          if (scale > 1) {
            isDragging = true;
            dragStart = {
              x: e.clientX - position.x,
              y: e.clientY - position.y
            };
            clonedSvg.style.cursor = 'grabbing';
          }
        });

        overlay.addEventListener('mousemove', (e) => {
          if (isDragging && scale > 1) {
            position = {
              x: e.clientX - dragStart.x,
              y: e.clientY - dragStart.y
            };
            updateTransform();
          }
        });

        overlay.addEventListener('mouseup', () => {
          isDragging = false;
          clonedSvg.style.cursor = scale > 1 ? 'grab' : 'default';
        });

        // Zoom com scroll
        overlay.addEventListener('wheel', (e) => {
          e.preventDefault();
          const delta = e.deltaY * -0.002;
          scale = Math.max(0.3, Math.min(5, scale + delta));
          updateTransform();
        });

        // Eventos de teclado
        const handleKeydown = (e) => {
          switch (e.key) {
            case 'Escape':
              document.body.removeChild(overlay);
              break;
            case '+':
            case '=':
              zoomIn();
              break;
            case '-':
            case '_':
              zoomOut();
              break;
            case '0':
              resetZoom();
              break;
          }
        };

        document.addEventListener('keydown', handleKeydown);

        // Cleanup quando overlay é removido
        const observer = new MutationObserver((mutations) => {
          mutations.forEach((mutation) => {
            if (mutation.type === 'childList' && !document.body.contains(overlay)) {
              document.removeEventListener('keydown', handleKeydown);
              observer.disconnect();
            }
          });
        });
        observer.observe(document.body, { childList: true });

        // Adiciona ao DOM
        overlay.appendChild(controls);
        overlay.appendChild(content);
        document.body.appendChild(overlay);

        // Cursor inicial
        clonedSvg.style.cursor = scale > 1 ? 'grab' : 'default';

        // Foco para permitir eventos de teclado
        overlay.focus();
        overlay.style.outline = 'none';
        overlay.tabIndex = -1;
      };

      // Adiciona eventos de clique
      fullscreenBtn.addEventListener('click', openFullscreen);
      container.addEventListener('click', openFullscreen);

      // Adiciona botão ao container
      container.appendChild(fullscreenBtn);

      // Adiciona tooltip
      container.title = 'Clique para visualizar em tela cheia';
    });
  }

  // Executa quando a página carrega
  document.addEventListener('DOMContentLoaded', enhanceMermaidDiagrams);

  // Executa após navegação no SPA
  if (window.location) {
    let currentPath = window.location.pathname;
    const checkForNewDiagrams = () => {
      if (window.location.pathname !== currentPath) {
        currentPath = window.location.pathname;
        setTimeout(enhanceMermaidDiagrams, 500); // Delay para permitir renderização
      }
    };

    // Observa mudanças na URL
    window.addEventListener('popstate', checkForNewDiagrams);

    // Observa mudanças no DOM para SPA navigation
    const observer = new MutationObserver(() => {
      setTimeout(enhanceMermaidDiagrams, 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}
