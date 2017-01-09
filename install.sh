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


echo "Saisir le mail du compte iTunes :" 
read COMPTE
echo "Saisir le mot de passe du compte : $COMPTE"
read PASSWORD
mas signin $COMPTE "$PASSWORD"




echo 'Installation de Cask, pour installer les autres apps.'
brew tap caskroom/cask

echo "Installation d'extension Brew"
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/php
brew tap homebrew/apache

# Vérifier que tout est bien à jour
brew update


echo 'Installation des apps : développement.'
caskinstall iterm2 
caskinstall textmate
caskinstall transmit
caskinstall viscosity 
caskinstall istat-menus
caskinstall aerial
caskinstall transmission
install "Xcode"

echo "Installation des apps Google."
caskinstall google-chrome
caskinstall google-drive

echo "Installation des apps : imagerie."
caskinstall imageoptim
caskinstall adobe-creative-cloud
install "iMovie"
install "Smart Converter Pro 2"

echo "Installation des apps bureautique"
install "Pages"
install "Keynote"
install "Numbers"
install "GarageBand"

echo "Installation des utiliataires"
install "Bento"
install "Microsoft Remote Desktop"
install "Memory Clean"
install "Wunderlist"
install "Bear"


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



# Dev
brewinstall wget
brewinstall composer
brewinstall dnsmasq
brewinstall elasticsearch@2.4
brewinstall imagemagick
brewinstall mariadb
brewinstall mcrypt
brewinstall node


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

