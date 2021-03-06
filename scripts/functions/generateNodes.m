function [nodes,ignore_node_heading] = generateNodes(origNode_fname,newNode_pname,outfname)

if nargin < 3
    %outfname = 'NewOutputs\new_nodes.txt';
    outfname = [];
    if nargin < 2
        %source location for header files for all of the new nodes
        %newNode_pname = 'C:\Users\wea\Documents\Arduino\libraries\OpenAudio_ArduinoLibrary\';
        newNode_pname = 'C:\Users\wea\Documents\Arduino\libraries\Tympan_Library\src\';
        if nargin < 2
            %location of original node text from original index.html
            origNode_fname = 'ParsedInputs\nodes.txt';
        end
    end
end


addpath('functions\');

%% read existing node file and get the nodes
orig_nodes = parseNodeFile(origNode_fname);

% keep just a subset of the nodes
% nodes_keep = {'AudioInputI2S','AudioInputUSB',...
%     'AudioOutputI2S','AudioOutputUSB',...
%     'AudioPlaySdWav',...
%     'AudioPlayQueue','AudioRecordQueue',...
%     'AudioSynthWaveformSine','AudioSynthWaveform','AudioSynthToneSweep',...
%     'AudioSynthNoiseWhite','AudioSynthNoisePink',...
%     'AudioAnalyzePeak','AudioAnalyzeRMS',...
%     'AudioControlSGTL5000'};
%
% nodes_keep = {'AudioInputUSB',...
%     'AudioOutputUSB',...
%     'AudioPlaySdWav',...
%     'AudioPlayQueue','AudioRecordQueue',...
%     'AudioAnalyzePeak','AudioAnalyzeRMS'};

%adjust node shortnames
for Inode=1:length(orig_nodes)
    node = orig_nodes(Inode);
    if strcmpi(node.type,'AudioInputUSB');
        node.shortName = 'usbAudioIn';
    elseif strcmpi(node.type,'AudioOutputUSB');
        node.shortName = 'usbAudioOut';
    end
    orig_nodes(Inode)=node;
end

% %adjust node icons
% for Inode=1:length(orig_nodes)
%     node = orig_nodes(Inode);
%     if strcmpi(node.type,'AudioControlSGTL5000')
%         node.icon = 'debug.png';
%     end
%     orig_nodes(Inode)=node;
% end


%keep just these
nodes_keep = {
    %'AudioControlSGTL5000',...
    %'AudioInputUSB',...
    %'AudioOutputUSB',...
    };
nodes=[];
for Ikeep=1:length(nodes_keep)
    for Iorig=1:length(orig_nodes)
            node = orig_nodes(Iorig);
        if strcmpi(node.type,nodes_keep{Ikeep})
            if isempty(nodes)
                nodes = node;
            else
                nodes(end+1) = node;
            end
        end
    end
end

%% read source files and load new node data

%To build text for the new nodes, use buildNewNodes.m.
%Then paste into XLSX to edit as desired.
%Then load the XLSX via the command below
if (0)
    [num,txt,raw]=xlsread('myNodes.xlsx');
    headings = raw(1,:);
    new_node_data = raw(2:end,:);
else
    %get info directly from underlying classes
    %source_pname = 'C:\Users\wea\Documents\Arduino\libraries\OpenAudio_ArduinoLibrary\';
    [headings, new_node_data]=buildNewNodes(newNode_pname);
end
ignore_node_heading = 'comment_lines';

%% generate the new nodes 

if ~isempty(nodes)
    template = nodes(1);
else
    template=[];
    template.type = 'AudioControlFoo';
    template.data = '{"defaults":{"name":{"value":"new"}}';
    template.shortName = 'foo';
    template.inputs = '0';
    template.output = '0';
    template.category = 'control-function';
    template.color = '#E6E0F8';
    template.icon = 'arrow-in.png';
end
new_nodes=[];
for Inode = 1:size(new_node_data,1)
    node = template;
    for Iheading = 1:length(headings)
        %if ~strcmpi(headings{Iheading},ignore_node_heading)
            node.(headings{Iheading}) = new_node_data{Inode,Iheading};
        %end
    end
    
    if isempty(nodes)
        nodes = node;
    else
        nodes(end+1) = node;
    end
end
clear new_node_data

%remove some undesired nodes
remove_names = {'AudioControlSGTL5000_Extended'
    'AudioConfigFIRFilterBank_F32';
    'AudioTestSignalGenerator_F32';
    'AudioTestSignalMeasurementInterface_F32';
    'AudioTestSignalMeasurement_F32';
    'AudioTestSignalMeasurementMulti_F32';
    'AudioControlSignalTesterInterface_F32';
    'AudioControlSignalTester_F32';
    'AudioControlTestAmpSweep_F32';
    'AudioControlTestFreqSweep_F32';
    'AudioTestSignalGenerator_F32';
    'AudioTestSignalMeasurementInterface_F32';
    'AudioTestSignalMeasurement_F32';
    'AudioTestSignalMeasurementMulti_F32';
    'AudioControlSignalTesterInterface_F32';
    'AudioControlSignalTester_F32';
    'AudioControlTestAmpSweep_F32';
    'AudioControlTestFreqSweep_F32';
    'AudioConvert_I16toF32';
    'AudioConvert_F32toI16';
    'AudioSettings_F32';
    'audio_block_f32_t';
    'FFT_F32';
    'IFFT_F32';
    'FFT_Overlapped_Base_F32';
    'SdBaseFile_Gre'
    'SdFile_Gre'
    'SdFileSystem_Gre'
    'SdFat_Gre'
    'SdFatSdio'
    'SdFatSdioEX'
    'SdFatSoftSpi'
    'SdFatEX'
    'SdFatSoftSpiEX'
    'Sd2Card'
    'MinimumSerial'
    'SysCall'
    'TeensyAudioControl'
    'TympanPins'
    'TympanPins_RevA'
    'TympanPins_RevC'
    'TympanPins_RevD'
    'TympanBase'
    'TympanRevC'
    'TympanRevD'
    'AudioControlTLV320AIC3206'
    };
Ikeep = ones(size(nodes));
for Irem=1:length(remove_names)
    for Inode = 1:length(Ikeep)
        if strcmpi(nodes(Inode).type,remove_names{Irem})
            Ikeep(Inode)=0;
        end
    end
end
disp(['Removing unwanted nodes: keeping ' num2str(sum(Ikeep)) ' of ' num2str(length(nodes))]);
Ikeep = find(Ikeep);
nodes = nodes(Ikeep);

%% put some of the nodes into a particular desired order
first_second = {};
%first_second(end+1,:) ={'tlv320aic3206' 'sgtl5000'};
first_second(end+1,:) ={'inputI2S' 'usbAudioIn'};
first_second(end+1,:) ={'outputI2S' 'usbAudioOut'};
first_second(end+1,:) ={'i2sAudioIn' 'usbAudioIn'};
first_second(end+1,:) ={'i2sAudioOut' 'usbAudioOut'};
first_second(end+1,:) ={'audioInI2S' 'audioInUSB'};
first_second(end+1,:) ={'audioOutI2S' 'audioOutUSB'};

for Iswap = 1:length(first_second);
    all_names = {nodes(:).shortName};
    I = find(strcmpi(all_names,first_second{Iswap,1}));
    J = find(strcmpi(all_names,first_second{Iswap,2}));
    if ~isempty(I) & ~isempty(J)
        first_node = nodes(I); second_node = nodes(J);
        nodes(min([I(1) J(1)])) = first_node;  %this comes first
        nodes(max([I(1) J(1)])) = second_node;  %this comes second
    end
end

%% write new nodes
if ~isempty(outfname)
    writeNodeText(nodes,outfname,ignore_node_heading)
end



