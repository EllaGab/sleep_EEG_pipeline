function density = f_local_density(onsets, window_size, sampling_rate)
%f_local_density calculated local density of events
% If sampling_rate is given, the onsets are converted to seconds
% Otherwise, the assampsion is that the onsets are already given in seconds
%
% Possible calls:
%   f_local_density(onsets, window_size)
%   f_local_density(onsets, window_size, sampling_rate)

% INPUT
%   onsets      [double]    vector with events onsets in seconds or in
%                           samples; in the latter case sampling rate is
%                           also required
%   window_size [double]    the size of the sliding window in seconds
%   sampling_rate [integer] (in Hz) If given, the onsets are converted to seconds

% OUTPUT
%       density - the mean numer of events per window size

if nargin < 3, sampling_rate = []; end

onsets = sort(onsets);

if ~isempty(sampling_rate)
    onsets = onsets/250;
end

sps_per_window = 0;
for i_event = 1:length(onsets)
    window_start = onsets(i_event) - window_size/2;
    window_end = onsets(i_event) + window_size/2;
    sps_per_window = sps_per_window + length(onsets(window_start < onsets & onsets < window_end));
end

density = sps_per_window/length(onsets);
