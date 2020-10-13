function directionRefractedRay = getDirectionRefractedRay(directionIncidentRay, interfaceNormals, param)
    crossProduct = cross(directionIncidentRay, interfaceNormals) ;
    dotProduct = dot(directionIncidentRay, interfaceNormals) ;
    euclideanNorm = sqrt(sum(crossProduct.^2, 1)) ;
    num = euclideanNorm.*sign(dotProduct) ;
    denum = tan(asin(euclideanNorm .* (param.IOR_1/param.IOR_2))) ;
    coeff = num./denum - dotProduct ;
    coeff(isnan(coeff)) = 0 ; % if isequal(crossProduct, [0 ; 0 ; 0]) then directionRefractedRay = directionIncidentRay ;
    directionRefractedRay = directionIncidentRay + coeff.*interfaceNormals ;
    euclideanNorm = sqrt(sum(directionRefractedRay.^2, 1)) ;
    directionRefractedRay = directionRefractedRay ./ euclideanNorm ;
end
