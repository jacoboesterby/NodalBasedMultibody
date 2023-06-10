function [Nodes,Elem] = readAbaInp(inp_file)
%=========================================================================%
%This function reads the Abaqus input file to define the nodes and element
%connectivity. 
%Input:         inp_file   -   String with Abaqus input file name
% Output:       Nodes      -   Matrix containing node number and nodal
%                              position (node#, x, y, z)
%               Elem       -   Matrix containing node connectivity to form
%                              elements
%=========================================================================%
%Read nodes from file 
fid = fopen(inp_file);
file  = textscan(fid,'%s','delim','\n');
idxNodeBegin = find(contains(file{1},'*Node'));
idxElemBegin = find(contains(file{1},'*Element'));
%Find location where nodes end
idxStarNode = find(contains(file{1},'*'));
idxNodeEnd = idxStarNode(find(idxStarNode>idxNodeBegin,1,'first'));
%Find location where elements end
idxStarElem = find(contains(file{1},'*'));
idxElemEnd = idxStar(find(idxStarElem>idxElemBegin,1,'first'));

NodeLines = sprintf('%s\n',file{1}{idxNodeBegin+1:idxNodeEnd-1});
ElemLines = sprintf('%s\n',file{1}{idxElemBegin+1:idxElemEnd-1});
Nodes = str2num(NodeLines);
Elem = str2num(ElemLines);
%Move nodes to COG
Nodes(:,4) = Nodes(:,4) - 0.2135389; %From .dat file of Abaqus output

end