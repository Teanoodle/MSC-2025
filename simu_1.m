%% Parameter Settings
L = 10; % Total staircase length (meters)
W = 1;  % Total staircase width (meters)
Nx = 100; % Number of divisions along length
Ny = 50;  % Number of divisions across width

% Discretization grid
x = linspace(0, L, Nx);
y = linspace(0, W, Ny);
[X, Y] = meshgrid(x, y);

% Define left peak Gaussian distribution (sharper)
mu_left = W / 4; % Center of left Gaussian distribution
sigma_left = W / 20; % Std dev of left Gaussian (smaller, sharper peak)
w_left = 0.1 * exp(-((Y - mu_left).^2) / (2 * sigma_left^2)); % Left distribution

% Define right peak Gaussian distribution (wider and flatter)
mu_right = 3 * W / 4; % Center of right Gaussian distribution
sigma_right = W / 5; % Std dev of right Gaussian (larger, wider peak)
w_right = 0.15 * exp(-((Y - mu_right).^2) / (2 * sigma_right^2)); % Right distribution (higher amplitude)

% Intermediate transition distribution
mu_center = W / 2; % Center of middle Gaussian distribution
sigma_center = W / 8; % Std dev of middle distribution
w_center = 0.05 * exp(-((Y - mu_center).^2) / (2 * sigma_center^2)); % Middle region

% Add linear gradient and noise
linear_gradient = 0.005 * (1 - abs(Y - W / 2) / (W / 2)); % Symmetric decreasing gradient across width
random_noise = 0.005 * rand(size(Y)); % Random noise

% Combine all distributions
w = w_left + w_right + w_center + linear_gradient + random_noise;

%% Plotting
% 3D plot of wear depth distribution
figure;
surf(X, Y, w);
xlabel('Length x (m)');
ylabel('Width y (m)');
zlabel('Wear depth w(x,y) (mm)');
title('Wear Depth Distribution');
colorbar;

% Heatmap plot
figure;
imagesc(x, y, w');
colorbar;
xlabel('Length x (m)');
ylabel('Width y (m)');
title('Wear Depth Heatmap');