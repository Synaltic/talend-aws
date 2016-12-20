# ansible permettant d'installer la tac de dev avec tous ces modules. Les sources � installer se trouvent dans le bucket S3 applications.dev. Il faut donc des cr�dentials.

Pr�requis : 
 - CentOs 6.X ou 7
 - Pouvoir executer des ansibles
 - pip install�
 
El�ments install�s :
 - Oracle java JDK 8u101
 - Mysql Server 5.7
 - Talend Administration 6.2.1
 - Nexus Repository
 
Param�tres : 
 - AWS_ACCESS_KEY : cl� d'acc�s AWS
 - AWS_SECRET_KEY : mot de passe AWS
 - MYSQL_DEFAULT_PASSWORD : (facultatif) mot de passe souhait� pour le compte root mysql. Attention le mysql s'installant est un mysql 5.7 avec une politique de mot de passe : 8 caract�res minimum, 1 caract�re sp�cial, 1 chiffre, 1 majuscule. Si ce param�tre n'est pas pass� � l'ex�cution le mot de passe par d�faut est root4Talend!
 
Exemple de lancement : 
ansible-playbook -e 'AWS_ACCESS_KEY=YOURACCESSKEY AWS_SECRET_KEY=YOURSECRETKEY MYSQL_DEFAULT_PASSWORD=root4Talend!' playbook-tac621.yml 