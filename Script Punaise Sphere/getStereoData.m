%% Prepare Stereo Data
%% Pictures are "vectorized" and neighboring pixels are aligned along the 3rd dimension

function dataImStereo = getStereoData(data)
    [nb_rows, nb_col, nb_ch, nb_im] = size(data.Imgs);
    dataImStereo = zeros(nb_rows*nb_col, 9, nb_ch, nb_im, 'uint8') ;
    for picture = 1:nb_im
        antiMask = data.Masques_Imgs(:,:,picture) == 0;
        currentIm = data.Imgs(:,:,:,picture);
        currentIm = reshape(currentIm, [nb_rows * nb_col, nb_ch]);
        currentIm(antiMask, :) = 0;
        currentIm = reshape(currentIm, [nb_rows, nb_col, nb_ch]);
        imStereo = cat(4,...
            currentIm([1 1:end-1],[1 1:end-1],:),...                        % Top left
            currentIm([1 1:end-1],:,:),...                                  % Top
            currentIm([1 1:end-1],[2:end end],:),...                        % Top right
            currentIm(:,[1 1:end-1],:),...                                  % Left
            currentIm,...                                                   % Center
            currentIm(:,[2:end end],:),...                                  % Right
            currentIm([2:end end],[1 1:end-1],:),...                        % Bottom left
            currentIm([2:end end],:,:),...                                  % Bottom
            currentIm([2:end end],[2:end end],:));                          % Bottom right
        imStereo = reshape(imStereo,[nb_rows * nb_col, nb_ch,9]);
        dataImStereo(:,:,:,picture) = permute(imStereo,[1,3,2]);
    end
end
