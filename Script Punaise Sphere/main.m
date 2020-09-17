clear variables ;

%%%%%% PARAMETRES %%%%%%%%
% Diopter's properties
interface.shape = 'sphere';
interface.facesNumber = 50;
interface.radius = 10;
interface.center = [0; 0; 100];

Nb_De_Tranches = 50 ;
Taille_Fenetre_SAD = 3 ; % 3*3
Profondeur = 20 ;
Output_Name = "Punaise_Sphere_" + int2str(interface.facesNumber) + "_" + int2str(Nb_De_Tranches) + ".mat" ;

%%%%%%%%% DONNEES %%%%%%%%%%%%%%

%% Get interface points and normals :
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[Barycentre, Pts_Surface_Ambre] = Calculer_Coord_Pts_Sphere(interface.facesNumber) ;
[interface.points, interface.normals] = interfaceSampling(interface);

load('Imgs_Et_Masques_Punaise_1.5.mat') ;
load('Cameras.mat') ;
n_Air = 1 ; n_Verre = 1.5 ; % n_Ambre = 1.541 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dioptre pour chaque Camera
Nb_Imgs = size(Imgs, 4) ;
%[Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(...
%    Position_Camera, Barycentre, Pts_Surface_Ambre) ;
[Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(Position_Camera, interface.center, interface.points);

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
[Nuage, Couleur] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
toc

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal
