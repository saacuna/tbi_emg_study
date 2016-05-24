classdef list
    % Filename: list.m
    % Author:   Samuel Acuna
    % Date:     24 May 2016
    % Description:
    % This class holds static functions that list and display trial information.
    % The trials must already in the workspace.
    %
    % Example Usage:
    %       tbiStudy.list.labels(tr(1))
    
    methods (Static)
        function labels(tr)
            disp(tr.emgLabel');  % these labels should be same for each trial examined
        end
    end
end