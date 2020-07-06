clear variables ;

%%%%%% PARAMETRES %%%%%%%%
Nb_De_Pts = 240066; % 1 <= Nb_De_Pts <= 240066

Num_Img_Ref = 1 ;
Liste_Num_Img_Ctrl = [8] ;
Liste_Num_Imgs_Temoins = [29, 2] ;

Output_Name = "Nuage_" + int2str(Nb_De_Pts) + "_" + int2str(Num_Img_Ref) + ".mat" ;

%%%%%%%%% DONNEES %%%%%%%%%%%%%%
load('Ellipsoide.mat') ;
Normales_Pts = Normales_Pts(1:Nb_De_Pts, :) ;
Pts_Surface_Ambre = Pts_Surface_Ambre(1:Nb_De_Pts, :) ;
load('Imgs_Et_Masques_Lapin_Ellipsoide_HD.mat') ;
load('Cameras.mat') ;
n_Air = 1 ; n_Verre = 1.5 ; % n_Ambre = 1.541 ;


% Dioptre pour chaque Camera
Nb_Imgs = size(Imgs, 4) ;
[Normales_Dioptres, Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(...
    Position_Camera, Barycentre, Pts_Surface_Ambre, Normales_Pts) ;

% Matrice de calibrage K
[Nb_De_Lignes, Nb_De_Colonnes, ~, ~] = size(Imgs) ;
Sensor_Length = 36 ;
Matrice_De_Calibrage = Calculer_Matrice_De_Calibrage(Nb_De_Lignes, Nb_De_Colonnes, Sensor_Length) ;

% Img 2 Dioptre
[Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, R, t, Matrice_De_Calibrage, Masques_Imgs) ;

% Taille Fenetre SAD, Nb De Tranches, Profondeur
Taille_Fenetre_SAD = 3 ; % 3*3
Nb_De_Tranches = 100 ;
Profondeur = 30 ;

% MVS
tic
[Nuage, Couleur] = MVS_Ellipsoide(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Normales_Dioptres, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal

save(Output_Name, 'Nuage', 'Couleur', 'nuage_points_3D') ;
