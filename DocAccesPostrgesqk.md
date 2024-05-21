# Documentation pour gérer et vérifier les droits d'accès aux bases de données PostgreSQL.

## Script pour Accorder les Droits de Lecture

grant_read_access.sh

### Description
Ce script accorde des droits de lecture à un utilisateur spécifié sur toutes les bases de données contenant un schéma public dans un serveur PostgreSQL.

### Prérequis
PostgreSQL doit être installé sur le système où le script est exécuté.
L'utilisateur exécutant le script doit avoir les privilèges nécessaires pour accorder des droits sur les bases de données.
Utilisation
Sauvegardez le script dans un fichier nommé grant_read_access.sh.
Rendez le script exécutable avec la commande :
```
chmod +x grant_read_access.sh
```

Exécutez le script en tapant :
```
./grant_read_access.sh
````

Suivez les instructions à l'écran pour entrer les informations de connexion et le nom de l'utilisateur à qui accorder les droits.



## Script pour Vérifier les Droits de Lecture

verify_read_access.sh

### Description
Ce script vérifie les droits de lecture de l'utilisateur sur toutes les bases de données avec un schéma public dans un serveur PostgreSQL, en tentant de récupérer une ligne de chaque table.

### Prérequis
PostgreSQL doit être installé sur le système où le script est exécuté.
L'utilisateur exécutant le script doit avoir accès en lecture aux bases de données qu'il souhaite vérifier.

### Utilisation
Sauvegardez le script dans un fichier nommé verify_read_access.sh.
Rendez le script exécutable avec la commande :
```
chmod +x verify_read_access.sh
````

### Exécutez le script en tapant :

./verify_read_access.sh

Suivez les instructions à l'écran pour entrer les informations de connexion.
