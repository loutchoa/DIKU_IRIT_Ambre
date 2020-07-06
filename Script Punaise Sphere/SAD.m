function score = SAD(f1,f2,masque1,masque2)
    v1 = double(f1(:)).*[masque1(:); masque1(:); masque1(:)];
    v2 = double(f2(:)).*[masque2(:); masque2(:); masque2(:)];
    score = sum(abs(v1-v2));
end