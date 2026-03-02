function plot_residuals(time, data, station_name)
% plot_residuals.m
% Plots the residuals of the East, North, and Up time series.

    figure();
    
    % East component residuals
    subplot(3, 1, 1);
    plot(time, data(:, 1), '.');
    title('Residuals Time Series Plot');
    ylabel('East (mm)');
    grid on;
    
    % North component residuals
    subplot(3, 1, 2);
    plot(time, data(:, 2), '.');
    ylabel('North (mm)');
    grid on;
    
    % Up component residuals
    subplot(3, 1, 3);
    plot(time, data(:, 3), '.');
    ylabel('Up (mm)');
    xlabel('Year');
    grid on;
    
    saveas(gcf, ['./output/' station_name '_residuals.png']);
end