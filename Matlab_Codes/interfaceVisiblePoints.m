%% Find points of the interface which are visible from each camera
%% This first version is very naive : it selects the half sphere which is facing the camera

%% Input : 
%%    - cameraCenter : 3D position of the camera center in the main frame
%%    - interface : object as constructed in main.m
%% Output : 
%%    - visiblePoints : 3D coordinates (in the main frame) of interface points which are visible from the camera
%%    - visiblePointsIdx : index of interface points which are visible from the camera

function [visiblePoints, visiblePointsIdx] = interfaceVisiblePoints(cameraCenter, interface)
    Nb_Imgs = size(cameraCenter, 1) ;
    visiblePoints = cell(Nb_Imgs, 1) ;
    visiblePointsIdx = cell(Nb_Imgs, 1) ;
    for i = 1:Nb_Imgs
		center2cam = cameraCenter(i, :)' - interface.center;
		scalarProduct = interface.normals*center2cam;
		visiblePointsIdx{i} = find(scalarProduct > 0);
        visiblePoints(i) = {interface.points(visiblePointsIdx{i}, :)};
    end
end
