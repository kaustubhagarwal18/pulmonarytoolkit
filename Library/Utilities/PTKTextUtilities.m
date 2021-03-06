classdef PTKTextUtilities < handle
    % PTKTextUtilities. Utility functions related to strings
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        


    methods (Static)
    
        function text = RemoveHtml(html_text)
            % Strips out HTML code from the provided string
            
            text = regexprep(html_text, '<.*?>', ' ');
            text = regexprep(text, '  ', ' ');
        end
        
        function file_name = MakeFilenameValid(file_name)
            % Strips out invalid characters from a filename
            
            file_name = regexprep(file_name, '  ', ' ');
            file_name(ismember(file_name, ' %*,.:;!?/<>\^%"')) = [];
        end
        
        function [sorted_filenames, sorted_indices] = SortFilenames(original_filenames)
            % Sorts a list of filenames, taking into account numbers
            
            if isempty(original_filenames)
                sorted_filenames = [];
                sorted_indices = [];
                return;
            end
            
            if isa(original_filenames{1}, 'PTKFilename')
                filenames = PTKContainerUtilities.GetFieldValuesFromSet(original_filenames, 'Name');
            else
                filenames = original_filenames;
            end
            
            
            % Determine the maximum number of consecutive digits across all of
            % the filenames
            [start_indices, end_indices] = regexp(filenames,'\d+','start','end');
            max_digits = 0;
            for filename_index = 1 : length(start_indices)
                string_lengths = 1 + end_indices{filename_index} - start_indices{filename_index};
                if ~isempty(string_lengths)
                    max_digits = max(max_digits, max(string_lengths));
                end
            end
            
            % Format each sequence of numbers into a fixed width field, so that
            % sorting will correctly order numbered files which don't have
            % leading zeros
            sprintf_field = ['%' int2str(max_digits) 'd']; %#ok<NASGU>
            reformatted_filenames = regexprep(filenames, '(\d+)', '${ sprintf(sprintf_field, (str2num(($1))) ) }');
            
            % Finally perform the sorting on the reformatted filenames
            [~, sorted_indices] = sort(reformatted_filenames);
            sorted_filenames = original_filenames(sorted_indices');
        end
        
        function filenames_stripped = StripFileparts(filenames)
            % Returns just the main filenames, removing the path and filetype
            
            cell_input = iscell(filenames);
            if ~cell_input
                filenames = {filenames};
            end
            filenames_stripped = [];
            for index = 1 : numel(filenames)
                [~, file_name, ~] = fileparts(filenames{index});
                filenames_stripped{index} = file_name;
            end
            if ~cell_input
                filenames_stripped = filenames_stripped{1};
            end
        end
        
    end
    
end

