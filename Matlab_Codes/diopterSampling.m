%% Get diopter points and normal : we try here to implement the function several diopter shapes, 
%% and ultimately, read these data in case of unorthodox diopter shape

%% Input : diopter object as constructed in main.m
%% Output : 
%%    - points : 3D position of diopter points in the main frame
%%    - normals : 3D normals associated with 3d points

function [points, normals] = diopterSampling(diopter)

switch diopter.shape

	case 'sphere'
		[X,Y,Z] = sphere(diopter.facesNumber);
		normals = [X(:) Y(:) Z(:)];
		X = X*diopter.radius + diopter.center(1);
		Y = Y*diopter.radius + diopter.center(2);
		Z = Z*diopter.radius + diopter.center(3);
		points = [X(:) Y(:) Z(:)];
	otherwise
		disp('This case has not been implemented yet')
	end
