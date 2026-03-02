% main_script.m
% Analyzes AOHI (Atmosphere, Ocean, Hydrology, Ice) geophysical model.

clear; clc; close all;

% --- Configuration ---
% Define the three stations to be analyzed
station_list = {'KIRU', 'THU3', 'ONSA'}; % Group 1: 'KIRU', 'THU3', 'ONSA'
num_stations = length(station_list);

% Define file paths
data_file = 'lab2_data.mat';
lab1_path = '../Practice 1/';
output_dir = './output/';

% Create output directory if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% --- Load AOHI Data ---
fprintf('Loading AOHI data...\n');
load(data_file); % Loads: aohi_ewh, aohi_def, t
aohi_def = aohi_def * 1000; % mm

% Get data dimensions
[n_lat, n_lon, n_time] = size(aohi_ewh);
fprintf('Data dimensions: %d lat x %d lon x %d time steps\n', n_lat, n_lon, n_time);

% Create coordinate grids
% The data is organized as (lat x lon x time)
aohi_lat = linspace(90, -90, n_lat);
aohi_lon = linspace(0, 360, n_lon);

% Convert time from MJD to decimal years
time_years = mjd2year(t);
fprintf('Time range: %.2f to %.2f (%.1f years)\n', ...
    min(time_years), max(time_years), max(time_years) - min(time_years));

% --- Task 1: Global Analysis of AOHI Mass Variations ---
fprintf('\n=== Task 1: Global Analysis ===\n');

% Estimate linear trend and annual signal for EWH
[trend_ewh, amplitude_ewh] = estimate_global_trend_annual(aohi_ewh, time_years);

% Estimate linear trend and annual signal for crustal deformation
[trend_def, amplitude_def] = estimate_global_trend_annual(aohi_def, time_years);


% Overlay global coastlines for context
coast_data = fullfile(lab1_path, 'lab1_data/coast30.mat');
if exist(coast_data, 'file')
    coast_data = load(coast_data);
else
    warning('Coastline data (coast30.mat) not found. Skipping coastline overlay.');
end

% Visualize global EWH results
plot_global_map(trend_ewh, aohi_lat, aohi_lon, coast_data, ...
    'Global Linear Trend - Equivalent Water Height', 'Trend [mm/year]', ...
    fullfile(output_dir, 'global_trend_ewh.png'));

plot_global_map(amplitude_ewh, aohi_lat, aohi_lon, coast_data, ...
    'Global Annual Amplitude - Equivalent Water Height', 'Amplitude [mm]', ...
    fullfile(output_dir, 'global_amplitude_ewh.png'));

% Visualize global deformation results
plot_global_map(trend_def, aohi_lat, aohi_lon, coast_data, ...
    'Global Linear Trend - Crustal Deformation', 'Trend [mm/year]', ...
    fullfile(output_dir, 'global_trend_def.png'));

plot_global_map(amplitude_def, aohi_lat, aohi_lon, coast_data, ...
    'Global Annual Amplitude - Crustal Deformation', 'Amplitude [mm]', ...
    fullfile(output_dir, 'global_amplitude_def.png'));

% --- Load Lab 1 Station Coordinates ---
lab1_results_file = fullfile(lab1_path, 'Results.mat');
if exist(lab1_results_file, 'file')
    load(lab1_results_file);
    fprintf('Loaded Lab 1 results from Results.mat\n');
else
    fprintf('Results.mat not found. Loading ITRF file for station coordinates...\n');
    itrf_file = fullfile(lab1_path, 'lab1_data', 'ITRF2008_GNSS.SSC.txt');
    
    % Read ITRF file to get station coordinates
    Results = struct();
    
    % For now, manually enter known coordinates (these should be from ITRF)
    Results.KIRU.llh0_deg = [67.86; 20.97; 0];
    Results.THU3.llh0_deg = [76.54; -68.82; 0];
    Results.ONSA.llh0_deg = [57.40; 11.93; 0];
    
    fprintf('Using approximate station coordinates.\n');
end

% --- Task 2: Station Time Series ---
fprintf('\n=== Task 2: Station Time Series ===\n');

% Initialize station results structure
StationResults = struct();

for i = 1:num_stations
    station_name = station_list{i};
    fprintf('Processing station: %s\n', station_name);
    
    % Get station coordinates from Lab 1
    station_lat = Results.(station_name).llh0_deg(1);
    station_lon = Results.(station_name).llh0_deg(2);
    
    fprintf('  Coordinates: %.2f°N, %.2f°E\n', station_lat, station_lon);
    
    % Interpolate EWH time series to station position
    ewh_station = interpolate_to_stations(aohi_ewh, aohi_lat, aohi_lon, ...
        station_lat, station_lon);
    
    % Interpolate deformation time series to station position
    def_station = interpolate_to_stations(aohi_def, aohi_lat, aohi_lon, ...
        station_lat, station_lon);
    
    % Plot time series
    plot_station_timeseries(time_years, ewh_station, def_station, ...
        station_name, output_dir);
    
    % Store results
    StationResults.(station_name).ewh_ts = ewh_station;
    StationResults.(station_name).def_ts = def_station;
    StationResults.(station_name).lat = station_lat;
    StationResults.(station_name).lon = station_lon;
end

% --- Task 3: Estimate Trends and Annual Signals at Stations ---
fprintf('\n=== Task 3: Station Kinematics and Comparison ===\n');

for i = 1:num_stations
    station_name = station_list{i};
    fprintf('Analyzing station: %s\n', station_name);
    
    % Get time series
    ewh_ts = StationResults.(station_name).ewh_ts;
    def_ts = StationResults.(station_name).def_ts;
    
    % Estimate linear trend and annual signal for EWH
    t0 = time_years(1);
    t = time_years - t0;
    omega = 2 * pi;
    A = [ones(n_time, 1), t, cos(omega * t), sin(omega * t)];
    
    % Solve for EWH
    x_ewh = (A' * A) \ (A' * ewh_ts);
    trend_ewh_station = x_ewh(2);
    amp_ewh_station = sqrt(x_ewh(3)^2 + x_ewh(4)^2);
    
    % Solve for deformation
    x_def = (A' * A) \ (A' * def_ts);
    trend_def_station = x_def(2);
    amp_def_station = sqrt(x_def(3)^2 + x_def(4)^2);
    
    % Store results
    StationResults.(station_name).trend_ewh = trend_ewh_station;
    StationResults.(station_name).amplitude_ewh = amp_ewh_station;
    StationResults.(station_name).trend_def = trend_def_station;
    StationResults.(station_name).amplitude_def = amp_def_station;
    
    fprintf('  EWH Trend: %.3f mm/yr, Amplitude: %.3f mm\n', ...
        trend_ewh_station, amp_ewh_station);
    fprintf('  Deformation Trend: %.3f mm/yr, Amplitude: %.3f mm\n', ...
        trend_def_station, amp_def_station);
end

% --- Compare with Lab 1 Results ---
fprintf('\n=== Comparison with Lab 1 (GNSS and GIA) ===\n');

if exist(lab1_results_file, 'file')
    comparison_table = compare_with_lab1(StationResults, Results);
else
    fprintf('Lab 1 Results.mat not found. Skipping detailed comparison.\n');
    fprintf('Please ensure Lab 1 analysis has been run and Results.mat is saved.\n');
end

% --- Save Results ---
save(fullfile(output_dir, 'Lab2_StationResults.mat'), 'StationResults');
fprintf('\nResults saved to: %s\n', fullfile(output_dir, 'Lab2_StationResults.mat'));