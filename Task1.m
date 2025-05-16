%% Parameter Settings
L = 10; % Total staircase length (meters)
W = 1;  % Single step width (meters)
Nx = 100; % Number of divisions along length
Ny = 50;  % Number of divisions across step width
w_max = 0.2; % Maximum wear depth (mm)
num_steps = 5; % Number of steps to simulate
k = 0.00001; % Wear coefficient (meters/person)
T = 1000;   % Time span (years)

%% Read grayscale image and generate wear distribution
image_path = 'D:\OneDrive-Mcmaster\OneDrive - McMaster University\桌面\f0.png'; % Replace with your image path
gray_image = imread(image_path); % Read image

% Convert to grayscale if RGB
if size(gray_image, 3) == 3
    gray_image = rgb2gray(gray_image);
end 

gray_image = double(gray_image); 
normalized_image = gray_image / 255; 

w_image = normalized_image * w_max;
h = fspecial('gaussian', [5, 5], 1);
w_smoothed = imfilter(w_image, h, 'replicate');
w_resized = imresize(w_smoothed, [Ny, Nx]);

% Initialize multi-step distribution
[Ny, Nx] = size(w_resized); % Get single step dimensions
multi_step = zeros(Ny * num_steps, Nx); % Create multi-step matrix

% Construct multiple step distribution
for i = 1:num_steps
    % Current step distribution + random perturbation
    current_step = w_resized + 0.02 * rand(size(w_resized));
    multi_step((i-1)*Ny + 1:i*Ny, :) = current_step; % Add to multi-step matrix
end

%% Replace with bimodal wear depth distribution w(x, y)
w = multi_step*1000;

% Grid generation
x = linspace(0, L, Nx);
y = linspace(0, W * num_steps, Ny * num_steps);
[X, Y] = meshgrid(x, y);

%% Calculate F_total
dx = L / (Nx - 1); 
dy = (W * num_steps) / (Ny * num_steps - 1); 
integral_w = sum(w, 'all') * dx * dy; 
F_total = integral_w / (k * T);

% Print output
fprintf('Using frequency F_total: %.2f people/year \n', F_total);

numerator = sum(w, 2) * dx;
denominator = sum(w, 'all') * dx * dy;
P_y = numerator / denominator;

[~, locs] = findpeaks(P_y);
if length(locs) > 1
    disp('Multiple walking positions detected (bimodal distribution)');
else
    disp('Single walking position detected (unimodal distribution)');
end

%% Plotting Section
% 1. Plot 3D wear depth distribution w(x, y)
figure;
surf(X, Y, w);
xlabel('Length x (m)');
ylabel('Width y (m)');
zlabel('Wear depth w(x, y) (mm)');
title('Wear Depth Distribution');
colorbar;

% 2. Plot width-wise normalized distribution P_y(y)
figure;
bar(y, P_y, 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('Width direction y (m)');
ylabel('Normalized distribution P_y(y)');
title('Width-wise Pedestrian Distribution');
grid on;

% 3. Plot wear depth heatmap w(x, y)
figure;
imagesc(x, y, w'); % Transpose for correct coordinate display
colorbar;
xlabel('Length x (m)');
ylabel('Width y (m)');
title('Wear Depth Heatmap');

%% Export data matrix
output_file = 'multi_step_combined_data.csv';
csvwrite(output_file, w); % Save data to CSV file
disp(['File saved to: ', output_file]);