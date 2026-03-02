function plot_station_timeseries(time_years, ewh_ts, def_ts, station_name, output_dir)
% plot_station_timeseries.m
% Plots time series for EWH and crustal deformation at a station.
%
% Inputs:
%   time_years   - Vector of time in decimal years
%   ewh_ts       - Vector of Equivalent Water Height time series [cm]
%   def_ts       - Vector of crustal deformation time series [mm]
%   station_name - String with station name
%   output_dir   - Directory to save the output figure

    % Check and create output directory
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % Convert decimal year to datetime object for better x-axis labeling
    full_year = floor(time_years);
    fraction_year = time_years - full_year;
    % Assuming 365.25 days per year for conversion
    t_date = datetime(full_year, 1, 1) + days(fraction_year * 365.25);

    % Create figure window with white background
    h_fig = figure('Position', [100, 100, 1000, 800], 'Color', 'w');
    
    % Plot EWH time series
    ax1 = subplot(2, 1, 1);
    plot(t_date, ewh_ts, 'o-', 'Color', [0 0.4470 0.7410], ...
         'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'w');
    grid on; grid minor;
    ylabel('EWH [mm]', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('AOHI Equivalent Water Height - %s', station_name), ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    % Plot crustal deformation time series
    ax2 = subplot(2, 1, 2);
    plot(t_date, def_ts, 's-', 'Color', [0.8500 0.3250 0.0980], ...
         'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'w');
    grid on; grid minor;
    xlabel('Time', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Deformation [mm]', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('AOHI Crustal Deformation - %s', station_name), ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    % Configure axes limits and date format
    axis(ax1, 'tight');
    axis(ax2, 'tight');
    xtickformat(ax1, 'yyyy-MM');
    xtickformat(ax2, 'yyyy-MM');

    % Link x-axes for synchronized zooming
    linkaxes([ax1, ax2], 'x');
    
    % Save figure
    output_filename = fullfile(output_dir, sprintf('timeseries_%s.png', station_name));
    % Use print for higher resolution (300 dpi)
    print(h_fig, output_filename, '-dpng', '-r300');
    fprintf('Time series plot saved to: %s\n', output_filename);
end
