%% Find points of the diopter which are visible from each camera
%% This first version is very naive : it selects the half sphere which is facing the camera

function [Pts_Dioptres, visiblePoints] = diopterVisiblePoints(Position_Camera, diopter)
    Nb_Imgs = size(Position_Camera, 1) ;
    Pts_Dioptres = cell(Nb_Imgs, 1) ;
    visiblePoints = cell(Nb_Imgs, 1) ;
    for i = 1:Nb_Imgs
		center2cam = Position_Camera(i, :)' - diopter.center;
		scalarProduct = diopter.normals*center2cam;
		visiblePoints{i} = find(scalarProduct > 0);
        Pts_Dioptres(i) = {diopter.points(visiblePoints{i}, :)};
    end
end
