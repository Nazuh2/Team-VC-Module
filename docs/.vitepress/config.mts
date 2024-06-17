import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Team Voice Chat",
  description: "A Versatile Voice Chat Module For Roblox",
  vite: {
    plugins: [
    ]
  },
  base: '/Team-VC-Module/',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'API Reference', items:[{ text: '1.0', link: '/api/1.0/TeamChatServer' }] }
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Guide',
          items: [
            { text: 'Overview', link: '/guide/' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Getting Started', link: '/guide/getting-started' },
          ]
        },
        {
          text: 'Examples',
          items: [
            { text: 'Audio Effects', link: '/guide/examples/audio-effects' },
            { text: 'Team Voice Chat Disabled', link: '/guide/examples/disable-team-voice-chat' }
          ]
        }
      ],
      '/api/1.0/': [
        {
          text: 'API',
          items: [
            { text: 'TeamChatServer', link: '/api/1.0/TeamChatServer' },
            { text: 'TeamChatClient', link: '/api/1.0/TeamChatClient' },
            { text: 'AudioUtil', link: '/api/1.0/AudioUtil' },
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Nazuh2/Team-VC-Module' },
      { icon: 'discord', link: 'https://discord.gg/v5uCx4VS9s' }
    ]
  }
})
