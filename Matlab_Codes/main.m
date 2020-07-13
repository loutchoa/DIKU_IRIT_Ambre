clear all;
close all;

%% TO DO :
%%%%%%%%%%
% - Imgs_2_Dioptres pourrait renvoyer uniquement l'indice du point parmis la liste des points du dioptre
% - Les temps de parcours dans l'air (MVS_Boule > Calcul_de_pij_prime_Discret) peuvent être calculés en amont
%			- Imgs_2_Dioptres pourrait renvoyer indice + temps de parcours dans l'air
% - Virer la boucle sur les pixels
% - Nettoyer les variables + traduction
% - Ajouter commentaires

%%%%%% PARAMETRES %%%%%%%%
%% Required information : to be provided by the user

Num_Img_Ref = 1 ;
Liste_Num_Img_Ctrl = [8] ;
Liste_Num_Imgs_Temoins = [28, 3] ;

Output_Name = "Nuage_" + int2str(Num_Img_Ref) + ".mat" ;

% Indexes of refraction :
IOR_1 = 1;   % Air
IOR_2 = 1.5; % Glass - Ambre IOR is 1.541

% Diopter's properties
diopter.shape = 'sphere';
diopter.facesNumber = 50;
diopter.radius = 10;
diopter.center = [0; 0; 100];

% Camera parameters :
camera.sensorLength = 36;
camera.focal = 90; %% focal in mm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[diopter.points, diopter.normals] = diopterSampling(diopter);

load('data/Imgs_Et_Masques_Lapin_Boule_HD.mat') ;
load('data/Cameras.mat') ;

%% Delete non-used data
usedCam = [Num_Img_Ref Liste_Num_Img_Ctrl Liste_Num_Imgs_Temoins];

data.Imgs = Imgs(:,:,:,usedCam);
data.Masques_Imgs = Masques_Imgs(:,:,usedCam);

camera.Position_Camera = Position_Camera(usedCam,:);
camera.R = R(:,:,usedCam);
camera.t = t(usedCam,:);

Selected_Num_Img_Ref = 1;
Selected_Liste_Num_Img_Ctrl = 2:(1+length(Liste_Num_Img_Ctrl));
Selected_Liste_Num_Imgs_Temoins = length(Selected_Liste_Num_Img_Ctrl)+2:(length(Selected_Liste_Num_Img_Ctrl)+1+length(Liste_Num_Imgs_Temoins));

[nb_rows, nb_col, nb_ch, nb_im] = size(data.Imgs);

% Dioptre pour chaque camera
[Pts_Dioptres, diopter.visiblePoints] = diopterVisiblePoints(camera.t, diopter);
diopter.pointsCELL = Pts_Dioptres;

% Calibration matrix K
K = evalK(nb_rows, nb_col, camera);
camera.K = K;

% Img 2 Dioptre
[Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, usedDiopterPoints] = Calculer_Imgs_2_Dioptres(Pts_Dioptres, camera, data.Masques_Imgs);

for pict = 1:nb_im
	aux = diopter.visiblePoints{pict};
	diopter.usedDiopterPoints{pict} = aux(usedDiopterPoints{pict});
end

% Taille Fenetre SAD, Nb De Tranches, Profondeur
Taille_Fenetre_SAD = 3 ; % 3*3
Nb_De_Tranches = 100 ;
Profondeur = 20 ;

% MVS
% Parameters : 
%%%%%%%%%%%%%%
params.n1 = IOR_1;
params.n2 = IOR_2;

options.size_SAD = 3;
options.nb_steps = Nb_De_Tranches;
options.Profondeur = Profondeur;

data.Img_Ref = Imgs(:, :, :, Num_Img_Ref) ;
data.Masque_Img_Ref = Masques_Imgs(:, :, Num_Img_Ref) ;
data.Masque_Proj_Ref = Masques_Imgs_Projections_Pts_Dioptres(:, :, Num_Img_Ref) ;

data.Num_Img_Ref = Selected_Num_Img_Ref;
data.Liste_Num_Img_Ctrl = Selected_Liste_Num_Img_Ctrl;
data.Liste_Num_Imgs_Temoins = Selected_Liste_Num_Imgs_Temoins;

data.Masques_Imgs_Projections_Pts_Dioptres = Masques_Imgs_Projections_Pts_Dioptres;
data.Imgs_2_Dioptres = Imgs_2_Dioptres;
data.Dioptres_2_Imgs = Dioptres_2_Imgs;

%% Prepare Stereo Data
%% Pictures are "vectorized" and neighboring pixels are aligned along the 4th dimension

for picture = 1:nb_im
	antiMask = find(data.Masques_Imgs(:,:,picture) == 0);
	currentIm = data.Imgs(:,:,:,picture);
	currentIm = reshape(currentIm, [nb_rows * nb_col, nb_ch]);
	currentIm(antiMask, :) = 0;
	currentIm = reshape(currentIm, [nb_rows, nb_col, nb_ch]);
	imStereo = cat(4,...
		currentIm([1 1:end-1],[1 1:end-1],:),...                        % Top left
		currentIm([1 1:end-1],:,:),...                                  % Top
		currentIm([1 1:end-1],[2:end end],:),...                        % Top right
		currentIm(:,[1 1:end-1],:),...                                  % Left
		currentIm,...                                                   % Center
		currentIm(:,[2:end end],:),...                                  % Right
		currentIm([2:end end],[1 1:end-1],:),...                        % Bottom left
		currentIm([2:end end],:,:),...                                  % Bottom
		currentIm([2:end end],[2:end end],:));                          % Bottom right

	imStereo = reshape(imStereo,[nb_rows * nb_col, nb_ch,9]);
    data.imStereo(:,:,:,picture) = permute(imStereo,[1,3,2]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
[Nuage, Couleur] = MVS_Boule(data, camera, params, options, diopter);
toc

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal

save(Output_Name, 'Nuage', 'Couleur', 'nuage_points_3D') ;
