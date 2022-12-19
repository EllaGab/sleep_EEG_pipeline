function sps_info = f_extract_sps_features(fpath, electrode, sleep_stage)
%f_extract_sps_features(fpath, electrode, sleep_stage) returns a table with spindle features
%   Onsets and durations are converted to seconds besed on the sampling rate listed in the spindle
%   mat file; for more details, see the description for INPUT arguments

% Possible calls:
%   f_extract_sps_features(fpath, electrode, sleep_stage)
%
% INPUT:
%   fpath       [string]    full path to the spindle mat file - the output
%                           from the spindle detection algorithm;
%                           should have Date, Info, SS
%   electrode   [string]    the electrode of interest, e.g., 'Pz'
%   sleep_stage [string]    'NREM2' - for NREM2; 'NREM3' - for NREM3; 'NREM23' - for NREM2 & NREM3 together
%
% OUTPUT
%   sps_info    [struct]
%       a structure with analysis info & a table with spindle features
%       .sps    [table]
%           Information extracted for each spindle:
% 	            .onset 		spindle onset in seconds
% 	            .duration 	spindle duration in seconds
% 	            .freq		spindle frequency in Hz
% 	            .peakPos	the highest signal intensity in microvolts, i.e., the highest peak
% 	            .peakNeg 	the lowest signal intensity in microvolts, i.e., the lowest trough
% 	            .peak2peak 	the amplitude of the largest wave with the largest difference between its peak and trough
% 	            .nWaves 	the number of waves in the spindle
% 	            .symmetry 	an index, between 0 and 1, indicating spindle symmetry relative to the highest peak;
%                           0.5 perfectly symmetrical with the equal number of peaks before and after the highest peak


% Sleep Stage 
disp(['Sleep stage: ' sleep_stage]);
if strcmp(sleep_stage,'NREM2')
    indSleepStage = 2;
elseif strcmp(sleep_stage,'NREM3')
    indSleepStage = 3;
elseif strcmp(sleep_stage,'NREM23')
    indSleepStage = [2 3];
end

% LOAD Spindles;
% each line represents one detected spindle over all recorded electrodes
%disp('Load spindles')
load_SS     = load(fpath, 'SS');
SS          = load_SS.SS;

% LOAD Info
load_Info   = load(fpath, 'Info');
Info        = load_Info.Info;

indexElectrode = find(strcmp({Info.Electrodes.labels}, electrode)==1);

% Display the number of detected spindles over all electrodes
disp(['Found ', num2str(length(SS)) ' spindles over all electrodes and sleep stages'])

% Reorganize data so that each column contains data for one electrode
scoring         = reshape([SS.scoring], length(Info.Electrodes), length(SS))';              % detected spindles are marked with numbers indicating their sleep stage 
refStarts       = reshape([SS.Ref_Start], length(Info.Electrodes), length(SS))';            % spindle starts/onsets
refEnds         = reshape([SS.Ref_End], length(Info.Electrodes), length(SS))';              % spindle ends
refFreq         = reshape([SS.Ref_Frequency], length(Info.Electrodes), length(SS))';        % spindle frequency
refPeakPos      = reshape([SS.Ref_PositivePeak], length(Info.Electrodes), length(SS))';   	% positive spindle peak
refPeakNeg      = reshape([SS.Ref_NegativePeak], length(Info.Electrodes), length(SS))';   	% negative spindle peak
refPeak2Peak 	= reshape([SS.Ref_Peak2Peak], length(Info.Electrodes), length(SS))';        % spindle mean peak2peak
refNWaves       = reshape([SS.Ref_NumberOfWaves], length(Info.Electrodes), length(SS))';  	% a number of waves within the spindle
refSymmetry  	= reshape([SS.Ref_Symmetry], length(Info.Electrodes), length(SS))';         % spinlde symmetry

% Get spindle indices detected over the target electrode during the sleep stage(s) of interest
indsSpFound = find(ismember(scoring(:,indexElectrode), indSleepStage));

% Show spindles on specific electrode and scoring
disp(['Found ' num2str(numel(indsSpFound)), ' spindles on ' electrode ' for ' sleep_stage]);

% Get onsets, in the ascending order, for spindles of interest only
currSpStarts                = refStarts(indsSpFound, indexElectrode);
[currSpStarts, sort_inds]   = sort(currSpStarts);
currSpStarts                = currSpStarts/Info.Recording.sRate; % convert into seconds with accuracy level of 6 decimal digits

% Get ends, in the same order as starts, for spindles of interest only
currSpEnds	= refEnds(indsSpFound, indexElectrode);
currSpEnds	= currSpEnds(sort_inds)/Info.Recording.sRate; % convert into seconds with accuracy level of 6 decimal digits

% Get other features, in the same order as starts, for spindles of interest only   
currSpFreq      = refFreq(indsSpFound, indexElectrode);
currSpFreq      = currSpFreq(sort_inds);
currSpPeakPos   = refPeakPos(indsSpFound, indexElectrode);
currSpPeakPos	= currSpPeakPos(sort_inds);
currSpPeakNeg   = refPeakNeg(indsSpFound, indexElectrode);
currSpPeakNeg	= currSpPeakNeg(sort_inds);
currSpPeak2Peak	= refPeak2Peak(indsSpFound, indexElectrode);
currSpPeak2Peak	= currSpPeak2Peak(sort_inds);
currSpNWaves   = refNWaves(indsSpFound, indexElectrode);
currSpNWaves	= currSpNWaves(sort_inds);
currSpSymmetry  = refSymmetry(indsSpFound, indexElectrode);
currSpSymmetry	= currSpSymmetry(sort_inds);

%% SET SPINLDE INFO

% init spindle structure
sps = struct(...
    'onset',        {},...
    'duration',     {},...
    'freq',         {},...
    'peakPos',      {},...
    'peakNeg',      {},...
    'peak2peak',	{},...
    'nWaves',       {},...
    'symmetry',     {}...
    );
cell_empty = cell(1, numel(currSpStarts));
[sps(1:numel(currSpStarts)).onset] = cell_empty{:};

% set spindle onsets & duraiton
num2Cell_tmp    = num2cell(currSpStarts);
[sps.onset]     = num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpEnds - currSpStarts);
[sps.duration]	= num2Cell_tmp{:};

% set other features
num2Cell_tmp    = num2cell(currSpFreq);
[sps.freq]      = num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpPeakPos);
[sps.peakPos]   = num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpPeakNeg);
[sps.peakNeg]   = num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpPeak2Peak);
[sps.peak2peak]	= num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpNWaves);
[sps.nWaves]    = num2Cell_tmp{:};
num2Cell_tmp    = num2cell(currSpSymmetry);
[sps.symmetry]  = num2Cell_tmp{:};    

% sps to table
sps = struct2table(sps);

% set the output structure
sps_info.source_fpath   = fpath;
sps_info.electrode      = electrode;
sps_info.sleep_stage    = sleep_stage;
sps_info.time_units     = 'seconds';

sps_info.sps            = sps;

end