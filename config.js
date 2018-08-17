module.exports = {
  brew: [
    // http://conqueringthecommandline.com/book/ack_ag
    'ack',
    'ag',
    // Install GNU core utilities (those that come with macOS are outdated)
    // Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    'coreutils',
    'moreutils',
    'dos2unix',
    // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'findutils',
    'fortune',
    'readline', // ensure gawk gets good readline
    'gawk',
    // http://www.lcdf.org/gifsicle/ (because I'm a gif junky)
    'gifsicle',
    'gnupg',
    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
    'gnu-sed --with-default-names',
    // better, more recent grep
    'homebrew/dupes/grep',
    // https://github.com/jkbrzt/httpie
    'httpie',
    // jq is a sort of JSON grep
    'jq',
    // Mac App Store CLI: https://github.com/mas-cli/mas
    'mas',
    // Install some other useful utilities like `sponge`
    'moreutils',
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    // better/more recent version of screen
    'homebrew/dupes/screen',
    'tmux',
    'todo-txt',
    'tree',
    'ttyrec',
    // better, more recent vim
    'vim --with-override-system-vi',
    'watch',
    // Install wget with IRI support
    'wget --enable-iri',
    // Extras
    'openssh',
    'screen',
    'sfnt2woff',
    'sfnt2woff-zopfli',
    'woff2',
    'lua',
    'lynx',
    'p7zip',
    'pigz',
    'pv',
    'rename',
    'rlwrap',
    'ssh-copy-id',
    'tree',
    'vbindiff',
    'zopfli',
    'the_silver_searcher',
    'yarn --without-node'
  ],
  cask: [
    //'adium',
    //'amazon-cloud-drive',
    'atom',
    // 'box-sync',
    //'comicbooklover',
    'diffmerge',
    'docker', // docker for mac
    'dropbox',
    'evernote',
    'flux',
    'gpg-suite',
    'ireadfast',
    'iterm2',
    'little-snitch',
    'macbreakz',
    'micro-snitch',
    'signal',
    //'macvim',
    'sizeup',
    //'sketchup',
    'slack',
    'the-unarchiver',
    //'torbrowser',
    'transmission',
    'visual-studio-code',
    'vlc',
    'xquartz'
  ],
  gem: [
  ],
  npm: [
    'antic',
    'buzzphrase',
    'eslint',
    'instant-markdown-d',
    // 'generator-dockerize',
    // 'gulp',
    'npm-check-updates',
    'prettyjson',
    'trash',
    'vtop',
    'npm-name-cli'
    // ,'yo'
  ]
};
