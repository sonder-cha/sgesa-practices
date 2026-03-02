function [t_years] = mjd2year(input_date)
% mjd2year Converts date to decimal year.
%
% Input:
%   input_date - MJD or MATLAB datenum

    % If datenum (datenum:2000->730486)
    if mean(input_date(:)) > 600000
        mjd = input_date - 678942;
    else
        mjd = input_date;
    end

    jd = mjd + 2400000.5;
    t_years = 2000 + (jd - 2451545.0) / 365.25;
end
