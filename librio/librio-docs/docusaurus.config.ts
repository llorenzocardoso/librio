import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Librio - Documentação Técnica',
  tagline: 'Aplicativo de Troca de Livros - Flutter & Firebase',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://your-docusaurus-site.example.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'your-username', // Usually your GitHub org/user name.
  projectName: 'librio-docs', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'pt',
    locales: ['pt'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/', // Serve the docs at the site's root
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/your-username/librio/tree/main/librio-docs/',
        },
        blog: false, // Disable the blog plugin
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        // `hashed` is recommended as long-term-cache of index file is possible.
        hashed: true,
        // For Docs using Chinese, The `language` is recommended to set to:
        // ```
        // language: ["en", "zh"],
        // ```
        language: ["pt", "en"],
        indexDocs: true,
        indexBlog: false,
        indexPages: false,
        // 0 means no limit
        docsRouteBasePath: '/',
        searchBarPosition: 'right',
      },
    ],
    // Plugin personalizado para melhorar diagramas Mermaid
    './src/plugins/mermaid-enhancer',
  ],

    // Enable Mermaid diagrams
  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],

  themeConfig: {
    // Configuração global do Mermaid para cores consistentes
    mermaid: {
      theme: {
        light: 'base',
        dark: 'dark'
      },
      options: {
        theme: 'base',
        themeVariables: {
          primaryColor: '#f8f9fa',
          primaryTextColor: '#495057',
          primaryBorderColor: '#6c757d',
          lineColor: '#6c757d',
          secondaryColor: '#e9ecef',
          tertiaryColor: '#f8f9fa'
        }
      }
    },
    // Replace with your project's social card
    image: 'img/librio-social-card.jpg',
    navbar: {
      title: 'Librio Docs',
      logo: {
        alt: 'Librio Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Documentação',
        },
        {
          href: 'https://github.com/your-username/librio',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentação',
          items: [
            {
              label: 'Visão Geral',
              to: '/',
            },
            {
              label: 'Configuração',
              to: '/setup/environment',
            },
            {
              label: 'Arquitetura',
              to: '/architecture/overview',
            },
          ],
        },
        {
          title: 'Tecnologias',
          items: [
            {
              label: 'Flutter',
              href: 'https://flutter.dev',
            },
            {
              label: 'Firebase',
              href: 'https://firebase.google.com',
            },
            {
              label: 'Dart',
              href: 'https://dart.dev',
            },
          ],
        },
        {
          title: 'Projeto',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/your-username/librio',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Librio Project. Documentação construída com Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'yaml', 'bash', 'javascript'],
    },
    // Configurações do tema
    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
