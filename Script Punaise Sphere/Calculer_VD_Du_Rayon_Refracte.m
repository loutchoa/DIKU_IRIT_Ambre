function VD_Unitaire_Rayon_Refracte = Calculer_VD_Du_Rayon_Refracte(VD_Unitaire_Rayon_Incident, Normale_Dioptre, param)
    crossProduct = cross(VD_Unitaire_Rayon_Incident, Normale_Dioptre) ;
    dotProduct = dot(VD_Unitaire_Rayon_Incident, Normale_Dioptre) ;
    euclideanNorm = sqrt(sum(crossProduct.^2, 1)) ;
    num = euclideanNorm.*sign(dotProduct) ;
    denum = tan(asin(euclideanNorm .* (param.IOR_1/param.IOR_2))) ;
    coeff = num./denum - dotProduct ;
    coeff(isnan(coeff)) = 0 ; % if isequal(crossProduct, [0 ; 0 ; 0]) then VD_Unitaire_Rayon_Refracte = VD_Unitaire_Rayon_Incident ;
    VD_Unitaire_Rayon_Refracte = VD_Unitaire_Rayon_Incident + coeff.*Normale_Dioptre ;
    euclideanNorm = sqrt(sum(VD_Unitaire_Rayon_Refracte.^2, 1)) ;
    VD_Unitaire_Rayon_Refracte = VD_Unitaire_Rayon_Refracte ./ euclideanNorm ;
end
