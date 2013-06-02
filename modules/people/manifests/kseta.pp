class people::kseta {
  include dropbox
  include skype
  include iterm2::stable
  include chrome
  include java
  include googledrive
  include alfred


  # install with homebrew
  package {
    [
      'ctags',
      'lv',
      'mysql',
      'redis',
      'wget',
      'z',
      'zsh',
    ]:
  }

  # install mac applications
  package {
    'GoogleJapaneseInput':
      source => "http://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg",
      provider => pkgdmg;
  }

  $home      = "/Users/${::luser}"
  $src       = "${home}/src"

  # settings for dotfiles
  $dotfiles  = "${src}/dotfiles"
  repository { $dotfiles:
    source  => "${::luser}/dotfiles",
    require => File[$src]
  }
  exec { "sh ${dotfiles}/configure":
    cwd => $dotfiles,
    creates => [ "${home}/.zshrc", "${home}/.vimrc", "${home}/.gitconfig", "${home}/.tmux.conf" ],
    require => Repository[$dotfiles],
  }

  # seettings for vim
  $vim         = "${home}/.vim"
  $neobundle   = "${vim}/bundle/neobundle.vim"
  file { $vim:
    ensure => "directory",
  }
  repository { $neobundle:
    source => "Shougo/neobundle.vim",
    require => File[$vim]
  }

  # settings for zsh
  file_line { 'add zsh to /etc/shells':
    path    => '/etc/shells',
    line    => "${boxen::config::homebrewdir}/bin/zsh",
    require => Package['zsh'],
    before  => Osx_chsh[$::luser];
  }
  osx_chsh { $::luser:
    shell   => "${boxen::config::homebrewdir}/bin/zsh";
  }
}
