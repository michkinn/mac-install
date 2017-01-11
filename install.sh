#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\

## La base : Homebrew et les lignes de commande
if test ! $(which brew)
then
	echo 'Installation de Homebrew'
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# Installation d'apps avec mas (source : https://github.com/argon/mas/issues/41#issuecomment-245846651)
function install () {
	# Check if the App is already installed
	mas list | grep -i "$1" > /dev/null

	if [ "$?" == 0 ]; then
		printf "==> \e[32m [Info] \e[0m $1 est déjà installée\n"
	else
		printf "==> Installation de $1...\n"
		mas search "$1" | { read app_ident app_name ; mas install $app_ident ; }
	fi
}


function brewinstall (){
	# Check if the App is already installed
	brew list | grep -i "$1" > /dev/null

	if [ "$?" == 0 ]; then
		printf "==> \e[32m [Info] \e[0m $1 est déjà installée\n"
	else
		printf "==> Installation de $1...\n"
		brew install "$1" 
	fi
}


function caskinstall (){
	# Check if the App is already installed
	brew cask list | grep -i "$1" > /dev/null

	if [ "$?" == 0 ]; then
		printf "==> \e[32m [Info] \e[0m $1 est déjà installée\n"
	else
		printf "==> Installation de $1...\n"
		brew cask install "$1" 
	fi
}



## Utilitaires pour les autres apps : Cask et mas (Mac App Store)
echo 'Installation de mas, pour installer les apps du Mac App Store.'
brewinstall mas

mas account | grep -i "Not signed in" > /dev/null

if [ "$?" == 0 ]; then
	echo "Saisir le mail du compte iTunes :" 
	read COMPTE
	mas signin $COMPTE
fi


echo 'Installation de Cask, pour installer les autres apps.'
brew tap caskroom/cask

# Vérifier que tout est bien à jour
brew update

printf "\e[32m [Info] \e[0m $1 Installation des outils de developpement ? [Y/n] : "
read ANSWER_DEV


if [ $ANSWER_DEV == "Y" ]; then
	echo 'Installation des apps : développement.'
	caskinstall iterm2
	caskinstall sequel-pro
	caskinstall textmate
	caskinstall sublime-text
	caskinstall sourcetree
	install "Xcode"
	caskinstall transmit
	caskinstall phpstorm
	caskinstall sqlpro-for-mssql
fi



printf "\e[32m [Info] \e[0m $1 Installation de l'ecosystème php ? [Y/n] : "
read ANSWER_PHP

if [ $ANSWER_PHP == "Y" ]; then
	echo "Installation de l'ecosystème php."
		
	echo "Installation d'extension Brew"
	brew tap homebrew/dupes
	brew tap homebrew/versions
	brew tap homebrew/php
	brew tap homebrew/apache

	brew update
	
	# Dev
	brewinstall wget
	brewinstall composer
	
	
	brewinstall dnsmasq
	echo "Configuration de DNSMASK."
	
	if [ -f "/usr/local/etc/dnsmasq.conf" ];
	then
	   rm /usr/local/etc/my_dnsmasq.conf
	fi
	
	echo 'address=/.lan/127.0.0.1' > /usr/local/etc/dnsmasq.conf
	
	if [ -f "/etc/resolver/lan" ];
	then
	   rm /etc/resolver/lan
	fi

	sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/lan'
	
	sudo brew services restart dnsmasq
	
	sudo apachectl stop
	sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
	brew install httpd24 --with-privileged-ports --with-http2
	
	#Installation PHP
	brewinstall php56 --with-httpd24
	brewinstall php56-opcache
	brewinstall php56-apcu
	brewinstall php56-yaml
	brewinstall php56-xdebug
	brewinstall php56-imagick
	brewinstall php56-intl
	brewinstall php56-mcrypt
	brewinstall php56-memcached
	brewinstall php56-pdo-dblib
	brew unlink php56
	
	brewinstall php70 --with-httpd24
	brewinstall php70-opcache
	brewinstall php70-apcu
	brewinstall php70-yaml
	brewinstall php70-xdebug
	brewinstall php70-imagick
	brewinstall php70-intl
	brewinstall php70-mcrypt
	brewinstall --HEAD homebrew/php/php70-memcached
	brewinstall php70-pdo-dblib
	
	brew install xdebug-osx

	brewinstall elasticsearch@2.4
	brewinstall imagemagick
	brewinstall mariadb
	mysql_install_db
	mysql.server start
	brewinstall mcrypt
	brewinstall node

	npm install -g less
	
	#Installation PHPSwitcher
	curl -L https://gist.github.com/w00fz/142b6b19750ea6979137b963df959d11/raw > /usr/local/bin/sphp
	chmod +x /usr/local/bin/sphp
fi



echo "Installation des apps Google."
caskinstall google-chrome
caskinstall google-drive

echo "Installation de Firefox"
caskinstall firefox

echo "Installation des apps : imagerie."
caskinstall imageoptim
caskinstall adobe-creative-cloud
install "iMovie"
install "Smart Converter Pro 2"


printf "\e[32m [Info] \e[0m $1 Installation des outils Apple ? [Y/n] : "
read ANSWER_APPLE

if [ ANSWER_APPLE == "Y" ]; then
	echo "Installation des apps bureautique"
	install "Pages"
	install "Keynote"
	install "Numbers"
	install "GarageBand"
fi


echo "Installation des utilitaires"
install "Bento"
install "Microsoft Remote Desktop"
install "Memory Clean"
install "Wunderlist"
install "Bear"
caskinstall viscosity 
caskinstall istat-menus
caskinstall aerial
caskinstall transmission
caskinstall skype
caskinstall unrarx


echo "Installation des applications perso"
caskinstall spotify
caskinstall vlc


printf "\e[32m [Info] \e[0m $1 Installation de Play On Mac ? [Y/n] : "
read ANSWER_PLAYONMAC

if [ ANSWER_PLAYONMAC == "Y" ]; then
	echo "Installation de Play On Mac"
	caskinstall playonmac
fi


echo "Configuration des préférences du finder"
# Afficher le dossier maison par défaut
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Finder : affichage de la barre latérale / affichage par défaut en mode liste / affichage chemin accès
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string “Nlsv”
defaults write com.apple.finder ShowPathbar -bool true

# Pas de création de fichiers .DS_STORE
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Photos : pas d'affichage pour les iPhone
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# Recherche dans le dossier en cours par défaut
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"



echo "Brew Cleanup."
brew cleanup
rm -f -r ~/Library/Caches/Homebrew/*


# Preparation xdebug
if [ ! -d ~/tmp/xdebug ]; then
	echo "Préparation Logs Xdebug"
	mkdir -p ~/tmp/xdebug
	chmod 777 ~/tmp/xdebug
else
	printf "\e[32m[Info]\e[0m Xdebug directory ready\n"
fi



## ************ Fin de l'installation *********
echo "Finder et Dock relancés… redémarrage nécessaire pour terminer."
killall Dock
killall Finder


printf "==> \e[32m [DONE] \e[0m $1 ET VOILÀ !\n"
