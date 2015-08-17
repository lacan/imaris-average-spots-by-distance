%
%
%  Create New Spots Object from Average Distance of Closest Spots
%  This XTension looks for spots closer than the given distances, removes
%  them and adds a single spot object in its place whose center is the
%  average distance of all spots that were found in that cluster
%
%
%  By Olivier Burri @ EPFL BioImaging & Optics Platform
%  License: GNU
%
%
%  Installation:
%  - Copy this file into the XTensions folder in the Imaris installation directory.
%  - You will find this function in the Image Processing Spots Functions menu
%
%    <CustomTools>
%      <Menu>
%       <Submenu name="Spots Functions">
%        <Item name="Average Spots By Distance" icon="Matlab">
%          <Command>MatlabXT::XTSpotsAverageByDistance(%i)</Command>
%        </Item>
%       </Submenu>
%      </Menu>
%      <SurpassTab>
%        <SurpassComponent name="bpSpots">
%          <Item name="Average Spots By Distance" icon="Matlab">
%            <Command>MatlabXT::XTSpotsAverageByDistance(%i)</Command>
%          </Item>
%        </SurpassComponent>
%      </SurpassTab>
%    </CustomTools>
%

function XTSpotsAverageByDistance(aImarisApplicationID, varargin)

% connect to Imaris interface
if ~isa(aImarisApplicationID, 'Imaris.IApplicationPrxHelper')
    javaaddpath ImarisLib.jar
    vImarisLib = ImarisLib;
    if ischar(aImarisApplicationID)
        aImarisApplicationID = round(str2double(aImarisApplicationID));
    end
    vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
else
    vImarisApplication = aImarisApplicationID;
end

% the user has to create a scene with some spots
vSurpassScene = vImarisApplication.GetSurpassScene;
if isequal(vSurpassScene, [])
    msgbox('Please create some Spots in the Surpass scene!');
    return;
end

% get the spots
vSpots = vImarisApplication.GetFactory.ToSpots(vImarisApplication.GetSurpassSelection);

% search the spots if not previously selected
if ~vImarisApplication.GetFactory.IsSpots(vSpots)
    for vChildIndex = 1:vSurpassScene.GetNumberOfChildren
        vDataItem = vSurpassScene.GetChild(vChildIndex - 1);
        if vImarisApplication.GetFactory.IsSpots(vDataItem)
            vSpots = vImarisApplication.GetFactory.ToSpots(vDataItem);
            break;
        end
    end
    % did we find the spots?
    if isempty(vSpots)
        msgbox('Please create some spots!');
        return;
    end
end

% Make a dialog unless varargin is set
if nargin == 1
    prompt = {'Enter Max Separation Distance:'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'1'};
    vAnswer = inputdlg(prompt,dlg_title,num_lines,def);
    dist = str2double(vAnswer);
else
    dist = varargin{1};
end
    vRGBA = vSpots.GetColorRGBA;
    
    % get the spots coordinates
    vSpotsXYZ = vSpots.GetPositionsXYZ;
    vSpotsTime = vSpots.GetIndicesT;
    vSpotsRadius = vSpots.GetRadiiXYZ;
    
    timepoints = unique(vSpotsTime);
    % Do distance measurement
    posXYZ = [];
    radiiXYZ =[];
    spotTimes = [];
    for t=1:size(timepoints)
        oriSpots = vSpotsXYZ(vSpotsTime==timepoints(t),:);
        oriRadii = vSpotsRadius(vSpotsTime==timepoints(t),:);
        
        [idx] = rangesearch(oriSpots,oriSpots,dist);
        
        for i=1:size(idx,1)
            if size(idx{i}, 2) > 1
                spots = idx{i};
                
                newSpots = mean(oriSpots(spots,:),1);
                newRadii = mean(oriRadii(spots,:),1);
                posXYZ(end+1,:) = newSpots;
                radiiXYZ(end+1,:) = newRadii;
                spotTimes(end+1,1) = timepoints(t);
                % Clear spots
                idx(spots) = {single(0)};
            end
        end
        posXYZ = [posXYZ; oriSpots(cell2mat(idx)>0,:)];
        radiiXYZ = [radiiXYZ; oriRadii(cell2mat(idx)>0,:)];
        spotTimes = [spotTimes; repmat(timepoints(t), sum(cell2mat(idx)>0),1)];
    end
    
    % Create new spots object
    vNewSpots = vImarisApplication.GetFactory.CreateSpots;
    vNewSpots.Set(posXYZ, spotTimes, radiiXYZ(:,1));
    vNewSpots.SetRadiiXYZ(radiiXYZ);
    vNewSpots.SetColorRGBA(vRGBA);
    vNewSpots.SetName([char(vSpots.GetName), ' Dist <' num2str(dist)]);
    vSpots.GetParent.AddChild(vNewSpots, -1);
    
end
