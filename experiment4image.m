clc;
clear;
% 获取当前文件的根目录
rootDir = fileparts(mfilename('fullpath'));

% 将根目录及其所有子目录添加到路径
addpath(genpath(rootDir));
% img = double(imread('airplane.bmp'));
% load("EMA_7P_tensor.mat");
load("friedrichshain-center_8P_tensor.mat");
img = x;
% img = img/255;
img = img / max(abs(img(:)));
sz = size(img);
% img = reshape(img,16, 16, sz(2), sz(3));
missing_ratio = 0.9;
sz = size(img);
mask = genMask(sz, missing_ratio);
tObs = mask .* img;

i = 1;
opt2.iter1 = 300;
opt2.init = 'rand';
opt2.initScale = .5;
opt2.epsilon = -1.0;
opt2.trun = 1e-4;
opt2.isPrune = true;
opt2.isELBO = true;
opt2.pruneMethod = 'relative';
opt2.tol = 1e-3;

for n = 1:length(sz)
    theta = 1e1;
    Lu = zeros(sz(n), sz(n));
    for ii = 1 : sz(n)
        for jj = 1 : sz(n)
            Lu(ii,jj) = exp(-(ii-jj)^2/theta^2);
        end
    end
    % Ku{n} = eye(sz(n));
    Ku{n} = Lu;
end

RInit = [7, 8, 15];
tic;
[model] = VKBTR(img, mask, RInit, Ku, opt2);
Timelist(i,1) = toc;
X_VKBTR = coreten2tr(model.G);
% RSElist(i,1) = perfscore(X_VKBTR*255, img*255);
% PSNRlist(i,1) = PSNR_RGB(X_VKBTR*255,img*255);
% SSIMlist(i,1) = ssim_index(rgb2gray(uint8(X_VKBTR*255)),rgb2gray(uint8(img*255)));
