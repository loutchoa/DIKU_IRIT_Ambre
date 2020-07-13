%% Find points of the diopter which are visible from each camera
%% This first version is very naive : it selects the half sphere which is facing the camera

%% Input : 
%%    - cameraCenter : 3D position of the camera center in the main frame
%%    - diopter object as constructed in main.m
%% Output : 
%%    - points : 3D coordinates (in the main frame) of diopter points which are visible from the camera
%%    - visiblePoints : index of diopter points which are visible from the camera

function [Pts_Dioptres, visiblePoints] = diopterVisiblePoints(cameraCenter, diopter)
    Nb_Imgs = size(cameraCenter, 1) ;
    Pts_Dioptres = cell(Nb_Imgs, 1) ;
    visiblePoints = cell(Nb_Imgs, 1) ;
    for i = 1:Nb_Imgs
		center2cam = cameraCenter(i, :)' - diopter.center;
		scalarProduct = diopter.normals*center2cam;
		visiblePoints{i} = find(scalarProduct > 0);
        Pts_Dioptres(i) = {diopter.points(visiblePoints{i}, :)};
    end
end
