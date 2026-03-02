function plot_global_map(grid_data, aohi_lat, aohi_lon, coast_data, title_str, unit_str, output_filename)
% plot_global_map.m
% Visualizes global grid data with proper formatting and coastlines.
%
% Inputs:
%   grid_data       - 2D array (lat x lon) of data to plot
%   aohi_lat        - Vector of latitude coordinates
%   aohi_lon        - Vector of longitude coordinates
%   title_str       - String for plot title
%   unit_str        - String for colorbar label (units)
%   output_filename - Full path to save the figure

    % Ensure output directory exists
    output_dir = fileparts(output_filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % Create figure with white background
    h_fig = figure('Position', [100, 100, 1200, 600], 'Color', 'w');
    
    % Create meshgrid for plotting
    [LON, LAT] = meshgrid(aohi_lon, aohi_lat);
    
    % Plot using pcolor
    pcolor(LON, LAT, grid_data);
    shading interp;
    hold on;
    
    % Plot coastlines in black
    plot(coast_data.lam, coast_data.phi, 'k-', 'LineWidth', 0.8);
    
    % Configure colorbar
    cb = colorbar;
    ylabel(cb, unit_str, 'FontSize', 12, 'FontWeight', 'bold');
    
    % Set colormap
    % 'parula' is perceptually uniform; use 'jet' if rainbow style is strictly required
    colormap(parula); 
    
    % Set axis properties
    xlabel('Longitude [degrees]', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Latitude [degrees]', 'FontSize', 12, 'FontWeight', 'bold');
    title(title_str, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Set axis limits and aspect
    axis tight;
    box on;
    
    % Ensure ticks and grid are on top of the pcolor map
    set(gca, 'Layer', 'top', 'FontSize', 12, 'LineWidth', 1.2);
    
    % Save figure with high resolution
    print(h_fig, output_filename, '-dpng', '-r300');
end
