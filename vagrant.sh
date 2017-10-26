#!/bin/bash

clear

stop='\033[00m '
bleu='\033[34m'
rouge='\033[31m'

#Variable qui permet de stocker le path lors d'execution du script
pathBox=$(pwd)

#Function qui permet de se déplacer dans les dossiers
function moove () {
  read -p "Dans quel dossier voulez-vous vous diriger ? (.. pour revenir en arrière) : " dos
  echo -e "${bleu}=========================${stop}"
  if [ -d "./"$dos ]
  then
    cd $dos
    echo "Nouveau path : "; pwd
    echo -e "${bleu}=========================${stop}"
    echo "Contenue du dossier actuel : "; ls
    echo -e "${bleu}=========================${stop}"
  else
    echo -e "${rouge}Dossier non valide${stop}"
  fi
}

#On boucle sur le programme tant que l'utilisateur n'écrit pas "stop"
while [ "$action" != "stop" ]
do
  read -p 'Quelle action voulez-vous réaliser ?
1- Création vagrant file
2- Lancer la vagrant et se connecter
3- Arreter la vagrant en cours
4- Consulter les vagrants allumé
5- "stop" pour arreter
=====> ' action
  case "$action" in
    1)
    #On affiche le path actuel ainsi que les dossiers présents dans le répertoire courant
    echo -e "${bleu}=========================${stop}"
    echo "Path :"; pwd
    echo -e "${bleu}=========================${stop}"
    echo "Contenue dossier courant : "; ls
    echo -e "${bleu}=========================${stop}"
    while [ "$vagrantDir" != "y" ]
    do
      #demande si on crée le dossier dans le répertoire courant, si non -> boucle sur la function moove, sinon passe à la suite
      read -p "Vous allez devoir créer un dossier, le créer dans le répertoire courant? (y/n)
" vagrantDir;
      if [ "$vagrantDir" == "n" ]
      then
        moove
      elif [ "$vagrantDir" == "y" ]
      then
        break;
      else
        echo -e "${bleu}=========================${stop}"
        echo -e "${rouge}Je n'ai pas compris${stop}"
        echo -e "${bleu}=========================${stop}"
      fi
    done
    vagrantDir=''
    read -p "Nom du dossier ? " Dir
    #On regarde si le dossier existe déjà
    if [ -d "./"$Dir ]
    then
      echo -e "${bleu}=========================${stop}"
      echo -e "${rouge}Impossible. Ce dossier existe déjà !${stop}"
      echo -e "${bleu}=========================${stop}"
    #On regarde si l'input possède un espace dedans ou non
    elif [[ "$Dir" =~ \s ]]
    then
      #s'il n'exite pas, on le crée et on init la vagrant
      mkdir $Dir 2>> $pathBox/errors.log
      cd $Dir
      vagrant init 1> /dev/null && 2>>errors.log
      echo -e "${bleu}=========================${stop}"
      echo "Dossier et vagrantFile crées !"
      echo -e "${bleu}=========================${stop}"
      read -p "Choisissez votre box (taper le nom du fichier) :
1- tapez xenial.box
2- tapez xenial.box
====> " box
      #On déplace la box dans le répertoire actuel
      mv $pathBox/$box $box 2>> $pathBox/errors.log || echo "la box n'est pas trouvable"
      #On modifie le vagrantfile en fction des inputs utilisateur
      sed -i "s/base/$box/g" Vagrantfile
      read -p "Choisissez le nom du dossier qui contiendra vos fichiers : " dos
      sed -i "s|../data|$dos|g" Vagrantfile
      mkdir $dos
      sed -i "/private_network/s/^  # /  /g" Vagrantfile
      sed -i "/vagrant_data/s/^  # /  /g" Vagrantfile
      read -p "Choisissez le path des sync files (le premier / est ajouté tout seul): " sync
      sed -i "s|vagrant_data|$sync|g" Vagrantfile
    else
      echo -e "${bleu}=========================${stop}"
      echo -e "${rouge}Non de dossier non valide !${stop}"
      echo -e "${bleu}=========================${stop}"
    fi
    ;;

    2)
    echo -e "${bleu}=========================${stop}"
    vagrant up 2>> $pathBox/errors.log || echo -e "${rouge}??? Aucune box vagrante n'a été configurée, veuillez choisir le menu 1${stop}" && vagrant ssh 2> /dev/null
    echo -e "${bleu}=========================${stop}"
    ;;

    3)
    echo -e "${bleu}=========================${stop}"
    read -p "Quel est le path de la vagrante à arrêter ? (à partir de /home) : " path
    cd $path 2>> $pathBox/errors.log || echo -e "${rouge}Ce path n'existe pas${stop}"
    vagrant halt 2>> $pathBox/errors.log && echo "Vagrant éteinte" || echo -e "${rouge}Erreur lors du shutdown de la vagrante${stop}"
    echo -e "${bleu}=========================${stop}"
    ;;

    4)
    echo -e "${bleu}=========================${stop}"
    vagrant global-status 2>> /dev/null
    echo -e "${bleu}=========================${stop}"
    ;;

    *)
    echo -e "${bleu}=========================${stop}"
    echo -e "${rouge}Action invalide${stop}"
    echo -e "${bleu}=========================${stop}"
    ;;
  esac
done
