%% Get interface points and normal : we try here to implement the function several interface shapes, 
%% and ultimately, read these data in case of unorthodox interface shape

%% Input : interface object as constructed in main.m
%% Output : 
%%    - points : 3D position of interface points in the main frame
%%    - normals : 3D normals associated with 3d points

function [points, normals] = interfaceSampling(interface)

switch interface.shape

	case 'sphere'
		[X,Y,Z] = sphere(interface.facesNumber);
		normals = [X(:) Y(:) Z(:)];
		X = X*interface.radius + interface.center(1);
		Y = Y*interface.radius + interface.center(2);
		Z = Z*interface.radius + interface.center(3);
		points = [X(:) Y(:) Z(:)];
	otherwise
		disp('This case has not been implemented yet')
	end
