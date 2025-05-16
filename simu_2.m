%% Parameter Settings
L = 10; % Total staircase length (meters)
W = 1;  % Total staircase width (meters)
Nx = 100; % Number of divisions along length
Ny = 50;  % Number of divisions across width
k = 0.01; % Wear coefficient (mm/person-time)
T = 10;   % Time span (years)

% Discretization grid
x = linspace(0, L, Nx);
y = linspace(0, W, Ny);
[X, Y] = meshgrid(x, y);

% Define continuous function w(x,y) or use matrix data directly
% Using bimodal distribution as example
mu_left = W / 4; % Center of left Gaussian distribution
mu_right = 3 * W / 4; % Center of right Gaussian distribution
sigma = W / 10; % Standard deviation of Gaussian distribution
w_left = 0.1 * exp(-((Y - mu_left).^2) / (2 * sigma^2)); % Left distribution
w_right = 0.1 * exp(-((Y - mu_right).^2) / (2 * sigma^2)); % Right distribution
w = w_left + w_right; % Combined distribution

% Add random fluctuations along length to simulate non-uniform distribution
w = w .* (1 + 0.1 * rand(size(w)))*1000;

%% Calculate total staircase usage frequency F_total
dx = L / (Nx - 1); % Grid spacing in x-direction
dy = W / (Ny - 1); % Grid spacing in y-direction
integral_w = sum(w, 'all') * dx * dy; % Double integral of w(x,y)
F_total = integral_w / (k * T); % Total usage frequency

% Output results
fprintf('Total usage frequency F_total: %.2f times/year \n', F_total);

% Numerator: Integral along x-direction
numerator = sum(w, 2) * dx; % Cumulative wear value for each y-position

% Denominator: Double integral along x and y directions
denominator = sum(w, 'all') * dx * dy;

% Normalized distribution P_y(y)
P_y = numerator / denominator;

% Determine distribution type
% Check if unimodal or bimodal
[~, locs] = findpeaks(P_y); % Find peak locations
if length(locs) > 1
    disp('Multiple walking positions detected (bimodal distribution)');
else
    disp('Single walking position detected (unimodal distribution)');
end

%% Plotting Section
% 1. Plot 3D wear depth distribution w(x,y)
figure;
surf(X, Y, w);
xlabel('Length x (m)');
ylabel('Width y (m)');
zlabel('Wear depth w(x,y) (mm)');
title('Wear Depth Distribution');
colorbar;

% 2. Plot P_y(y) distribution
figure;
bar(y, P_y, 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('Width direction y (m)');
ylabel('Normalized distribution P_y(y)');
title('Width-wise Pedestrian Distribution');
grid on;

% 3. Plot heatmap of w(x,y)
figure;
imagesc(x, y, w'); % Transpose for correct coordinate display
colorbar;
xlabel('Length x (m)');
ylabel('Width y (m)');
title('Wear Depth Heatmap');