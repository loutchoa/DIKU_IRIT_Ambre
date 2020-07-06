function Booleen = Est_Dans_Ambre(Point)
    Point = Point - [0 ; 0 ; 100] ;
    R = [0.7644    0.0494    0.6428 ;
        -0.2800    0.9235    0.2620 ;
        -0.5807   -0.3803    0.7198] ;
    Point = R*Point ;
    Point(1) = (1/15)*Point(1) ;
    Point(2) = (1/9)*Point(2) ;
    Point(3) = (1/17)*Point(3) ;
    Booleen = sum(Point.^2) < 1 ;
end