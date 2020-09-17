clear all;
close all;

%%%%%% PARAMETRES %%%%%%%%
% Interface's properties
interface.shape = 'sphere';
interface.facesNumber = 50;
interface.radius = 9;
interface.center = [0; 0; 100];

% Options :
numberOfSteps = 100 ;
depthMax = 20 ;

Taille_Fenetre_SAD = 3 ; % 3*3
Output_Name = "Punaise_Sphere_" + int2str(interface.facesNumber) + "_" + int2str(numberOfSteps) + ".mat" ;

load('Imgs_Et_Masques_Punaise_1.5.mat');

% Camera parameters :
camera.sensorLength = 36;
camera.focal = 90; %% focal in mm

load('data/Cameras.mat');
camera.R = R;
camera.t = t;

%%%%%%%%% DONNEES %%%%%%%%%%%%%%
%% Get interface points and normals :
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[interface.points, interface.normals] = interfaceSampling(interface);

% Indexes of refraction :
IOR_1 = 1;   % Air
IOR_2 = 1.5; % Glass - Ambre IOR is 1.541

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate visible interface points for each camera
[Pts_Dioptres, indPointsDioptres] = interfaceVisiblePoints(camera.t, interface);

% Matrice de calibrage K
[nb_rows, nb_col, nb_ch, nb_im] = size(Imgs);
camera.K = Calculer_Matrice_De_Calibrage(nb_rows, nb_col, camera.sensorLength) ;

% Img 2 Dioptre
[Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, camera.R, camera.t, camera.K, Masques_Imgs) ;


% MVS 1
Num_Img_Ref = 1 ;
Liste_Num_Img_Ctrl = [] ;
Liste_Num_Imgs_Temoins = [28, 29, 2, 3, 8] ;
tic
[Nuage, Couleur] = MVS_Boule(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
    Liste_Num_Imgs_Temoins, interface.center, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    camera.t, numberOfSteps, IOR_1, IOR_2, Taille_Fenetre_SAD, depthMax) ;
toc

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal
