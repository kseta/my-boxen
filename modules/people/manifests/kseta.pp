class people::kseta {
  include dropbox
  include skype
  include iterm2::stable
  include chrome
  include java
  include googledrive
  include alfred
  include phpstorm
  include shortcat
  include clipmenu
  include skitch
  include virtualbox
  include mongodb

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
      'curl',
      'automake',
      'autoconf',
      'pcre',
      're2c',
      'mhash',
      'libtool',
      'icu4c',
      'gettext',
      'jpeg',
      'libxml2',
      'libssh2',
      'mcrypt',
      'gmp',
      'libevent'
    ]:
  }

  # install mac applications
  package {
    'GoogleJapaneseInput':
      source => "http://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg",
      provider => pkgdmg;
  }

  $home  = "/Users/${::luser}"
  $src   = "${home}/src"
  $boxen = "/opt/boxen"

  # settings for phpbrew
  $phpbrew = "${boxen}/phpbrew"
  repository { $phpbrew:
    source  => "c9s/phpbrew",
    require => File[$boxen]
  }
  exec { "ln -s ${phpbrew}/phpbrew ${boxen}/bin":
    require => Repository[$phpbrew],
  }

  # settings for dotfiles
  $dotfiles  = "${src}/dotfiles"
  repository { $dotfiles:
    source  => "${::luser}/dotfiles",
    require => File[$src]
  }
  exec { "sh ${dotfiles}/configure":
    cwd => $dotfiles,
    creates => [ "${home}/.zshrc", "${home}/.zshenv", "${home}/.vimrc", "${home}/.vim", "${home}/.gitconfig" ],
    require => Repository[$dotfiles],
  }

  # settings for private files
  $privatefiles  = "${src}/privatefiles"
  repository { $privatefiles:
    source  => "git@bitbucket.org:${::luser}/privatefiles.git",
    require => File[$src]
  }
  exec { "sh ${privatefiles}/configure":
    cwd => $privatefiles,
    creates => [ "${home}/.ssh" ],
    require => Repository[$privatefiles],
  }

  # seettings for vim
  $vim         = "${dotfiles}/.vim"
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

 # download items
 $items = "${src}/items"

 # Ricty
 $ricty = "${items}/ricty"
 repository { $ricty:
     source  => "git@bitbucket.org:${::luser}/ricty.git",
     require => File[$items]
 }
 exec { "sh ${ricty}/configure":
     cwd     => $ricty,
     require => Repository[$ricty],
 }

 # postgresql jdbc
 file { "${items}":
   ensure => "directory",
 }
 $jdbc_url = "http://jdbc.postgresql.org/download/postgresql-9.2-1002.jdbc3.jar"
 exec { "wget ${jdbc_url} -P ${items}":
   cwd => $privatefiles,
   creates => [ "${items}" ],
 }

 # hub completion
 $_git = "${boxen}/homebrew/share/zsh/site-functions/_git"
 $hubc = "${items}/hub-zsh-completion/_git"
 repository { "${items}/hub-zsh-completion":
     source  => "glidenote/hub-zsh-completion",
     require => File[$items]
 }
 exec { "rm ${_git} && ln -s ${hubc} ${_git}":
     require => File[$items]
 }
}
