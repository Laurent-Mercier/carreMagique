# Auteur: Laurent Mercier (laurent.mercier@umontreal.ca)
# Date: 31 mars 2024.
#
# Ce programme demande à l'utilisateur de rentrer des valeurs de 1 à n^2, 
# où n^2 est le nombre d'éléments dans la matrice (matrice carrée nxn) et 
# détermine si la matrice forme un carré magique, c'est à dire que la somme des
# éléments dans chaque rangée, dans chaque colonne, dans chaque diagonale et 
# dans les 4 coins est la même. 

################################################################################
# Segment de la mémoire contenant les données globales.
.data 

################################################################################
# On définit les messages que l'on veut communiquer à l'utilisateur.
msgEntrezColonnesRangees: 
.asciiz "Entrez le nombre de colonnes/rangées de la matrice à vérifier : "
msgEntrezDonnees: 
.asciiz "Entrez une valeur de 1 à "
msgDonneeNonValide: 
.asciiz "Le nombre entré n'est pas valide. Entrez une valeur de 1 à "
msgDonneeDejaEntree: 
.asciiz "La donnée est déjà entrée! Entrez une autre valeur de 1 à "
msgPonctuation: 
.asciiz " : "
msgEspace: 
.asciiz " "
msgSautDeLigne: 
.asciiz "\n"
msgNonMagique: 
.asciiz "La matrice n'est pas un carré magique!"
msgEstMagique: 
.asciiz "Carré Magique!!! La valeur magique est: "
msgPoint: 
.asciiz "."

################################################################################
# On définit une étiquette qui va contenir l'adresse mémoire de la matrice et 
# une autre pour la matrice de vérification.
adresseMatrice: .word 0
adresseMatriceVerif: .word 0

# On définit des étiquettes qui vont contenir le nombre de colonnes et de lignes 
# de la matrice. On a toujours le même nombre de colonnes et de rangées, avec un 
# maximum de 701 colonnes/rangées. Ce maximum fait une allocation au heap de 
# moins de 3932156 bytes, le maximum permis par le simulateur Mars. Avec 702 
# colonnes/rangées, on est au-delà du maximum. On définit aussi une étiquette 
# qui va contenir le nombre maximal qui peut être entré par l'utilisateur selon 
# la taille de la matrice.
nombreColonnes: .word 0
nombreRangees: .word 0
nombreMaximal: .word 0

# On définit une étiquette qui va contenir l'espace alloué au heap en bytes. 
espaceAlloue: .word 0
 
# On définit une étiquette qui va contenir la valeur magique du carré magique.
valeurMagique: .word 0

# On définit une étiquette qui contient le nombre de colonnes/rangées maximal. 
# Cette valeur nous aidera à ne pas allouer plus d'espace au heap que possible 
# si l'utilisateur entre 702 rangées/colonnes ou plus.
nombreMaxColonnesRangees: .word 701

################################################################################
# Segment de la mémoire contenant le code.
.text

################################################################################
# Fonction principale du programme, on y alloue de l'espace pour les matrices 
# et on entrepose l'adresse du début de la matrice et de la matrice de 
# vérification dans leurs étiquettes correspondantes.
main:

# On demande à l'utilisateur d'entrer le nombre de colonnes/rangées (c'est le 
# même nombre pour les deux, on a une matrice carrée).
li $v0, 4
la $a0, msgEntrezColonnesRangees 
syscall

# L'utilisateur entre un nombre et on vérifie qu'il est entre 1 et 701.
li $v0, 5
syscall 

# On met la valeur 701 dans $s0.
lw $s0, nombreMaxColonnesRangees

################################################################################
# Cette boucle va vérifier que le nombre de colonnes/rangées entré par 
# l'utilisateur est valide, soit entre 1 et 701. Si elle ne l'est pas, on 
# redemande à l'utilisateur d'entrer une valeur jusqu'à ce qu'elle soit valide.
verifTailleMatrice:

addi $t0, $0, 1 # On met la valeur 1 dans $t0.
slt $t0, $v0, $t0

# Si la valeur entrée est plus petite que 1, on saute à l'étiquette 
# colonneRangeePlusPetitQueUn.
bne $t0, $0, colonneRangeePlusPetitQueUn

# On additionne 1 à 701 pour comparer la valeur entrée et vérifier qu'elle est
# plus petite que 702. Si elle l'est, la valeur est valide et on saute à 
# sauverEtiquettes.
addi $t1, $s0, 1
slt $t0, $v0, $t1
bne $t0, $0,  sauverEtiquettes

# On imprime le message pour indiquer que la donnée entrée n'est pas valide. 
li $v0, 4
la $a0, msgDonneeNonValide
syscall 

li $v0, 1
lw $a0, nombreMaxColonnesRangees
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

# On lit le nombre entré par l'utilisateur et il est stocké dans $v0.
li $v0, 5
syscall   

# On revient à l'étiquette verifTailleMatrice pour revérifier la nouvelle valeur 
# entrée par l'utilisateur.
j verifTailleMatrice

################################################################################
# On indique à l'utilisateur que la valeur entrée n'est pas valide et on lui 
# demande d'entrer une autre valeur.
colonneRangeePlusPetitQueUn:

li $v0, 4
la $a0, msgDonneeNonValide
syscall 

li $v0, 1
lw $a0, nombreMaxColonnesRangees
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

# L'utilisateur re-rentre une valeur et on revient à l'étiquette 
# verifTailleMatrice.
li $v0, 5
syscall   

j verifTailleMatrice
################################################################################
# Une fois que le nombre de colonnes/rangées est valide, on définit les valeurs
# utiles au programme en fonction du nombre de colonnes/rangées et on les 
# met dans leur étiquette correspondante.
sauverEtiquettes:

sw $v0, nombreColonnes
sw $v0, nombreRangees

# On multiplie le nombre de colonnes et de rangées pour obtenir le nombre 
# maximal qui peut être entré dans la matrice et on met cette valeur dans 
# nombreMaximal.
lw $t1, nombreColonnes
lw $t2, nombreRangees

mul $t0, $t1, $t2 
sw $t0, nombreMaximal

# On calcule le nombre de bytes à allouer au heap.
addi $t1, $0, 4
lw $t2, nombreMaximal 

mul $t3, $t1, $t2 

addi $t4, $0, 2
mul $t0, $t4, $t3

# On met la valeur de bytes à allouer dans l'étiquette espaceAlloue
sw, $t0, espaceAlloue 

# On alloue un espace de 2*(4*(nombreMaximal)) bytes à l'adresse mémoire du 
# heap (0x10040000), cet espace va contenir notre matrice et la matrice de 
# vérification.
li $v0, 9
lw $a0, espaceAlloue
syscall

# On met l'adresse de l'espace alloué pour la matrice dans l'étiquette 
# adresseMatrice.
sw $v0, adresseMatrice

# On met l'adresse de l'espace alloué pour la matrice de vérification dans 
# l'étiquette adresseMatriceVerif. $t3 contient 4*nombreMaximal, ce qui 
# correspond au nombre de bytes dans la matrice de base, l'adresse de la 
# matrice de vérification est donc juste après ce décalage par rapport à 
# l'adresse de base de la matrice de base.
add $v0, $v0, $t3
sw $v0, adresseMatriceVerif

################################################################################
# On créé la matrice en demandant les valeurs à l'utilisateur une après 
# l'autre. On vérifie que les valeurs n'ont pas déjà été entrées avec la matrice 
# de vérification et on vérifie que la valeur entrée ne dépasse pas le nombre 
# maximal ou soit plus petite que 1.
creerMat:

# On initialise les variables qu'on utilisera lors de la boucle pour entrer les 
# données.
lw $s0, adresseMatrice # $s0 = l'adresse de la matrice de base.
lw $s1, adresseMatriceVerif # $s1 = adresse de la matrice de vérification.
addi $s2, $0, 0 # $s2 = valeur de l'itérateur, initialisée à 0.
lw $s3, nombreMaximal # $s3 = valeur maximale de l'ítérateur.

################################################################################
# Boucle principale qui demande à l'utilisateur d'entrer des valeurs de 1 à 
# nombreMaximal. On fait appel à d'autres boucles pour vérifier la validité des 
# valeurs entrées.
boucleEntrezDonnees:

slt $t0, $s2, $s3 # Est-ce que l'ítérateur est plus petit que son maximum?
beq $t0, $0, afficherMat # Sinon, on sort de la boucle et on affiche la matrice.

# On imprime le message pour entrer les données. On le fait en 3 parties car ce 
# message dépend de la valeur de nombreMaximal.
li $v0, 4
la $a0, msgEntrezDonnees 
syscall 

li $v0, 1
lw $a0, nombreMaximal
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

# On lit le nombre entré par l'utilisateur et il est stocké dans $v0.
li $v0, 5
syscall 

################################################################################
# On vérifie que la valeur entrée par l'utilisateur est valide.
verifDonneeValide:

addi $t0, $0, 1
slt $t1, $v0, $t0

# Si la valeur est plus petite que 1, on saute à l'étiquette plusPetitQueUn.
bne $t1, $0, plusPetitQueUn
addi $t2, $s3, 1 # On met la valeur de $t2 à nombreMaximal+1.

# Est-ce que la valeur entrée est plus petite que nombreMaximal+1?
slt $t0, $v0, $t2
# Si elle l'est, on saute à l'étiquette verifDonneeDejaEntree.
bne $t0, $0, verifDonneeDejaEntree

# On imprime le message pour indiquer que la donnée entrée n'est pas valide.
li $v0, 4
la $a0, msgDonneeNonValide
syscall 

li $v0, 1
lw $a0, nombreMaximal
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

# On lit le nombre entré par l'utilisateur et il est stocké dans $v0.
li $v0, 5
syscall   

# On revient à l'étiquette verifDonneeValide pour revérifier la nouvelle valeur 
# entrée par l'utilisateur.
j verifDonneeValide

################################################################################
# Si la valeur est plus petite que 1, on réimprime le message comme quoi la 
# valeur n'est pas valide.
plusPetitQueUn:

li $v0, 4
la $a0, msgDonneeNonValide
syscall 

li $v0, 1
lw $a0, nombreMaximal
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

# L'utilisateur re-rentre une valeur et on revient à l'étiquette 
# verifDonneeValide.
li $v0, 5
syscall   

j verifDonneeValide

################################################################################
# On vérifie que la donnée entrée par l'utilisateur n'est pas déjà dans la 
# matrice.
verifDonneeDejaEntree:

# On calcule l'adresse de l'élément dans la matrice de vérification qui 
# correspond au nombre entré par l'utilisateur.
subi $t0, $v0, 1 # On soustrait 1 à la valeur entrée par l'utilisateur

# On multiplie la valeur obtenue après la soustraction par 4, ce qui nous donne 
# le décalage en bytes par rapport à l'adresse du premier élément de la matrice 
# de vérification.
mul $t1, $t0, 4
add $t2, $t1, $s1 # $t2 = adresse de matriceVerif[nombreEntre-1]

# On met la valeur qui figure à l'adresse correspondante dans la matrice de 
# vérification dans $t3 et si elle ne vaut pas 1, on va à ajoutValeurAdresses.
lw $t3, 0($t2)
addi $t4, $0, 1
bne $t3, $t4, ajoutValeurAdresses

# Si la valeur est déjà dans la matrice, on redemande une valeur à l'utilisateur 
# et on saute à verifDonneeValide pour revérifier cette nouvelle valeur.
li $v0, 4
la $a0, msgDonneeDejaEntree
syscall 

li $v0, 1
lw $a0, nombreMaximal
syscall

li $v0, 4
la $a0, msgPonctuation 
syscall 

li $v0, 5
syscall   

j verifDonneeValide

################################################################################
# On ajoute la valeur entrée par l'utilisateur au bon endroit dans la matrice et 
# on ajoute un 1 au bon endroit dans la matrice de vérification.
ajoutValeurAdresses:

# On calcule l'adresse de l'élément dans la matrice où stocker le nombre entré 
# par l'utilisateur. On multiplie la valeur de l'itérateur par 4, ce qui 
# correspond au décalage en byte par rapport à l'adresse du premier élément de 
# la matrice de base.
sll $t0, $s2, 2
add $t0, $t0, $s0 # $t0 = adresse de matrice[i].
sw $v0, 0($t0) # On met la valeur entrée par l'utilisateur au bon endroit.

# On calcule l'adresse de l'élément dans la matrice de vérification qui 
# correspond au nombre entré par l'utilisateur. On soustrait 1 à la valeur 
# entrée par l'utilisateur, ce qui nous permettra de calculer le bon décalage.
subi $t0, $v0, 1

# On multiplie la valeur obtenue après la soustraction par 4, ce qui nous donne 
# le décalage en bytes par rapport à l'adresse du premier élément de la matrice 
# de vérification.
mul $t1, $t0, 4
add $t2, $t1, $s1 # $t2 = adresse de matriceVerif[nombreEntre-1]

# On met la valeur 1 à l'adresse appropriée dans la matrice de vérification.
addi $t3, $0, 1
sw $t3, 0($t2)

# On incrémente la valeur de l'itérateur et on recommence la boucle.
addi $s2, $s2, 1
j boucleEntrezDonnees

################################################################################
# Fonction qui va afficher la matrice entrée par l'utilisateur à l'écran.
afficherMat:

li $t1, 0 # Itérateur de la posistion dans la matrice.
lw $a2, nombreMaximal 
lw $a3, adresseMatrice
li $t2, 0 # Itétateur pour la longueur d'une rangée.
lw $a1, nombreColonnes

boucleAffiche:
# Est-ce que l'itérateur est plus petit que la taille de la matrice?
slt $t0, $t1, $a2
beq $t0,$0, estMagique # Sinon, on vérifie que la matrice est un carré magique.

# On imprime le prochain nombre dans la matrice.
lw $a0, 0($a3)
li $v0, 1
syscall

lw, $s0, 0($a3) # On met le nombre imprimé dans $s0.

add $a3, $a3, 4 # Additonner 4 pour l'adresse mémoire suivante de la matrice.
add $t1, $t1, 1	# On incrémente l'itérateur.
add $t2, $t2, 1 # On incrémente l'itérateur de la longuur de la ligne.

# Si on a atteint la fin de la ligne, on va à la partie saut de ligne.
beq $t2, $a1, SautDeLigne

# On définit des variables qui vont nous permettre de déterminer le nombre
# d'espaces à imprimer selon la grandeur du nombre imprimé, ce qui fera en sorte
# que les colonnes seront alignées à l'affichage.
addi $s2, $0, 10
addi $s3, $0, 100
addi $s4, $0, 1000
addi $s5, $0, 10000
addi $s6, $0, 100000

# On met la valeur 1 dans $t6 pour comparer avec la valeur obtenue par le slt.
addi $t6, $0, 1 

# On définit un itérateur pour imprimer les espaces, initialisé à 0.
li $t7, 0 # Itérateur

# On compare successivement le nombre imprimé avec 10, 100, 1000, 10000 et 
# 100000 pour déterminer le nombre d'espaces à imprimer.
slt $t5, $s0, $s2 
li $s1, 6
beq $t6, $t5, boucleEspace

slt $t5, $s0, $s3 
li $s1, 5
beq $t6, $t5, boucleEspace

slt $t5, $s0, $s4 
li $s1, 4
beq $t6, $t5, boucleEspace

slt $t5, $s0, $s5
li $s1, 3
beq $t6, $t5, boucleEspace

slt $t5, $s0, $s6
li $s1, 2
beq $t6, $t5, boucleEspace

# Si le nombre est plus grand ou égal à 100000, on imprime seulement une espace.
li $s1, 1

################################################################################
# On imprime les espaces de façon successive jusqu'à ce que l'itérateur atteigne
# le nombre d'espace à imprimer dont la valeur est dans $s1. 
boucleEspace:

# Si on a imprimé toutes les espaces, on imprime le prochain nombre.
beq $t7, $s1 boucleAffiche

li $v0, 4
la $a0, msgEspace # Imprime une espace.
syscall

addi $t7, $t7, 1 # On incrémente l'itérateur et on recommence la boucle.
j boucleEspace

################################################################################
# Si on a atteint la fin de la ligne on fait un saut de ligne pour imprimer la 
# prochaine ligne de la matrice.
SautDeLigne:

li $v0, 4
la $a0, msgSautDeLigne
syscall
li $t2, 0 # On réinitialise l'itérateur de la position sur la ligne.
j boucleAffiche

################################################################################
# On vérifie que la matrice entrée par l'utilisateur forme un carré magique. On
# commence par vérifier que la somme de chaque rangée est la même, ensuite on 
# vérifie les colonnes, puis les diagonales et finalement les 4 coins.
estMagique:

################################################################################
# On vérifie que les rangées sont compatibles avec la notion de carré magique, 
# c'est à dire que leur somme est la même.
verifierRangéesMagiques:

li $t0, 0 # Itérateur.
lw $t1, nombreColonnes 
lw $t2, nombreRangees 
lw $t3, adresseMatrice 

################################################################################
# On itère sur les rangées afin de vérifier que la somme de chaque rangée est la
# même.
boucleRangées:

slt $t4, $t0, $t2 # Est-ce que l'itérateur est inférieur au nombre de rangées?
beq $t4, $0, verifierColonnesMagiques # Sinon, on vérifie les colonnes.

# On initlialise $t5 et $t6 à 0 pour le calcul de la somme de la rangée 
# courante.
li $t5, 0 
li $t6, 0 

################################################################################
# Pour une rangée donnée, on fait une boucle sur les différentes colonnes et on
# fait la somme de chaque valeur dans la rangée.
boucleColonnes:

# Est-ce que l'itérateur est inférieur au nombre de colonnes?
slt $t7, $t6, $t1
beq $t7, $0, checkSomme # Sinon, on vérifie la somme de la rangée.

lw $t8, 0($t3) # Chargement de la valeur de la matrice.
add $t5, $t5, $t8 # Ajout de la valeur à la somme de la rangée.
addi $t3, $t3, 4 # Déplacement à la prochaine valeur de la matrice.
addi $t6, $t6, 1 # Incrémentation de l'itérateur de colonne.
j boucleColonnes

################################################################################
# On compare la somme de la rangée avec la somme de la rangée précédente si ce 
# n'est pas la première rangée.
checkSomme:

bne $t0, $0, comparerSomme 
move $t9, $t5 # On stocke la somme de la rangée actuelle dans $t9.
j incrementer

################################################################################
# Si la somme de cette rangée est différente de la première, la matrice n'est 
# pas magique.
comparerSomme:

bne $t5, $t9, nonMagique

################################################################################
# Quand on a atteint la fin d'une rangée, et que la somme est la même que celle 
# de la rangée précédente, on incrémente l'itérateur et on vérifie la prochaine
# rangée.
incrementer:

addi $t0, $t0, 1
j boucleRangées

################################################################################
# Si les sommes diffèrent, la matrice n'est pas un carré magique et on affiche
# le message correspondant.
nonMagique:

li $v0, 4
la $a0, msgNonMagique
syscall
j exit

################################################################################
# On vérifie que les colonnes sont compatibles avec la notion de carré magique, 
# c'est à dire que leur somme est la même.
verifierColonnesMagiques:

li $t0, 0 # Itérateur pour le numéro de colonne.
lw $t1, nombreColonnes 
lw $t2, nombreRangees 
lw $t3, adresseMatrice 

################################################################################
# On itère sur les colonnes afin de vérifier que la somme de chaque colonne est 
# la même.
boucleColonnesSuite:

slt $t4, $t0, $t1 # Est-ce que l'itérateur est inférieur au nombre de colonnes?
sw $t5, valeurMagique

# Sinon, on sort de la boucle et on vérifie les diagonales.
beq $t4, $0, verifDiagonale

# On initlialise $t5 et $t6 à 0 pour le calcul la somme de la colonne courante.
li $t5, 0 
li $t6, 0 

################################################################################
# Pour une colonne donnée, on itère sur les différentes rangées afin de calculer
# la somme des éléments dans cette colonne.
boucleRangeesSuite:

slt $t7, $t6, $t2 # Est-ce que l'itérateur est inférieur au nombre de rangées?
beq $t7, $0, checkSommeColonnes # Sinon, on vérifie la somme de la colonne.

lw $t8, 0($t3) 
add $t5, $t5, $t8 # Ajout de la valeur à la somme de la colonne.
addi $t3, $t3, 4 
addi $t6, $t6, 1 # Incrémentation de l'itérateur.
j boucleRangeesSuite

################################################################################
# On compare la somme de la colonne avec la somme de la colonne précédente si ce 
# n'est pas la première colonne.
checkSommeColonnes:

bne $t0, $0, comparerSommeColonnes
move $t9, $t5 # On stocke la somme de la colonne actuelle dans $t9.
j continueColonne

################################################################################
# Si la somme de cette colonne est différente de la première, la matrice 
# n'est pas magique et on saute à nonMagique.
comparerSommeColonnes:

bne $t5, $t9, nonMagique

################################################################################
# Quand on a atteint la fin d'une colonne, et que la somme est la même que celle 
# de la colonne précédente, on incrémente l'itérateur et on vérifie la prochaine
# colonne.
continueColonne:

addi $t0, $t0, 1 # Incrémentation de l'itérateur de colonne.
j boucleColonnesSuite

################################################################################
# On vérifie la somme des diagonales
verifDiagonale:

li $t0, 0 # Itérateur.
lw $t1, nombreRangees
li $s1, 0 # Somme de la diagonale de gauche.
li $s2, 0 # Somme de la diagonale de droite.
lw $t2, adresseMatrice
lw $t3, adresseMatrice

# On calcule l'adresse du coin en haut et à droite de la matrice et on la stocke
# dans $t3.
subi $t5, $t1, 1

# $t4 est le byte offset qui nous permettra d'accéder successivement les
# éléments de la diagonale de droite.
mul $t4, $t5, 4
add $t3, $t3, $t4

# $t5 est le byte offset qui nous permettra d'accéder successivement les
# éléments de la diagonale de gauche.
addi $t6, $t1, 1
mul $t5, $t6, 4

################################################################################
# On calcule la somme de chaque diagonale en itérant sur les différents éléments
# des diagonales.
sommeDiagonale:

# Si l'itérateur a atteint le nombre de rangées de la matrice, on compare les 
# sommes des diagonales.
slt $t8, $t0, $t1 
beq $t8, $0, comparerSommesDiag

# On prend les éléments des diagonales à ajouter à leur somme respective.
lw $t6, 0($t2)
lw $t7, 0($t3)

# On ajoute les éléments aux sommes.
add $s1, $s1, $t6
add $s2, $s2, $t7 

# On change la valeur de l'adresse dans $t2 et $t3 pour l'adresse du prochain 
# élément dans la diagonale.
add $t2, $t2, $t5
add $t3, $t3, $t4 

# On incrémente l'itérateur et on recommence la boucle.
addi $t0, $t0, 1

j sommeDiagonale

################################################################################
# On compare la valeur des deux sommes des diagonales et si elles ne sont pas 
# égales à la valeurMagique calculée pour les rangées et les colonnes, on saute 
# à nonMagique. Sinon, on continue et on vérifie les coins.
comparerSommesDiag:

bne $s1, $s2, nonMagique
lw $t0, valeurMagique 
bne $s1, $t0, nonMagique

################################################################################
# On vérifie la somme des 4 coins de la matrice et on détermine si elle est 
# égale à la valeurMagique calculée précédemment.
verifCoins:

# On initialise 4 registres qui vont contenir les adresses de chaque coin de la
# matrice.
lw $t0, adresseMatrice # L'adresse du coin en haut et à gauche de la matrice.
lw $t1, adresseMatrice 
lw $t2, adresseMatrice
lw $t3, adresseMatrice

# On calcule l'adresse du coin en haut et à droite de la matrice.
lw $t4, nombreColonnes 
subi $t5, $t4, 1 
mul $t5, $t5, 4
add $t1, $t1, $t5

# On calcule l'adresse du coin en bas et à droite de la matrice.
lw $t5, nombreMaximal
sub $t5, $t5, $t4 
mul $t5, $t5, 4 
add $t2, $t2, $t5 

# On calcule l'adresse du coin en bas et à droite de la matrice.
lw $t5, nombreMaximal 
subi $t5, $t5, 1 
mul $t5, $t5, 4 
add $t3, $t3, $t5

# On met les valeurs stockées aux adresses de chaque coin dans leur registre 
# respectif et on stocke la valeurMagique dans $t4 pour la comparer avec la 
# somme.
lw $t0, 0($t0) 
lw $t1, 0($t1)
lw $t2, 0($t2)
lw $t3, 0($t3)
lw $t4, valeurMagique

# On additionne les 4 coins ensemble.
add $s3, $t0, $t1
add $s3, $s3, $t2 
add $s3, $s3, $t3 

# Si la somme n'est pas égale à la valeurMagique, on saute à nonMagique.
bne $s3, $t4, nonMagique

################################################################################   
# Fonction qui s'exécute si la matrice est forcément un carré magique. On 
# affiche un message qui indique que la matrice est un carré magique et on 
# affiche la valeurMagique à l'écran.
estMagiqueResultat:

li $v0, 4
la $a0, msgEstMagique
syscall
	
li $v0, 1
lw $a0, valeurMagique
syscall
	
li $v0, 4
la $a0, msgPoint
syscall
	
j exit

################################################################################
# On saute à cette étiquette pour terminer le programme. On imprime un saut de
# ligne avant de terminer le programme.
exit:

# On imprime un saut de ligne pour terminer.
li $v0, 4
la $a0, msgSautDeLigne
syscall

# On termine le programme.
li $v0,10 
syscall

################################################################################
