# Utilisation de packer pour créer une AMI

## Installation de Packer (Linux ou MacOS)
Voir la documentation ici : https://packer.io/intro/getting-started/setup.html

## Création d'une AMI
se munir de ses crédentials pour le compte de DEV.
packer build -var 'aws_access_key=Your_Access_Key' -var 'aws_secret_key=Your_Secret_Key' packer-stats.json


