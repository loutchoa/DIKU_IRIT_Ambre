function VD_Rayon_Refracte = Calculer_VD_Du_Rayon_Refracte(VD_Rayon_Incident, Normale_Dioptre, n_1, n_2)
	if isequal(cross(VD_Rayon_Incident, Normale_Dioptre), [0 ; 0 ; 0])
        VD_Rayon_Refracte = VD_Rayon_Incident ;
    else
        coeff = norm(cross(VD_Rayon_Incident, Normale_Dioptre))*sign(dot(VD_Rayon_Incident, Normale_Dioptre))/(tan(asin(norm(cross(VD_Rayon_Incident, Normale_Dioptre))*n_1/n_2)))-dot(VD_Rayon_Incident, Normale_Dioptre) ;
        VD_Rayon_Refracte = VD_Rayon_Incident + coeff*Normale_Dioptre ;
    end
    VD_Rayon_Refracte = VD_Rayon_Refracte/norm(VD_Rayon_Refracte) ;
end
