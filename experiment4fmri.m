clc;
clear;

rootDir = fileparts(mfilename('fullpath'));

addpath(genpath(rootDir));

% MODIFY: load the fMRI data, the code below is orinally for color video
% NOTE!: this algorithm seems to use a lot of RAM, consider using few frames
load('claire.mat');
img = double(claire(:,:,:,1:30));
img = img/255;
sz = size(img);
indice = randperm(sz(4), sz(4)*0.2);

X_noise = img;

% MODIFY: create the mask
missing_ratio = 0.9; 
mask1 = ones(sz);
mask1(:,:,:,indice) = 0;
mask2 = genMask(sz, missing_ratio);
mask = mask1 .* mask2;

% observation
tObs = mask .* X_noise;
 
i = 1;
opt2.iter1 = 100; % maybe you will need to modify this number of iterations
opt2.init = 'rand'; % maybe you will need to modify this: rand or randn
opt2.initScale = 0.5;
opt2.epsilon = -1.0;
opt2.trun = 1e-5;
opt2.isPrune = true;
opt2.pruneMethod = 'absolute'; % maybe you will need to modify this: absolute or relative
opt2.tol = 1e-3;

% create the kernel for each mode
% theta is important
for n = [1,2,3,4]
    theta = 1e1; % GRIDSEARCH to find theta
    Lu = zeros(sz(n),sz(n));
    for ii = 1 : sz(n)
        for jj = 1 : sz(n)
            Lu(ii,jj) = exp(-(ii-jj)^2/theta^2);
        end
    end
    Ku{n} = Lu;
end

% GRIDSEARCH to find initial ranks
% NOTE!: cause memory overflow when using just rank~20
RInit = [10,10,10,10];
tic;
[model] = VKBTR(tObs, mask, RInit, Ku, opt2);
Timelist(i,1) = toc;
X_VKBTR = coreten2tr(model.G);

% MODIFY: measure the RSE that we want to use
[RSElist(i,1),PSNRlist(i,1), SSIMlist(i,1)] = MSIQA4color(X_VKBTR*255, img*255);

