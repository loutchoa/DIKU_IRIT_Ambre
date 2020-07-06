clear variables ;

%%%%%% PARAMETRES %%%%%%%%
Nb_De_Faces = 600 ;
Nb_De_Tranches = 100 ;
Taille_Fenetre_SAD = 3 ; % 3*3
Profondeur = 20 ;
Name_reconstruction = "Punaise_Sphere";
suffixe = sprintf("%03d_%03d_%d_%02d", Nb_De_Faces, Nb_De_Tranches, Taille_Fenetre_SAD, Profondeur);
Output_Name = Name_reconstruction + "_" + suffixe + ".mat" ;


if isfile(Output_Name)
    vinfo = who('-file', Output_Name);
else
    vinfo = 0;
end 


%%%%%%%%% DONNEES %%%%%%%%%%%%%%

% Echantillonage de la surface de l'ambre + Barycentre ;
[Barycentre, Pts_Surface_Ambre] = Calculer_Coord_Pts_Sphere(Nb_De_Faces) ;

load('Imgs_Et_Masques_Punaise_Boule15.mat') ;
load('Cameras.mat') ;
n_Air = 1 ; n_Verre = 1.5 ; % n_Ambre = 1.541 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dioptre pour chaque Camera
Nb_Imgs = size(Imgs, 4) ;
[Pts_Dioptres, Booleen_Pts_Dioptres] = Calculer_Dioptres(...
    Position_Camera, Barycentre, Pts_Surface_Ambre) ;

% Matrice de calibrage K
[Nb_De_Lignes, Nb_De_Colonnes, ~, ~] = size(Imgs) ;
Sensor_Length = 36 ;
Matrice_De_Calibrage = Calculer_Matrice_De_Calibrage(Nb_De_Lignes, Nb_De_Colonnes, Sensor_Length) ;

% Img 2 Dioptre
[Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, R, t, Matrice_De_Calibrage, Masques_Imgs) ;

% Ou 16? gnome-system-monitor affiche 16 CPUs chez moi...
poolobj = parpool(8);
% Peut-etre le nombre de "workers" est par defaut le nimbre max de CPUs?
% poolobj = parpool;

%MVS 1
if iscell(vinfo) && ismember('Nuage_1', vinfo) && ismember('Couleur_1', vinfo)
    load(Output_Name, 'Nuage_1');
    load(Output_Name, 'Couleur_1');
else
    Num_Img_Ref = 1 ;
    Liste_Num_Img_Ctrl = [] ;
    Liste_Num_Imgs_Temoins = [28, 29, 2, 3, 8] ;
    tic
    [Nuage_1, Couleur_1] = MVS_BouleP(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
        Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
        Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
        t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
    toc
    if ~isfile(Output_Name)
        save(Output_Name, 'Nuage_1', 'Couleur_1');
    else
        save(Output_Name, '-append', 'Nuage_1', 'Couleur_1');
    end
    vinfo = who('-file', Output_Name);
end



% MVS 2
% vindo existe surement a ce niveau la...
if ismember('Nuage_2', vinfo) && ismember('Couleur_2', vinfo)
    load(Output_Name, 'Nuage_2');
    load(Output_Name, 'Couleur_2');
else
    Num_Img_Ref = 8 ;
    Liste_Num_Img_Ctrl = [] ;
    Liste_Num_Imgs_Temoins = [6, 7, 9, 10, 1] ;
    tic
    [Nuage_2, Couleur_2] = MVS_BouleP(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
        Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
        Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
        t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
    toc
    save(Output_Name, '-append', 'Nuage_2', 'Couleur_2');
end
    
    
% MVS 3
if ismember('Nuage_3', vinfo) && ismember('Couleur_3', vinfo)
    load(Output_Name, 'Nuage_3');
    load(Output_Name, 'Couleur_3');
else
    Num_Img_Ref = 16 ;
    Liste_Num_Img_Ctrl = [] ;
    Liste_Num_Imgs_Temoins = [14, 15, 17, 18, 22] ;
    tic
    [Nuage_3, Couleur_3] = MVS_BouleP(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
        Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
        Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
        t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
    toc
    save(Output_Name, '-append', 'Nuage_3', 'Couleur_3');
end

% MVS 4
if ismember('Nuage_4', vinfo) && ismember('Couleur_4', vinfo)
    load(Output_Name, 'Nuage_4');
    load(Output_Name, 'Couleur_4');
else
    Num_Img_Ref = 22 ;
    Liste_Num_Img_Ctrl = [] ;   
    Liste_Num_Imgs_Temoins = [20, 21, 23, 24, 16] ;
    tic
    [Nuage_4, Couleur_4] = MVS_BouleP(Num_Img_Ref , Liste_Num_Img_Ctrl, ...
        Liste_Num_Imgs_Temoins, Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
        Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
        t, Nb_De_Tranches, n_Air, n_Verre, Taille_Fenetre_SAD, Profondeur) ;
    toc
    save(Output_Name, '-append', 'Nuage_4', 'Couleur_4');
end


if ismember('Nuage', vinfo)
    load(Output_Name, 'Nuage');
else
    Nuage = [Nuage_1 ; Nuage_2 ; Nuage_3 ; Nuage_4] ;
    save(Output_Name, '-append', 'Nuage')
end

if ismember('Couleur', vinfo)
    load(Output_Name, 'Couleur');
else
    Couleur = [Couleur_1 ; Couleur_2 ; Couleur_3 ; Couleur_4] ;
    save(Output_Name, '-append', 'Couleur');
end


% shutdown parallel pool
delete(poolobj)

% Affichage
figure(1)
nuage_points_3D = pointCloud(Nuage,'Color',uint8(Couleur));
pcshow(nuage_points_3D,'VerticalAxis','y','VerticalAxisDir','down','MarkerSize',45);
axis equal

