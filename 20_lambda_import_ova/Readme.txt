1) Creer un bucket S3 pour y mettre les 2 fonctions lambda (si pas déjà créer).
   
   import_ova.zip
   check_import_status.zip

2) Changer dans le variables.tf les bucket source des 2 fonctions lambda avec le nom du bucket (1)

    "${var.bucket_lambda}"

  
   Changer l'addresse mail dans variable pour les notifications SNS
   Changer le nom du bucket d'import dans variables.tf suivant l'environnement cible (respect des naming conventions) 

3) Lancer le script terraform pour la creation des roles / bucket d'import OVA / permissions / creation lambdas

4) Donner les droits au role User (getBucketlist, putobject...) sur le bucket import des différents univers


Pour tester:

- S'assurer que l'email a été trusté dans SNS
- S'assurer que les users cibles (role user?) ont les droits d'upload dans le bucket d'import d'OVA
- Demander à télécharger un fichier .OVA dans le bucket d'import via la console

Jeremy CANALE