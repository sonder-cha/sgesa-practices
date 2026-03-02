% main_script.m
% Practice 3: GRACE Data Analysis
% Analyzes mass variations from GRACE and HI models.

clear; clc; close all;

% --- Setup ---
if ~exist('./output', 'dir')
    mkdir('./output');
end

% Add path to Practice 2 for helper functions
addpath('../Practice 2');
output_dir = './output/';

% --- Load Data ---
data_file = 'lab3_data.mat';
if ~exist(data_file, 'file')
    error('Data file %s not found.', data_file);
end
load(data_file); 
% ewh_GRACE, t_GRACE, ewh_HI, t_HI, ewh_ICE5G, greenlandmask

% --- Preprocessing ---
% Convert serial dates to decimal years if needed
if mean(t_GRACE) > 600000 
    t_GRACE_years = mjd2year(t_GRACE); 
else
    t_GRACE_years = t_GRACE; 
end

if mean(t_HI) > 600000 
    t_HI_years = mjd2year(t_HI);
else
    t_HI_years = t_HI;
end

% Create coordinate vectors (0.5 spacing)
aohi_lon = 0.5:1:359.5;
aohi_colat = 0.5:1:179.5;
aohi_lat = 90 - aohi_colat; % [89.5 ... -89.5]

% Find common time interval
[common_years, idx_GRACE, idx_HI] = intersect(round(t_GRACE_years, 4), round(t_HI_years, 4), 'stable');

fprintf('Found %d common epochs between GRACE and HI.\n', length(common_years));
fprintf('Common interval: %.2f to %.2f\n', min(common_years), max(common_years));

% --- Part 1: Global Analysis ---
fprintf('\n=== Part 1: Global Analysis ===\n');

% Extract data for common interval
ewh_GRACE_common = ewh_GRACE(:, :, idx_GRACE);
ewh_HI_common = ewh_HI(:, :, idx_HI);

% Estimate trends and amplitudes
[trend_GRACE, amp_GRACE] = estimate_global_trend_annual(ewh_GRACE_common, t_GRACE_years(idx_GRACE));
[trend_HI, amp_HI] = estimate_global_trend_annual(ewh_HI_common, t_HI_years(idx_HI));

% GIA Trend is given directly
trend_GIA = ewh_ICE5G;

% Validation Metrics
trend_diff = trend_GRACE - (trend_HI + trend_GIA);
amp_diff = amp_GRACE - amp_HI;

% Plotting Global Maps
coast_data_path = '../Practice 1/lab1_data/coast30.mat'; 
if exist(coast_data_path, 'file')
    coast_data = load(coast_data_path);
else
    warning('Coastline data not found. Plotting without coastlines.');
    coast_data = struct('lam', [], 'phi', []);
end

% --- Compute Common Color Limits ---
clim_trend = [-50, 50]; 
fprintf('Using Fixed Trend Color Limit: +/- %.2f mm/yr\n', clim_trend(2));

clim_amp = [0, 100];
fprintf('Using Fixed Amplitude Color Limit: 0 to %.2f mm\n', clim_amp(2));

% Diff Limits: Consistent with main maps for comparison
clim_diff = [-50, 50];
clim_amp_diff = [-50, 50];


% Plotting Global Maps
coast_data_path = '../Practice 1/lab1_data/coast30.mat'; 
if exist(coast_data_path, 'file')
    coast_data = load(coast_data_path);
else
    warning('Coastline data not found. Plotting without coastlines.');
    coast_data = struct('lam', [], 'phi', []);
end

% Function handle for local custom plot
plot_map = @(data, title_s, unit_s, file_s, clim_s, cmap_s) ...
    plot_global_map_custom(data, aohi_lat, aohi_lon, coast_data, title_s, unit_s, file_s, clim_s, cmap_s);

% Trends
plot_map(trend_GRACE, 'GRACE Linear Trend', 'Trend [mm/yr]', ...
    fullfile(output_dir, 'Trend_GRACE.png'), clim_trend, 'jet');

plot_map(trend_HI, 'HI Model Linear Trend', 'Trend [mm/yr]', ...
    fullfile(output_dir, 'Trend_HI.png'), clim_trend, 'jet');

plot_map(trend_GIA, 'GIA Linear Trend (ICE-5G)', 'Trend [mm/yr]', ...
    fullfile(output_dir, 'Trend_GIA.png'), clim_trend, 'jet');

plot_map(trend_diff, 'Trend Difference (GRACE - (HI + GIA))', 'Diff [mm/yr]', ...
    fullfile(output_dir, 'Trend_Difference.png'), clim_diff, 'jet');

% Amplitudes
plot_map(amp_GRACE, 'GRACE Annual Amplitude', 'Amplitude [mm]', ...
    fullfile(output_dir, 'Amplitude_GRACE.png'), clim_amp, 'parula');

plot_map(amp_HI, 'HI Annual Amplitude', 'Amplitude [mm]', ...
    fullfile(output_dir, 'Amplitude_HI.png'), clim_amp, 'parula');

plot_map(amp_diff, 'Amplitude Difference (GRACE - HI)', 'Diff [mm]', ...
    fullfile(output_dir, 'Amplitude_Difference.png'), clim_amp_diff, 'jet');


% --- Part 2: Greenland Mass Change ---
% Function to compute integrated mass
compute_mass = @(grid_ewh) compute_integrated_mass(grid_ewh, greenlandmask, aohi_lat);

% Compute for full time series
mass_GRACE_raw = compute_mass(ewh_GRACE); % Result in Gt per epoch
mass_HI = compute_mass(ewh_HI); % Result in Gt per epoch

% GIA Correction for GRACE
% Calculate total GIA rate over Greenland [Gt/yr]
rate_GIA_Gt_yr = compute_mass(ewh_ICE5G);
fprintf('Integrated GIA Rate: %.4f Gt/yr\n', rate_GIA_Gt_yr);

% Correct GRACE time series by removing accumulated GIA effect
t0_GRACE = t_GRACE_years(1);
gia_effect = rate_GIA_Gt_yr * (t_GRACE_years - t0_GRACE);
if isrow(gia_effect) ~= isrow(mass_GRACE_raw)
    gia_effect = gia_effect';
end
mass_GRACE_corrected = mass_GRACE_raw - gia_effect;

% Estimate Trend and Amplitude for Integrated Series
[trend_Gt_GRACE, amp_Gt_GRACE] = estimate_timeseries_params(mass_GRACE_corrected, t_GRACE_years);
[trend_Gt_HI, amp_Gt_HI] = estimate_timeseries_params(mass_HI, t_HI_years);

fprintf('Greenland Mass Statistics:\n');
fprintf('  GRACE (Corrected): Trend = %.2f Gt/yr, Amplitude = %.2f Gt\n', trend_Gt_GRACE, amp_Gt_GRACE);
fprintf('  HI Model         : Trend = %.2f Gt/yr, Amplitude = %.2f Gt\n', trend_Gt_HI, amp_Gt_HI);

% Plot Time Series
figure('Position', [100, 100, 1000, 600], 'Color', 'w');
% Plot 0 line
yline(0, 'k--', 'LineWidth', 1.0, 'HandleVisibility', 'off'); 
hold on;
% Plot Raw GRACE for context (optional/advanced, but good for "is reasonable" check)
% Aligning raw to start at same point as corrected for visual comparison or just plotting raw
% plot(t_GRACE_years, mass_GRACE_raw - mass_GRACE_raw(1), 'c--', 'LineWidth', 1.0, 'DisplayName', 'GRACE (Raw, offset)');

plot(t_GRACE_years, mass_GRACE_corrected, 'b.-', 'LineWidth', 1.5, 'DisplayName', 'GRACE (GIA Corrected)');
plot(t_HI_years, mass_HI, 'r.-', 'LineWidth', 1.5, 'DisplayName', 'HI Model');

xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Mass Change [Gt]', 'FontSize', 12, 'FontWeight', 'bold');
title('Greenland Ice Sheet Mass Variations', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'FontSize', 12, 'Location', 'SouthWest');
grid on;
box on;
xlim([min([t_GRACE_years; t_HI_years]), max([t_GRACE_years; t_HI_years])]);

% Add annotation with white background
result_str = sprintf('GRACE: Trend=%.1f Gt/yr, Amp=%.1f Gt\nHI: Trend=%.1f Gt/yr, Amp=%.1f Gt\nGIA Correction: %.1f Gt/yr', ...
    trend_Gt_GRACE, amp_Gt_GRACE, trend_Gt_HI, amp_Gt_HI, -rate_GIA_Gt_yr);
dim = [0.14 0.2 0.3 0.12];
annotation('textbox', dim, 'String', result_str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'EdgeColor', 'k');

output_ts_file = fullfile(output_dir, 'Greenland_Mass_TimeSeries.png');
print(gcf, output_ts_file, '-dpng', '-r300');
fprintf('Saved time series plot to %s\n', output_ts_file);
% close(gcf);

% --- Helper Functions ---
function plot_global_map_custom(grid_data, aohi_lat, aohi_lon, coast_data, title_str, unit_str, output_filename, clim_val, cmap_name)
    % Optimized plotting with clim control and resolution
    
    h_fig = figure('Position', [100, 100, 1000, 500], 'Color', 'w', 'Visible', 'off');
    
    [LON, LAT] = meshgrid(aohi_lon, aohi_lat);
    pcolor(LON, LAT, grid_data);
    shading interp;
    hold on;
    
    if ~isempty(coast_data.lam)
        plot(coast_data.lam, coast_data.phi, 'k-', 'LineWidth', 0.8);
    end
    
    cb = colorbar;
    ylabel(cb, unit_str, 'FontSize', 11, 'FontWeight', 'bold');
    
    if nargin >= 9 && ~isempty(cmap_name)
        colormap(cmap_name);
    else
        colormap('parula');
    end
    
    if nargin >= 8 && ~isempty(clim_val)
        caxis(clim_val);
    end
    
    xlabel('Longitude [°]', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Latitude [°]', 'FontSize', 11, 'FontWeight', 'bold');
    title(title_str, 'FontSize', 14, 'FontWeight', 'bold');
    
    axis tight;
    set(gca, 'Layer', 'top', 'FontSize', 10, 'LineWidth', 1.0);
    
    print(h_fig, output_filename, '-dpng', '-r300');
    % close(h_fig);
end

function total_mass_Gt = compute_integrated_mass(data_cube, mask, lat_vec)
    % compute_integrated_mass
    % Integrates EWH over masked region accounting for grid cell area.
    
    [n_lat, n_lon, n_time] = size(data_cube);
    mask = (mask > 0);
    
    % Area calculation: (111 km)^2 * cos(lat)
    base_area_m2 = (111000)^2; 
    area_grid_m2 = zeros(n_lat, n_lon);
    for i = 1:n_lat
        area_grid_m2(i, :) = base_area_m2 * cosd(lat_vec(i));
    end
    
    total_mass_Gt = zeros(n_time, 1);
    for t = 1:n_time
        if ndims(data_cube) == 3
            slice = data_cube(:, :, t);
        else
            slice = data_cube;
        end
        % Integration: [kg] * 1e-12 = [Gt]
        masked_data = slice .* mask;
        total_mass_kg = sum(sum(masked_data .* area_grid_m2), 'omitnan');
        total_mass_Gt(t) = total_mass_kg * 1.0e-12;
    end
end

function [trend, amp] = estimate_timeseries_params(vals, vy)
    % Robust Linear Trend + Annual Signal estimation 
    if isempty(vals) || isempty(vy), trend=NaN; amp=NaN; return; end
    
    t0 = vy(1);
    t = vy - t0;
    omega = 2 * pi;
    
    A = [ones(length(t), 1), t, cos(omega * t), sin(omega * t)];
    
    % Handle shapes
    if size(vals, 1) == 1, vals = vals'; end
    if size(t, 1) == 1, t = t'; end
    
    % Basic Least Squares
    x = (A' * A) \ (A' * vals);
    trend = x(2);
    amp = sqrt(x(3)^2 + x(4)^2);
end
