% Parameter Settings
L = 10; % Staircase length (unit: meters)
Nx = 100; % Number of horizontal grid divisions
x = linspace(0, L, Nx); % Discrete points along the staircase length

W = 1; % Staircase width (unit: meters)
Ny = 50; % Number of width-wise grid divisions
y = linspace(0, W, Ny); % Discrete points along the staircase width

T = 24; % Simulation time (unit: hours)
Nt = 24; % Number of time steps
t = linspace(0, T, Nt); % Time discretization

% Total pedestrian flow over time
N_t = zeros(1, Nt);
N_t(1:8) = 500; % Morning peak (6:00 - 9:00)
N_t(9:16) = 200; % Midday trough (10:00 - 15:00)
N_t(17:24) = 400; % Evening peak (16:00 - 19:00)

% Horizontal distribution (normal distribution)
mu_x = L / 2; % Center of pedestrian flow at midpoint
sigma_x = L / 4; % Distribution width
p_x = exp(-(x - mu_x).^2 / (2 * sigma_x^2));
p_x = p_x / trapz(x, p_x); % Normalized distribution

% Lateral distribution (biased to the left)
mu_y = W / 3; % Bias to the left
sigma_y = W / 6; % Distribution width
p_y = exp(-(y - mu_y).^2 / (2 * sigma_y^2));
p_y = p_y / trapz(y, p_y); % Normalized distribution

% Wear model parameters
k = 0.001; % Wear coefficient (unit: mm/person)
delta = ones(Nx, Nt); % Direction factor, assumed constant

% Initialize wear depth
w = zeros(Nx, Nt); % Wear depth matrix

% Step-by-step wear depth calculation
for j = 1:Nt-1
    % Calculate pedestrian distribution at each time step
    lambda_x = N_t(j) * p_x; % Horizontal pedestrian distribution
    for i = 1:Nx
        w(i, j+1) = w(i, j) + k * lambda_x(i) * delta(i, j) * (trapz(y, p_y)); % Wear calculation
    end
end

% Visualization
figure;

% 1. Staircase usage frequency distribution
subplot(3, 1, 1);
plot(x, trapz(t, w, 2), 'LineWidth', 2);
xlabel('Staircase length position (m)');
ylabel('Cumulative usage frequency (unit: mm)');
title('Staircase Cumulative Usage Frequency Distribution');
grid on;

% 2. Directional preference
subplot(3, 1, 2);
bar(y, p_y, 'FaceColor', [0.2, 0.7, 0.9]);
xlabel('Staircase width direction (m)');
ylabel('Probability density');
title('Lateral Pedestrian Distribution (Directional Preference)');
grid on;

% 3. Instantaneous pedestrian distribution
subplot(3, 1, 3);
imagesc(t, x, w);
colorbar;
xlabel('Time (hours)');
ylabel('Staircase length position (m)');
title('Instantaneous Pedestrian Distribution (Wear Depth Over Time)');
grid on;