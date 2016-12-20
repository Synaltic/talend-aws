# ansible permettant d'installer la tac de dev avec tous ces modules. Les sources à installer se trouvent dans le bucket S3 applications.dev. Il faut donc des crédentials.

Prérequis : 
 - CentOs 6.X ou 7
 - Pouvoir executer des ansibles
 - pip installé
 
Eléments installés :
 - Oracle java JDK 8u101
 - Mysql Server 5.7
 - Talend Administration 6.2.1
 - Nexus Repository
 
Paramètres : 
 - AWS_ACCESS_KEY : clé d'accès AWS
 - AWS_SECRET_KEY : mot de passe AWS
 - MYSQL_DEFAULT_PASSWORD : (facultatif) mot de passe souhaité pour le compte root mysql. Attention le mysql s'installant est un mysql 5.7 avec une politique de mot de passe : 8 caractères minimum, 1 caractère spécial, 1 chiffre, 1 majuscule. Si ce paramètre n'est pas passé à l'exécution le mot de passe par défaut est root4Talend!
 
Exemple de lancement : 
ansible-playbook -e 'AWS_ACCESS_KEY=YOURACCESSKEY AWS_SECRET_KEY=YOURSECRETKEY MYSQL_DEFAULT_PASSWORD=root4Talend!' playbook-tac621.yml 