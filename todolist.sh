#!/bin/bash

read -p "quel est le nom de votre liste: " fichier
echo ""
if ! [ -d les_listes ];then
	mkdir les_listes
fi
nom="${PWD}/les_listes/${fichier}" # Le nom de la TodoList courante
if ! [ -e ${nom} ];then
	touch ${nom}
fi
faite="${PWD}/les_listes/faite" #La liste qui fait du bien 
help="${PWD}/help" #La page manuel de notre script
read -p "Todo --" op
echo ""
while [ "$op" != "quitter" ] ; do
	case $op in
	   *aj*) #ajouter des entrées dans la liste
			echo " "
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				read -p "Ajouter la tâche " tach
				echo "$tach -- ajoutée le $(date "+%A %x à %T ")" >> $nom
				echo " -- $tach -- added" 
			fi;;
		*sup*) #supprimer des entrées de la liste
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				if [ $( cat ${nom} | wc -l ) = "0" ];then
					echo "Rien à supprimer!"
				else
					echo " "
					cat -n $nom
					echo""
					read -p "Quel est le numero de la ligne que vous voulez supprimée: " num
					while [ -z ${num} ];do #tant que la variable numero est vide
						echo "IL FAUT TAPER UN NUMERO!"
						read -p "Quel est le numero de la ligne que vous voulez supprimée: " num
					done
					while [ $( cat ${nom} | wc -l ) -lt "${num}" ];do
						#tant que le numero de la ligne selectionnée est superieur au nombre total des lignes
						echo "Ligne inexistante!"
						read -p "Quel est le numero de la ligne que vous voulez supprimée: " num
					done
					echo "--> $( sed -n "$num p" $nom) a été faite le $(date "+%A %x à %T ")" >> ${faite}
					echo " -- $( sed -n "$num p" $nom) -- a été supprimé"
					sed -i "$num d" $nom 
				fi
			fi;;
		*res*) #supprimer toutes les tâches de la liste directement sans passer par la liste du bien.
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				read -p "Êtes-vous sûr de vouloir tout supprimer? (o/n)->: " answer
				if [ ${answer} = "o" ];then
					sed -i "/?*/d" $nom
					echo ""
					echo "-----Tout est supprimé-----" 
				else
					echo "-----le contenu n'a pas été supprimé.-----"
				fi
			fi;;
		*addtolist*) #ajouter une tâche dans une liste sans y être
			ls ${PWD}/les_listes
			echo "------------------------"
			read -p "Ajouter dans quelle liste? : " lst
			if ! [ -r ${PWD}/les_listes/${lst} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				read -p "Tâche à ajouter => " string
				echo "${string}-- ajoutée le $(date "+%A %x à %T ")" >> ${PWD}/les_listes/${lst}
				echo " -- ${string} -- added" 
				#si la liste n'existe pas, elle sera créée
			fi;;
		*aff*) #Afficher le contenu de la liste
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				if [ $( grep -c ".*" $nom ) -eq 0 ];then
					echo "_____________"
					echo "|total : 0 |"
					echo "-------------"
					echo "aucune tâche à afficher!"
					echo "-------------"
					echo " "
				else 
					echo "_____________"
					echo "|total : $( grep -c ".*" $nom)|"
					echo "-------------"
					cat -n $nom
					echo "-------------"
					echo " "
				fi 
			fi;;
		*fait*) #La liste du bien
 			if [ ! -e ${faite} ] ;then
				echo "le fichier fait n'est pas encore crée" 
			else 
				cat ${faite} 
			fi ;;
		*newlist*) #creer une nouvelle liste
			read -p "Quel est le nom de la nouvelle liste " namelist
			touch ${namelist}
			mv ${namelist} ${PWD}/les_listes 
			nom="${PWD}/les_listes/${namelist}"
			echo "-----Vous êtes dans la liste ${nameliste}-----";;
		*change*list*)  #changement de la Todolist courante
			ls ${PWD}/les_listes
			echo ""
			read -p "Accéder à la liste :" nameof
			if ! [ -r ${PWD}/les_listes/${nameof} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				nom="${PWD}/les_listes/${nameof}"
				echo"" 
				echo "Vous êtes actuellement dans la Todolist ${nameof}"
			fi;;
		*rename*) #renommer la liste courant
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				read -p "Le nouveau nom de la liste: " rename
				mv ${nom} ${PWD}/les_listes/${rename} 
				nom=${PWD}/les_listes/${rename}
				echo ""
				echo "----${fichier} a été renommé en ${rename}----"
			fi;;	
		*catlist*) #afficher le contenu d'une liste
			ls ${PWD}/les_listes
			echo ""
			read -p "choisissez une Todolist ->: " name
			namebis="${PWD}/les_listes/${name}"
			if ! [ -r ${namebis} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				echo ""
				echo "----------${name}----------"
				echo "|total : $( grep -c ".*" ${namebis})|"
				cat -n ${namebis}
				echo "---------------------------"
				echo ""
			fi;;
		*crypt*) #crypter une Todolist avec un mot de passe
			echo ""
			ls ${PWD}/les_listes
			echo "-----------------------------------------"
			read -p "Choisir la liste à crypter:  " crplist
			if [ -r ${PWD}/les_listes/${crplist} ];then
				read -s -p "saisir le mot de passe: " mdp; echo
				# -s permet de ne pas afficher le mot de passe
				# echo pour un saut de ligne
				if [ -e ${PWD}/les_listes/.mm ];then
					chmod 644 ${PWD}/les_listes/.mm
				else
					touch ${PWD}/les_listes/.mm
				fi
				echo "${crplist}=${mdp}" >> ${PWD}/les_listes/.mm
				#le fichier .mm contient les mots de passe et il est invisible
				chmod 0 ${PWD}/les_listes/.mm
				#protéger le fichier .mm
				chmod 0 "${PWD}/les_listes/${crplist}"
				echo "----La Todolist ${crplist} a été protégé----"
			else
				echo "----${crplist} est déjà cryptée!----"
			fi;;
		*decrypt*) #décrypter une Todolist
			echo ""
			ls ${PWD}/les_listes
			echo "-----------------------------------------"
			read -p "Choisir la liste à décrypter:  " crplist
			if ! [ -e ${PWD}/les_listes/${crplist} ];then
				echo "Cette liste n'existe pas"
			else
				if [ -r ${PWD}/les_listes/${crplist} ];then
					echo "Cette liste n'est pas cryptée!"
				else
					read -s -p "Saisir le mot de passe: " mdpbis; echo
					chmod 644 ${PWD}/les_listes/.mm
					recup=$( grep "${crplist}" ${PWD}/les_listes/.mm | cut -d= -f2 )
					while [[ ${mdpbis} != ${recup} ]];do
						echo "MOT DE PASSE INCORRECT!!"
						read -s -p "Saisir le mot de passe: " mdpbis; echo
					done
					echo "mot de passe valide"
					chmod 644 "${PWD}/les_listes/${crplist}"
					echo "----${crplist} a été décrypté----"
					sed -i "/${crplist}/d" ${PWD}/les_listes/.mm
					chmod 0 ${PWD}/les_listes/.mm #re-protéger le fichier des MDP
				fi
			fi;;
		*delet*list*) #supprimer une Todoliste
			ls ${PWD}/les_listes
			echo ""
			read -p "Le nom de la Todolist à supprimer " nlist
			nlistbis="${PWD}/les_listes/${nlist}"
			if ! [ -r ${nlistbis} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				if [ $( grep -c ".*" ${nlistbis} ) = "0" ];then #si la liste est vide, on la supprime directement
					rm ${nlistbis}
					echo "----La liste ${nlist} a été supprimée----"
				else
					read -p "La liste n'est pas vide, êtes-vous sûr de vouloir la supprimer?: (o/n)" reponse
					if [ ${reponse} = "n" ];then
						echo ""
						echo "----La liste ${nlist} n'a pas été supprimée----"
					elif [ ${reponse} = "o" ];then
						echo ""
						rm ${nlistbis}
						echo "----La liste ${nlist} a été supprimée----"
					fi
				fi
			fi;;
		*show*) #Afficher les titres de toutes les Todolists
				if [ $(ls ${PWD}/les_listes | wc -w) = "0" ];then
					echo "vous avez aucune liste de tâches!!"
				else
					echo "____________"	
					echo "total : $( ls ${PWD}/les_listes | wc -w )"
					echo "____________"
					ls ${PWD}/les_listes
					echo "_____________________________________________"
					echo "(pour afficher le contenu d'une liste utilisez la commande \"catlist\") "
				fi;;
		*vide*) #Vider le contenu de la liste qui fait du bien
			read -p "etes-vous sur de vouloir vider la liste du bien?(o\n)" opb
			if [ ${opb} = "o" ] ; then
				rm ${faite} #on la supprime et après elle sera recrée automatiquement lors de l'ajout
				echo ""
				echo "-----la liste fait a été vidé!-----"	
			elif [ ${opb} = "n" ] ; then
				echo ""
				echo "voici la liste du bien"
				echo ""
				cat -n ${faite} #sinon on l'affiche
			fi ;;
		*cher*) #faire référence à une tâche par une partie du texte
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: decrypte "
			else
				read -p "entrez un mot: " mot 
				nb=$( cut -d - -f1 ${nom} | grep -n "$mot" | wc -l ) #nombre de lignes contenant la chaîne
				if [ ${nb} -eq 0 ];then
					echo "Lignes correspondantes: 0 !!"
				else		
					echo ""
					echo "----|total: ${nb}|-------------"
					for i in $( eval echo {1..$nb} );do
					#eval permet de bien interpréter la commande
						var=$( cut -d - -f1 ${nom} | grep -n "${mot}" | cut -d : -f1 | sed -n "${i}p" )
						sed -n "${var}p" ${nom}
					done
					echo "-------------------------------"
				fi
			fi;;
		*comment*) #ajouter un commentaire à une tâche
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				if [ $( cat ${nom} | wc -l ) = "0" ];then
					echo ""
					echo "Aucune tâche à commenter!" 
				else
					echo ""
					cat -n $nom
					echo "______________________"
					read -p "Quelle ligne voulez-vous commenter ? " numero
					while [ -z ${numero} ];do #tant que la variable numero est vide
						echo "IL FAUT TAPER UN NUMERO!"
						read -p "Quelle ligne voulez-vous commenter ? " numero
					done
					while [ $( cat ${nom} | wc -l ) -lt "${numero}" ];do
						#tant que le numero de la ligne selectionnée est superieur au nombre total des lignes
						echo "ligne inexistante!"
						read -p "Quelle ligne voulez-vous commenter ? " numero
					done
					read -p "Le commentaire: " comm 
					res=$( sed -n "${numero}p" ${nom} )
					sed -i "$numero d" $nom	
					sed -i "${numero}i ${res}=>(${comm})" ${nom}	
					echo "-----Commentaire ajouté----------"
				fi	
			fi;;
		*deletecom*) #supprimer un commentaire
			#si on a plusieurs commentaires, elle supprime tous
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				if [ $( cat ${nom} | wc -l ) = "0" ];then
					echo ""
					echo "Aucun commentaire à supprimer!"
				else
					echo ""
					cat -n $nom
					echo "______________________"
					read -p "quel commentaire voulez-vous supprimer ? " numero
					while [ -z ${numero} ];do #tant que la variable numero est vide
						echo "IL FAUT TAPER UN NUMERO!"
						read -p "quel commentaire voulez-vous supprimer ? " numero
					done
					while [ $( cat ${nom} | wc -l ) -lt "${numero}" ];do
						#tant que le numero de la ligne selectionnée est superieur au nombre total des lignes
						echo "Ligne inexistante!"
						read -p "quel commentaire voulez-vous supprimer ? " numero
					done
					test=$( sed -n "${numero}p" ${nom} | grep "=>" )
					#test si la tâch contient un commentaire
					if [[ -z ${test} ]];then
						echo "La ligne ${numero} ne contient pas de commentaire!"
					else
						if [ "$numero" -eq $( grep -c ".*" $nom) ] ; then
							echo "une ligne supplementaire temporaire" >> $nom 
					# ajouter un ligne supp pour que sed insert au desssus d'elle
							phrase=$(sed -n "${numero}p" ${nom} | cut -d= -f1)	
							sed -i "${numero}d" ${nom}	
							sed -i "${numero}i ${phrase}" ${nom}  
					#l'option (i) pour inserer la ligne à la place où elle était	
							sed -i "$( grep -c ".*" ${nom} )d" ${nom} 
						#suppression de la ligne temporaire
							echo "-----commentaire supprimé----------"
						else
							phrase=$(sed -n "${numero}p" ${nom} | cut -d= -f1)
							sed -i "$numero d" $nom
							sed -i "${numero}i ${phrase}" ${nom}
							echo "-----commentaire supprimé----------"
						fi
					fi
				fi
			fi;;
		*mod*) #Modifier le texte d'une tâche
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				echo ""
				cat -n $nom
				echo ""
				read -p "Quelle ligne vous voulez modifier: " num 
				echo "La ligne concernée est : $( sed -n "$num p" $nom)"
				read -p "Modification " mod
				if [ "$num" -eq $( grep -c ".*" $nom) ] ; then
						echo "une ligne supplementaire " >> ${nom}
			# permet à sed d'ajouter une ligne supplementaire "	
						sed -i "$num d" $nom
						sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+$(grep -c "^C " $nom)+$(grep -c "^D " $nom)+1)) i $mod -- a été modifiée le $(date "+%A %x à %T ")" $nom
						sed -i "$( grep -c ".*" $nom) d" $nom
				else
					sed -i "$num d" $nom
						sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+$(grep -c "^C " $nom)+$(grep -c "^D " $nom)+1)) i $mod a été modifiée le $(date "+%A %x à %T ")" $nom
				 fi 
			fi;;
		*pri*) #Donner une priorité à une tâche
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				echo ""
				cat -n $nom
				echo ""
				read -p "Quel est le numero de la ligne que vous voulez priorisée: " num
				if [ "$num" -le $( grep -c ".*" $nom) ] ; then
					read -p "le niveau d'importance (A/a) ou (B/b) ou (C/c) ou (D/d) : " niv
					sed -in "$num s/^[ABCD]//" $nom
					sed -in "$num s/^ //" $nom
					while [ $niv != "A" ] && [ $niv != "a" ] && [ $niv != "B" ] && [ $niv != "b" ] && [ $niv != "C" ] &&[ $niv != "c" ] &&[ $niv != "D" ] && [ $niv != "d" ];do
						echo "veuillez choisir entre A/a, B/b, C/c et D/d"
						read -p "le niveau d'importance (A/a) ou (B/b) ou (C/c) ou (D/d) : " niv
					done
					case $niv in
						A|a ) phrase="A $(sed -n "$num p" $nom)"
							echo "$phrase -- has prioritized"
							if [ "$num" -eq $( grep -c ".*" $nom) ] ; then
								echo "une ligne supplementaire " >> ${nom}
					# permet à sed d'ajouter une ligne supplementaire "	
								sed -i "$num d" $nom
								sed -i "1 i $phrase" $nom
								sed -i "$( grep -c ".*" $nom) d" $nom
							else
								sed -i "$num d" $nom
								sed -i "1 i $phrase" $nom 
							fi ;;
						B|b) phrase="B $(sed -n "$num p" $nom)"
							echo "$phrase -- has prioritized"
							if [ "$num" -eq $( grep -c ".*" $nom) ] ; then
								echo "une ligne supplementaire " >> ${nom}
					# permet à sed d'ajouter une ligne supplementaire "	
								sed -i "$num d" $nom
								sed -i "$(($(grep -c "^A " $nom)+1)) i $phrase" $nom
								sed -i "$( grep -c ".*" $nom) d" $nom
							else
								sed -i "$num d" $nom
								sed -i "$(($(grep -c "^A " $nom)+1)) i $phrase" $nom 
							fi ;;
						C|c) phrase="C $(sed -n "$num p" $nom)"
							echo "$phrase -- has prioritized"
							if [ "$num" -eq $( grep -c ".*" $nom) ] ; then
								echo "une ligne supplementaire " >> ${nom}
					# permet à sed d'ajouter une ligne supplementaire "	
								sed -i "$num d" $nom
								sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+1)) i $phrase" $nom
								sed -i "$( grep -c ".*" $nom) d" $nom
							else
								sed -i "$num d" $nom
								sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+1)) i $phrase" $nom 
							fi ;;
						D|d) phrase="D $(sed -n "$num p" $nom)"
							echo "$phrase -- has prioritized"
							if [ "$num" -eq $( grep -c ".*" $nom) ] ; then
								echo "une ligne supplementaire " >> ${nom}
					# permet à sed d'ajouter une ligne supplementaire "
								sed -i "$num d" $nom 
								sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+$(grep -c "^C " $nom)+1)) i $phrase" $nom
								sed -i "$( grep -c ".*" $nom) d" $nom
							else
								sed -i "$num d" $nom 
								sed -i "$(($(grep -c "^A " $nom)+$(grep -c "^B " $nom)+$(grep -c "^C " $nom)+1)) i $phrase" $nom
							fi ;;	
					esac
				else
					echo "cette tâche n'existe pas !!"
				fi 
			fi;;
		*auto*) #supprimer des tâches avec un délai précis
			if ! [ -r ${nom} ];then
				echo ""
				echo "Cette liste est protégée!"
				echo "------------pour l'ouvrir utiliser: --decrypte "
			else
				cat -n $nom
				echo ""
				read -p "quel est le numero de la ligne que vous voulez supprimer avec un délai: " num
				if [ $num -gt $(grep -c ".*" $nom) ] ; then 
					echo "cette ligne n'existe pas!"
				else
					read -p "veuillez entrez le mois (1-12): " mois
					read -p "veuillez entrez le jour (1-31): " jour
					read -p "veuillez entrez l'heure (00-23): " heure
					read -p "veuillez entrez la munite (1-59): " minute
					echo "la tache -- $(sed -n "$num p" $nom) -- sera supprimer le $jour/$mois à $heure:$minute"
					sed -i "$num i $(sed -n "$num p" $nom) -- sera supprimer le $jour/$mois à $heure:$minute" $nom
					sed -i "$(($num+1)) d" $nom 
					crontab < <(crontab -l ; echo "$minute $heure $jour $mois 0 sed -i \"\$(grep -n \"sera supprimer le $jour/$mois à $heure:$minute\" $nom | cut -d: -f1) d\" $nom" )
				fi 
			fi;;
		*help*) #La page d'aide du programme
			less ${help};;
	esac
	echo ""
	read -p "Todo --" op
	echo ""
done
