import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'fr-FR',
  title: 'Thon sur thon',
  description: 'Projet SMA – M2 ILIADE : banc de thons, obstacles et émergence',
  srcExclude: ['memoire/**'],
  head: [['link', { rel: 'icon', href: '/logo.png' }]],
  themeConfig: {
    logo: '/logo.png',
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Le projet', link: '/idee-generale' },
      { text: 'Versions', link: '/versions' },
      { text: 'Feuille de route', link: '/feuille-de-route' },
    ],
    sidebar: [
      {
        text: 'Le projet',
        items: [
          { text: 'Idée générale', link: '/idee-generale' },
          { text: 'Versions', link: '/versions' },
          { text: 'Interface et ergonomie', link: '/interface' },
          { text: 'Écran de démarrage', link: '/ecran-de-demarrage' },
        ],
      },
      {
        text: 'Organisation',
        items: [
          { text: 'Feuille de route', link: '/feuille-de-route' },
          { text: 'Pratiques git', link: '/pratiques-git' },
        ],
      },
    ],
    search: { provider: 'local' },
    socialLinks: [{ icon: 'github', link: 'https://github.com/Lou-Simon/thon-sur-ton' }],
    outline: { label: 'Sur cette page' },
    docFooter: { prev: 'Page précédente', next: 'Page suivante' },
  },
})
