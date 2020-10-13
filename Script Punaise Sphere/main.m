clear all;
close all;


%% Required information : to be provided by the user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Camera Selection
refImg = 1;
witnImgs_list = [28, 29, 2, 3];
ctrlImgs_list = [8];

% Indexes of refraction :

param.IOR_1 = single(1);   % Air
param.IOR_2 = single(1.5); % Glass - Ambre IOR is 1.541

% Interface's properties
interface.shape = 'sphere';
interface.facesNumber = single(50);
interface.radius = single(9);
interface.center = single([0; 0; 100]);

% Camera parameters :
camera.sensorLength = single(36);
camera.focal = single(90); %% focal in mm

% Options :
options.numberOfSteps = single(100) ;
options.depthMax = single(20) ;
% Output_Name = "Punaise_Sphere_" + int2str(interface.facesNumber) + "_" + int2str(options.numberOfSteps) + ".mat" ;

% Files to load :
load('Imgs_Et_Masques_Punaise_1.5.mat');
load('data/Cameras.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get interface points and normals :
[interface.points, interface.normals] = interfaceSampling(interface);

%% Use only selected cameras :
usedCam = [refImg, witnImgs_list, ctrlImgs_list];

data.indLastWitness = uint8(length(witnImgs_list) + 1);
data.Imgs = Imgs(:, :, :, usedCam);
data.Masques_Imgs = Masques_Imgs(:, :, usedCam);

[nb_rows, nb_col, nb_ch, nb_im] = size(data.Imgs);

%% Get selected cameras information :
camera.R = single(R(:,:,usedCam));
camera.t = single(t(usedCam,:));
camera.K = single(evalK(nb_rows, nb_col, camera));
[camera.visiblePoints, camera.interfacePoints2Pixels] = getCorrespondances(camera, interface, data);

%% Prepare Stereo Data
%% Pictures are "vectorized" and neighboring pixels are aligned along the 3rd dimension
data.imStereo = getStereoData(data);

%% MVS
clearvars -except data camera interface options param ;
tic
[Cloud, Color] = MVS(data, camera, interface, options, param);
toc

%% Display Results
figure(1)
PointsCloud3D = pointCloud(Cloud,'Color',uint8(Color));
pcshow(PointsCloud3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal
