% main_script.m
% Main script to run the entire analysis for SGESA Practical 1.

clear; clc; close all;

% --- Configuration ---
% Define the three stations to be analyzed
station_list = {'KIRU', 'THU3', 'ONSA'}; % Group 1: 'KIRU', 'THU3', 'ONSA'
num_stations = length(station_list);

% Define file paths
data_path = './lab1_data/';
itrf_file = [data_path, 'ITRF2008_GNSS.SSC.txt'];
discontinuity_file = [data_path, 'Discontinuities_CONFIRMED.snx'];
nuvel_file = [data_path, 'NNR_NUVEL1A.txt'];
gia_ice4g_file = [data_path, 'crust_ICE4G.mat'];
gia_ice5g_file = [data_path, 'crust_ICE5G.mat'];
coastline_file = [data_path, 'coast30.mat'];

% --- Data Structures to Store Results ---
Results = struct();

% --- Main Processing Loop for Each Station ---
for i = 1:num_stations
    station_name = station_list{i};
    fprintf('Processing station: %s\n', station_name);
    
    % --- Task 1: Load Data and Coordinate Transformation ---
    xyz_file = [data_path, upper(station_name), '_ig1.xyz'];
    
    % Load time series data (MJD, X, Y, Z)
    [time_mjd, xyz_coords] = load_station_data(xyz_file);
    time_year = mjdweek2year(time_mjd); % Convert MJD week to decimal year
    
    % Get ITRF2008 reference coordinates (X0, Y0, Z0)
    [xyz0, llh0_deg] = get_reference_coord(itrf_file, station_name);
    
    % Transform from geocentric (XYZ) to local (ENU)
    enu_coords = transform_to_local(xyz_coords, xyz0, llh0_deg);
    
    % Find discontinuities for plotting
    jump_times = find_discontinuities(discontinuity_file, station_name);
    
    % Visualize the time series in the local system
    plot_timeseries(time_year, enu_coords * 1000, station_name, jump_times);
    
    % --- Task 2 & 3: Least Squares Estimation and Residuals ---
    % Estimate linear trend and annual signal
    % Task 2: Compute linear trend and amplitude of seasonal signal
    [params, residuals] = estimate_kinematics(time_year, enu_coords, discontinuity_file, station_name);
    
    % Store results
    Results.(station_name).llh0_deg = llh0_deg;
    Results.(station_name).xyz0 = xyz0;
    Results.(station_name).trend_mm_yr = params(:, 2) * 1000; % Convert m/yr to mm/yr
    Results.(station_name).amplitude_mm = sqrt(params(:, 3).^2 + params(:, 4).^2) * 1000; % in mm
    
    % Task 3: Reduce linear trend to identify small non-linear variations (Residuals)
    % Plot residuals
    plot_residuals(time_year, residuals * 1000, station_name);
    
    % --- Task 5: Compute Horizontal Movement from NNR-NUVEL 1A ---
    [v_nuvel_enu] = calculate_nuvel_velocity(nuvel_file, station_name, xyz0, llh0_deg);
    Results.(station_name).nuvel_v_ne_mm_yr = [v_nuvel_enu(1); v_nuvel_enu(2)] * 1000; % North, East
    
    % --- Task 9: Interpolate Vertical Movement from GIA models ---
    v_up_ice4g = interpolate_gia_rate(gia_ice4g_file, llh0_deg);
    v_up_ice5g = interpolate_gia_rate(gia_ice5g_file, llh0_deg);
    Results.(station_name).gia_v_up_mm_yr = [v_up_ice4g; v_up_ice5g];
    
end

% --- Generate Summary Tables ---
generate_summary_tables(Results, station_list);

% --- Task 6 & 7: Compare Horizontal Movements ---
% Visualize comparison between GNSS and NNR-NUVEL 1A
plot_velocity_vectors(Results, station_list, coastline_file);

% --- Task 8: Visualize GIA models ---
plot_gia_map(gia_ice4g_file, 'ICE-4G', coastline_file, Results, station_list);
plot_gia_map(gia_ice5g_file, 'ICE-5G', coastline_file, Results, station_list);

fprintf('Analysis complete. Results saved in ./output/\n');

% --- Helper Functions ---
% function [time_mjd, xyz_coords] = load_station_data(filename)
% function [xyz0, llh0_deg] = get_reference_coord(itrf_file, station_name)
% function enu_coords = transform_to_local(xyz, xyz0, llh0_deg)
% function [params, residuals] = estimate_kinematics(time_year, enu_coords, discontinuity_file, station_name)
% function jump_times_year = find_discontinuities(discontinuity_file, station_name)
% function [v_nuvel_enu] = calculate_nuvel_velocity(nuvel_file, station_name, xyz0, llh0_deg)
% function v_up = interpolate_gia_rate(gia_file, llh0_deg)
% function plot_timeseries(time, data, station_name)
% function plot_residuals(time, data, station_name)
% function plot_velocity_vectors(Results, station_list, coastline_file)
% function plot_gia_map(gia_file, model_name, coastline_file, Results, station_list)
% function generate_summary_tables(Results, station_list)