function [Normales_Dioptres, Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(Position_Camera, Barycentre, Pts_Surface_Ambre, Normales_Pts)
    Nb_Imgs = size(Position_Camera, 1) ;
    Pts_Dioptres = cell(Nb_Imgs, 1) ;
    Normales_Dioptres = cell(Nb_Imgs, 1) ;
    Booleen_Pts_Dioptres = zeros(size(Pts_Surface_Ambre, 1), Nb_Imgs, 'logical') ;
    for i = 1:Nb_Imgs
        [Normales_Dioptre_i, Pts_Dioptre_i, Booleen_Pts_Dioptre_i] = Calculer_Dioptre_Discret(Position_Camera(i, :)', Barycentre, Pts_Surface_Ambre, Normales_Pts) ;
        Normales_Dioptres(i) = {Normales_Dioptre_i} ;
        Pts_Dioptres(i) = {Pts_Dioptre_i} ;
        Booleen_Pts_Dioptres(:, i) = Booleen_Pts_Dioptre_i ;
    end
end


function [Normales_Dioptre, Pts_Dioptre, Booleen_Pts_Dioptre] = Calculer_Dioptre_Discret(Position_Camera, Barycentre, Coord_Pts, Normales_Pts)
    Normale_Au_Plan = Position_Camera - Barycentre ;
    a = Normale_Au_Plan(1) ;
    b = Normale_Au_Plan(2) ;
    c = Normale_Au_Plan(3) ;
    x = Barycentre(1) ;
    y = Barycentre(2) ;
    z = Barycentre(3) ;
    d = -(a*x + b*y + c*z) ;
    Calcul = a*Coord_Pts(:, 1) + b*Coord_Pts(:, 2) + c*Coord_Pts(:, 3) + d*ones(size(Coord_Pts, 1), 1) ;
    Booleen_Pts_Dioptre = (Calcul > 0) ;
    Normales_Dioptre = Normales_Pts(Booleen_Pts_Dioptre, :) ;
    Pts_Dioptre = Coord_Pts(Booleen_Pts_Dioptre, :) ;
end