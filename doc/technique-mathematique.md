# Technique mathématique

*Promis, pas de quoi se noyer dans les équations.*

Chaque thon ne regarde que ses voisins proches (dans un rayon R, sauf juste derrière lui : il n'a pas d'yeux dans le dos, c'est un thon, pas un hibou). À chaque instant, il additionne 4 forces :

1. **Séparation** : s'écarter des voisins trop proches, pour ne pas se cogner. Chacun son espace vital, même en boîte.
2. **Alignement** : nager dans la même direction que ses voisins. Suivre le mouvement, c'est tout un art.
3. **Cohésion** : se rapprocher du centre de ses voisins. C'est elle qui reforme le banc après l'obstacle : l'union fait la force (et le banc).
4. **Évitement** : fuir un obstacle (algues, prédateur) quand il est proche. Plus il est près, plus la force est forte. Sauve qui peut !

Chaque force a un poids (réglable avec un curseur). La vitesse du thon reste entre un minimum et un maximum : pas de thon au point mort, pas de thon supersonique. Tous les thons bougent en même temps.

## Deux mesures

- **Alignement du banc** : entre 0 (chacun va dans son sens, c'est la foire aux thons) et 1 (tout le monde va dans la même direction).
- **Nombre de sous-groupes** : combien de petits bancs séparés il y a.

Le banc est « reformé » quand il ne reste qu'un seul groupe bien aligné (alignement au-dessus de 0,9). On mesure combien de temps ça prend après le passage de l'obstacle : le temps de se remettre de ses émotions.
