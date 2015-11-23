classdef emg_tbi_nmbl < handle
    % Filename: emg_tbi_nmbl.m
    % Author:   Samuel Acuna
    % Date:     20 Nov 2015
    % Description:
    % This class file is used to proces collected EMG data from the TCNL
    % lab for their TBI study.
    %
    % Example usage:
    %
    % note: protocol should be scripted like this in a driver file. 
    properties(GetAccess = 'public', SetAccess = 'private')
           % public read access, but private write access.
        
    end
    methods ( Access = public )
        % constructor function
        function obj = emg_tbi_nmbl()
            %   Inputs (optional)
            %       infile - file to be loaded
            %                If infile is unspecified, the user is prompted to select the input file
            %       inpath - directory of location where data file is located
            %               when no path is specified, it defaults to current directory

        end
    end
    methods ( Access = private )
    
    end         
end