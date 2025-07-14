import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
  docsSidebar: [
    'intro',
    'overview',
    {
      type: 'category',
      label: '🔧 Configuração do Ambiente',
      items: [
        'setup/environment',
        'setup/installation',
      ],
    },
    {
      type: 'category',
      label: '🏗️ Arquitetura',
      items: [
        'architecture/overview',
        'architecture/clean-architecture',
        'architecture/state-management',
      ],
    },
    {
      type: 'category',
      label: '🔥 Firebase Backend',
      items: [
        'firebase/firestore',
        'firebase/authentication',
        'firebase/storage',
      ],
    },
    {
      type: 'category',
      label: '⚡ Funcionalidades',
      items: [
        'features/authentication',
        'features/books',
        'features/search-and-filters',
        'features/geolocation',
        'features/exchanges',
        'features/chat',
        'features/notifications',
        'features/ratings',
      ],
    },
    {
      type: 'category',
      label: '🧪 Testes',
      items: [
        'testing/unit-tests',
        'testing/widget-tests',
        'testing/integration-tests',
      ],
    },
    {
      type: 'category',
      label: '🚀 Deploy e Publicação',
      items: [
        'deployment/building',
        'deployment/publishing',
        'deployment/ci-cd',
      ],
    },
  ],

  // But you can create a sidebar manually
  /*
  tutorialSidebar: [
    'intro',
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
   */
};

export default sidebars;
