clear variables ;

%%%%%% PARAMETRES %%%%%%%%
Nb_De_Faces = 600 ;
Nb_De_Tranches = 200 ;
Taille_Fenetre_SAD = 3 ; % 3*3
Profondeur = 20 ;
Output_Name = "Punaise_Sphere_" + int2str(Nb_De_Faces) + "_" + int2str(Nb_De_Tranches) + ".mat" ;

%%%%%%%%% DONNEES %%%%%%%%%%%%%%

% Echantillonage de la surface de l'ambre + Barycentre ;
[Barycentre, Pts_Surface_Ambre] = Calculer_Coord_Pts_Sphere(Nb_De_Faces) ;

load('Imgs_Et_Masques_Punaise_Boule15.mat') ;
load('Cameras.mat') ;
n_Air = 1 ; n_Verre = 1.5 ; % n_Ambre = 1.541 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dioptre pour chaque Camera
Nb_Imgs = size(Imgs, 4) ;
[Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(...
    Position_Camera, Barycentre, Pts_Surface_Ambre) ;

% Matrice de calibrage K
[Nb_De_Lignes, Nb_De_Colonnes, ~, ~] = size(Imgs) ;
Sensor_Length = 36 ;
Matrice_De_Calibrage = Calculer_Matrice_De_Calibrage(Nb_De_Lignes, Nb_De_Colonnes, Sensor_Length) ;

% Img 2 Dioptre
[Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, R, t, Matrice_De_Calibrage, Masques_Imgs) ;


% MVS 1
Num_Img_Ref = 1 ;
Liste_Num_Img_Ctrl = [] ;
Liste_Num_Imgs_Temoins = [28, 29, 2, 3, 8] ;
tic
[Nuage_1, Couleur_1] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc

% MVS 2
Num_Img_Ref = 8 ;
Liste_Num_Img_Ctrl = [] ;
Liste_Num_Imgs_Temoins = [6, 7, 9, 10, 1] ;
tic
[Nuage_2, Couleur_2] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc

% MVS 3
Num_Img_Ref = 16 ;
Liste_Num_Img_Ctrl = [] ;
Liste_Num_Imgs_Temoins = [14, 15, 17, 18, 22] ;
tic
[Nuage_3, Couleur_3] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc

% MVS 4
Num_Img_Ref = 22 ;
Liste_Num_Img_Ctrl = [] ;
Liste_Num_Imgs_Temoins = [20, 21, 23, 24, 16] ;
tic
[Nuage_4, Couleur_4] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc


Nuage = [Nuage_1 ; Nuage_2 ; Nuage_3 ; Nuage_4] ;
Couleur = [Couleur_1 ; Couleur_2 ; Couleur_3 ; Couleur_4] ;

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal

save(Output_Name, 'Nuage_1', 'Nuage_2', 'Nuage_3', 'Nuage_4', 'Nuage', 'Couleur_1', 'Couleur_2', 'Couleur_3', 'Couleur_4', 'Couleur', 'nuage_points_3D') ;
