#!/bin/sh
#variable à modifier en fonction de l'emplacement du job serveur
PATH_JOBS="/opt/jobserver/Talend-JobServer-20160704_1411-V6.2.1/TalendJobServersFiles/repository/"

getLatestTalendJob()
{
        job=$1
        currentDir=$PATH_JOBS
        lastrun=$(find ${currentDir} -type f -name ${job}"_run.sh" | sort -r |head -n1)
        echo ${lastrun}
}

JOB_TO_LAUNCH=$(getLatestTalendJob $1)
if [ -n "$JOB_TO_LAUNCH"  ]
then
	echo "derniere version trouvée pour " $1 " : " $JOB_TO_LAUNCH
#on passe en parametre au job tous les parametres du script sauf le premier
	sh $JOB_TO_LAUNCH ${@: 2}
else
#on envoie sur stderr un message dans le cas où on ne trouve pas le job
	echo >&2 "impossible de trouver le job " $1
	exit 1
fi
