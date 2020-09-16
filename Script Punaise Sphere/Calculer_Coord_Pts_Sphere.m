function [Centre_Sphere, Coord_Pts_Sphere] = Calculer_Coord_Pts_Sphere(Nb_De_Faces)
    [X,Y,Z] = sphere(Nb_De_Faces) ;
    Rayon_Sphere = 9 ;
    Centre_Sphere = [0 ; 0 ; 100] ;
    X = X*Rayon_Sphere + Centre_Sphere(1) ;
    Y = Y*Rayon_Sphere + Centre_Sphere(2) ;
    Z = Z*Rayon_Sphere + Centre_Sphere(3) ;
    Coord_Pts_Sphere = [X(:) Y(:) Z(:)] ;
end