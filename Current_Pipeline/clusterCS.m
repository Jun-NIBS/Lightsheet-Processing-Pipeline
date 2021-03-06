%% parameters

inputRoot        = '/groups/lightsheet/lightsheet/home/ackermand/Lightsheet_Data/Paper/Supplementary_Data_2/Image_Data.MultiFused/';%'X:\SiMView2\13-12-30\Pha_E1_H2BRFP_01_20131230_140802.corrected\Results\MultiFused';
outputRoot       = '/groups/lightsheet/lightsheet/home/ackermand/Lightsheet_Data/Paper/Supplementary_Data_2/ForTimeLapseMovie/Image_Data.MultiFused.Corrected/';%'X:\SiMView2\13-12-30\Pha_E1_H2BRFP_01_20131230_140802.corrected\Results\MultiFused.Corrected';
headerPattern    = 'Dme_E1_H2ARFP.TM??????_multiFused_blending/'; %'Pha_E1_H2BRFP.TM??????_multiFused_blending\';
filePattern      = 'SPM00_TM??????_CM00_CM01_CHN00_CHN01.fusedStack'; % 'SPM00_TM??????_CM00_CM01_CHN00_CHN01.fusedStack';
configRoot       = '/groups/lightsheet/lightsheet/home/ackermand/Lightsheet_Data/Paper/Supplementary_Data_2/configRoot/';%'X:\SiMView2\13-12-30\Pha_E1_H2BRFP_01_20131230_140802.corrected\Scripts\SPM00_CM00_CM01_CHN00_CHN01_stackCorrection';

timepoints       = 0:0;
dataType         = 1;      % 0: process projections only, 1: process stacks and projections
percentile       = [1 10]; % [percentileFlag, subsampling], percentileFlag - 0: calculate true minimum, otherwise: use as percentile for minimum calculation

inputType        = 0;      % 0: input data in KLB format
                           % 1: input data in JP2 format
                           % 2: input data in TIF format
outputType       = 2;      % 0: output data saved in KLB format
                           % 1: output data saved in JP2 format
                           % 2: output data saved in TIF format

% configuration of drift correction
correctDrift     = 1;
referenceTime    = 0;
referenceROI     = [];     % [xStart xStop; yStart yStop; zStart zStop], provide empty vector to enforce use of maximum dimensions

% configuration of intensity normalization
correctIntensity = 1;

maxStampDigits   = 6;

localRun         = [1 0];  % slot 1: flag for local vs. cluster execution (0: cluster submission, 1: local workstation)
                           %         note: cluster submission requires a Windows cluster with HPC 2008 support (see "job submit" commands below)
                           % slot 2: number of parallel workers for execution on local workstation (only needed if slot 1 is set to 1)
                           %         note: use "0" to enable automated detection of available CPU cores

jobMemory        = [1 0];  % slot 1: flag for automated memory management (0: disable, 1: enable)
                           % slot 2: estimated upper boundary for memory consumption per submitted time point (in GB)
                           %         note 1: slot 2 is only evaluated if automated memory management is disabled
                           %         note 2: "0" indicates memory consumption below "coreMemory" threshold and enables parametric submission mode

coreMemory       = floor(((96 - 8) * 1024) / (12 * 1024)); % memory boundary for switching from parametric to memory-managed submission (in GB)
                                                           % note: parameter is only required for cluster submission

%% keller parameters
% % % 
% % % inputRoot        = 'X:' filesep 'SiMView1' filesep '14-01-21' filesep 'Mmu_E1_CAGTAG1_01_23_20140121_141339.corrected' filesep 'Results' filesep 'MultiFused';
% % % outputRoot       = 'X:' filesep 'SiMView1' filesep '14-01-21' filesep 'Mmu_E1_CAGTAG1_01_23_20140121_141339.corrected' filesep 'Results' filesep 'MultiFused.Corrected';
% % % headerPattern    = 'Mmu_E1_CAGTAG1.TM??????_multiFused_blending' filesep;
% % % filePattern      = 'SPM00_TM??????_CM00_CM01_CHN00_CHN01.fusedStack';
% % % configRoot       = 'X:' filesep 'SiMView1' filesep '14-01-21' filesep 'Mmu_E1_CAGTAG1_01_23_20140121_141339.corrected' filesep 'Scripts' filesep 'SPM00_CM00_CM01_CHN00_CHN01_stackCorrection';
% % % 
% % % timepoints       = 0:570;
% % % dataType         = 1;      % 0: process projections only, 1: process stacks and projections
% % % percentile       = [1 10]; % [percentileFlag, subsampling], percentileFlag - 0: calculate true minimum, otherwise: use as percentile for minimum calculation
% % % 
% % % inputType        = 0;      % 0: input data in KLB format
% % %                            % 1: input data in JP2 format
% % %                            % 2: input data in TIF format
% % % outputType       = 0;      % 0: output data saved in KLB format
% % %                            % 1: output data saved in JP2 format
% % %                            % 2: output data saved in TIF format
% % % 
% % % % configuration of drift correction
% % % correctDrift     = 1;
% % % referenceTime    = 305;
% % % referenceROI     = [];     % [xStart xStop; yStart yStop; zStart zStop], provide empty vector to enforce use of maximum dimensions
% % % 
% % % % configuration of intensity normalization
% % % correctIntensity = 1;
% % % 
% % % maxStampDigits   = 6;
% % % 
% % % localRun         = [0 0];  % slot 1: flag for local vs. cluster execution (0: cluster submission, 1: local workstation)
% % %                            % slot 2: number of parallel workers for execution on local workstation (only needed if slot 1 is set to 1)
% % %                            %         note: use "0" to enable automated detection of available CPU cores
% % % 
% % % jobMemory        = [1 0];  % slot 1: flag for automated memory management (0: disable, 1: enable)
% % %                            % slot 2: estimated upper boundary for memory consumption per submitted time point (in GB)
% % %                            %         note 1: slot 2 is only evaluated if automated memory management is disabled
% % %                            %         note 2: "0" indicates memory consumption below "coreMemory" threshold and enables parametric submission mode
% % % 
% % % coreMemory       = floor(((96 - 8) * 1024) / (12 * 1024)); % memory boundary for switching from parametric to memory-managed submission (in GB)

%% initialization

if localRun(1) == 1 && localRun(2) == 0
    localRun(2) = feature('numcores');
    disp(' ');
    disp([num2str(localRun(2)) ' CPU cores were detected and will be allocated for parallel processing.']);
end;

switch outputType
    case 0
        outputExtension = '.klb';
    case 1
        outputExtension = '.jp2';
    case 2
        outputExtension = '.tif';
end;

nTimepoints = numel(timepoints);
inputDatabase = cell(nTimepoints, 1);
outputDatabase = cell(nTimepoints, 2);

for n = 1:nTimepoints
    inputDatabase{n} = [inputRoot filesep '' headerPattern filePattern];
    outputDatabase{n, 1} = [outputRoot filesep '' headerPattern];
    outputDatabase{n, 2} = [outputRoot filesep '' headerPattern filePattern];
    for i = maxStampDigits:-1:1
        precision = ['%.' num2str(i) 'd'];
        
        positions1 = strfind(inputDatabase{n}, repmat('?', [1 i]));
        for k = 1:length(positions1)
            inputDatabase{n}(positions1(k):(positions1(k) + i - 1)) = num2str(timepoints(n), precision);
        end;
        
        positions2 = strfind(outputDatabase{n, 1}, repmat('?', [1 i]));
        for k = 1:length(positions2)
            outputDatabase{n, 1}(positions2(k):(positions2(k) + i - 1)) = num2str(timepoints(n), precision);
        end;
        
        positions3 = strfind(outputDatabase{n, 2}, repmat('?', [1 i]));
        for k = 1:length(positions3)
            outputDatabase{n, 2}(positions3(k):(positions3(k) + i - 1)) = num2str(timepoints(n), precision);
        end;
    end;
end;

load([configRoot filesep 'dimensions.mat']);
load([configRoot filesep 'dimensionsMax.mat']);
load([configRoot filesep 'dimensionsDeltas.mat']);

if correctDrift
    load([configRoot filesep 'driftTable.mat']);
    
    xOffsets = driftTable(:, 2);
    yOffsets = driftTable(:, 3);
    zOffsets = driftTable(:, 4);
    
    referenceIndex = find(dimensions(:, 1) == referenceTime, 1);
    
    xOffsets = xOffsets(referenceIndex) - xOffsets;
    yOffsets = yOffsets(referenceIndex) - yOffsets;
    zOffsets = zOffsets(referenceIndex) - zOffsets;
else
    xOffsets = [];
    yOffsets = [];
    zOffsets = [];
end;

if correctIntensity
    load([configRoot filesep 'intensityBackgrounds.mat']);
    load([configRoot filesep 'intensityFactors.mat']);
else
    intensityBackgrounds = [];
    intensityFactors = [];
end;

%% job submission

for t = numel(timepoints):-1:1
    if exist([outputDatabase{t, 2} '_yzProjection.corrected' outputExtension], 'file') == 2
        timepoints(t) = [];
        inputDatabase(t) = [];
        outputDatabase(t, :) = [];
    end;
end;

if ~isempty(timepoints)
    nTimepoints = numel(timepoints);
    
    if jobMemory(1) == 1 && localRun(1) ~= 1
        if dataType == 0
            unitX = 0;
        else
            unitX = 2 * dimensionsMax(1) * dimensionsMax(2) * dimensionsMax(3) / (1024 ^ 3);
        end;
        jobMemory(1, 2) = ceil(1.2 * 3 * unitX);
    end;
    
    currentTime = clock;
    timeString = [...
        num2str(currentTime(1)) num2str(currentTime(2), '%.2d') num2str(currentTime(3), '%.2d') ...
        '_' num2str(currentTime(4), '%.2d') num2str(currentTime(5), '%.2d') num2str(round(currentTime(6) * 1000), '%.5d')];
    parameterDatabase = [pwd filesep 'jobParameters.correctStack.' timeString '.mat'];
    
    save(parameterDatabase, ...
        'inputDatabase', 'outputDatabase', 'dataType', 'timepoints', 'dimensions', 'dimensionsMax', 'dimensionsDeltas', ...
        'correctIntensity', 'intensityBackgrounds', 'intensityFactors', 'correctDrift', 'inputType', 'outputType', ...
        'percentile', 'referenceROI', 'xOffsets', 'yOffsets', 'zOffsets', 'jobMemory');
    
    if localRun(1) ~= 1
        disp(' ');
        disp(['Estimated memory consumption per workstation core is ' num2str(jobMemory(2)) ' GB.']);
        disp(' ');
        if jobMemory(2) <= coreMemory && nTimepoints > 1
            disp(['Submitting parametric cluster job for ' num2str(nTimepoints) ' time point(s).']);
        else
            disp(['Submitting individual cluster job(s) for ' num2str(nTimepoints) ' time point(s).']);
        end;
        disp(' ');
        
        if jobMemory(2) <= coreMemory && nTimepoints > 1
            cmdFunction = ['correctStack(''' parameterDatabase ''', *, ' num2str(jobMemory(2)) ')'];
            cmd = ['job submit /scheduler:keller-cluster.janelia.priv /user:simview ' ...
                '/parametric:1-' num2str(nTimepoints) ':1 runMatlabJob.cmd """' pwd '""" """' cmdFunction '"""'];
            [status, systemOutput] = system(cmd);
            disp(['System response: ' systemOutput]);
        else
            for t = 1:nTimepoints
                cmdFunction = ['correctStack(''' parameterDatabase ''', ' num2str(t) ', ' num2str(jobMemory(2)) ')'];
                cmd = ['job submit /scheduler:keller-cluster.janelia.priv /user:simview ' ...
                    '/progressmsg:"' num2str(jobMemory(2)) '" runMatlabJob.cmd """' pwd '""" """' cmdFunction '"""'];
                [status, systemOutput] = system(cmd);
                disp(['Submitting time point ' num2str(timepoints(t), '%.4d') ': ' systemOutput]);
            end;
        end;
    else
        disp(' ');
        
        if localRun(2) > 1 && nTimepoints > 1
            if matlabpool('size') > 0
                matlabpool('close');
            end;
            matlabpool(localRun(2));
            
            disp(' ');
            
            parfor t = 1:nTimepoints
                disp(['Submitting time point ' num2str(timepoints(t), '%.4d') ' to a local worker.']);
                correctStack(parameterDatabase, t, jobMemory(2));
            end;
            
            disp(' ');
            
            if matlabpool('size') > 0
                matlabpool('close');
            end;
            
            disp(' ');
        else
            for t = 1:nTimepoints
                disp(['Processing time point ' num2str(timepoints(t), '%.4d')]);
                correctStack(parameterDatabase, t, jobMemory(2));
                disp(' ');
            end;
        end;
    end;
else
    disp(' ');
    disp('Existing processing results detected for all selected time points. Submission aborted.');
    disp(' ');
end;