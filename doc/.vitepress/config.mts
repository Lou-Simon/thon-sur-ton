import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'fr-FR',
  title: 'Thon sur thon',
  description: 'Projet SMA – M2 ILIADE : banc de thons, obstacles et émergence',
  themeConfig: {
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Doc', link: '/idee-generale' },
    ],
    sidebar: [
      {
        text: 'Documentation',
        items: [
          { text: '1. Idée générale', link: '/idee-generale' },
          { text: '2. Technique mathématique', link: '/technique-mathematique' },
          { text: '3. Technique Claude (agents)', link: '/technique-claude' },
        ],
      },
    ],
    socialLinks: [{ icon: 'github', link: 'https://github.com/Lou-Simon/thon-sur-ton' }],
    outline: { label: 'Sur cette page' },
    docFooter: { prev: 'Page précédente', next: 'Page suivante' },
  },
})
