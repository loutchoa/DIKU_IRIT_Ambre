clear all;
close all;


%% Required information : to be provided by the user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Camera Selection
refImg = 1;
witnImgs_list = [28, 29, 2, 3];
ctrlImgs_list = [8];

% Indexes of refraction :
param.IOR_1 = 1;   % Air
param.IOR_2 = 1.5; % Glass - Ambre IOR is 1.541

% Interface's properties
interface.shape = 'sphere';
interface.facesNumber = 50;
interface.radius = 9;
interface.center = [0; 0; 100];

% Camera parameters :
camera.sensorLength = 36;
camera.focal = 90; %% focal in mm

% Options :
options.numberOfSteps = 100 ;
options.depthMax = 20 ;
Output_Name = "Punaise_Sphere_" + int2str(interface.facesNumber) + "_" + int2str(options.numberOfSteps) + ".mat" ;

% Files to load :
load('Imgs_Et_Masques_Punaise_1.5.mat');
load('data/Cameras.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get interface points and normals :
[interface.points, interface.normals] = interfaceSampling(interface);

%% Use only selected cameras :
usedCam = [refImg, witnImgs_list, ctrlImgs_list];

data.indLastWitness = length(witnImgs_list) + 1;
data.Imgs = Imgs(:, :, :, usedCam);
data.Masques_Imgs = Masques_Imgs(:, :, usedCam);

[nb_rows, nb_col, nb_ch, nb_im] = size(data.Imgs);

%% Get selected cameras information :
camera.R = R(:,:,usedCam);
camera.t = t(usedCam,:);
camera.K = evalK(nb_rows, nb_col, camera);

[camera.visiblePoints, camera.interfacePoints2Pixels] = getCorrespondances(camera, interface, data);

%% Prepare Stereo Data
%% Pictures are "vectorized" and neighboring pixels are aligned along the 3rd dimension

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


% MVS
tic
[Nuage, Couleur] = MVS_Boule(data, camera, interface, options, param);
toc

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal
